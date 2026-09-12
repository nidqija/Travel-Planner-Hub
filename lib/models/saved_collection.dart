import 'package:flutter/material.dart';
import 'travel_destination.dart';
import 'video_item.dart';

class SavedPlaceItem {
  final String id;
  final TravelDestination destination;
  final VideoItem video;
  final DateTime savedAt;
  String? customNotes;

  SavedPlaceItem({
    required this.id,
    required this.destination,
    required this.video,
    required this.savedAt,
    this.customNotes,
  });
}

class SavedCollection {
  final String id;
  String name;
  String emoji;
  String description;
  final DateTime createdAt;
  List<String> placeIds;

  SavedCollection({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.createdAt,
    List<String>? placeIds,
  }) : placeIds = placeIds ?? [];
}

class SavedCollectionsManager extends ChangeNotifier {
  static final SavedCollectionsManager instance = SavedCollectionsManager._internal();

  SavedCollectionsManager._internal() {
    _initDefaultCollections();
  }

  final Map<String, SavedCollection> _collections = {};
  final Map<String, SavedPlaceItem> _places = {};

  List<SavedCollection> get collections => _collections.values.toList();
  List<SavedPlaceItem> get allPlaces => _places.values.toList();

  int get totalPlacesCount => _places.length;
  int get totalCollectionsCount => _collections.length;

  void _initDefaultCollections() {
    final sampleFeed = VideoItem.getSampleFeed();

    final c1 = SavedCollection(
      id: 'want_to_visit',
      name: 'Want to Visit',
      emoji: '📍',
      description: 'Priority destinations inspired by my FYP feed',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    );

    final c2 = SavedCollection(
      id: 'summer_escapes',
      name: 'Summer Escapes',
      emoji: '☀️',
      description: 'Sun-soaked coastal retreats and island getaways',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    );

    final c3 = SavedCollection(
      id: 'nature_zen',
      name: 'Nature & Zen',
      emoji: '🌿',
      description: 'Glacial lakes, sacred forests, and serene waters',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    );

    _collections[c1.id] = c1;
    _collections[c2.id] = c2;
    _collections[c3.id] = c3;

    // Seed with Kyoto (Video 01) and Banff (Video 02)
    if (sampleFeed.isNotEmpty) {
      final v1 = sampleFeed[0];
      final p1 = SavedPlaceItem(
        id: v1.destination.id,
        destination: v1.destination,
        video: v1,
        savedAt: DateTime.now().subtract(const Duration(days: 4)),
        customNotes: 'Morning mist views mirrored in the river pavilion',
      );
      _places[p1.id] = p1;
      c1.placeIds.add(p1.id);
      c3.placeIds.add(p1.id);
    }

    if (sampleFeed.length > 1) {
      final v2 = sampleFeed[1];
      final p2 = SavedPlaceItem(
        id: v2.destination.id,
        destination: v2.destination,
        video: v2,
        savedAt: DateTime.now().subtract(const Duration(days: 2)),
        customNotes: 'Geothermal azure waters and Aurora Borealis skies',
      );
      _places[p2.id] = p2;
      c1.placeIds.add(p2.id);
      c2.placeIds.add(p2.id);
      c3.placeIds.add(p2.id);
    }

    if (sampleFeed.length > 2) {
      final v3 = sampleFeed[2];
      final p3 = SavedPlaceItem(
        id: v3.destination.id,
        destination: v3.destination,
        video: v3,
        savedAt: DateTime.now().subtract(const Duration(days: 1)),
        customNotes: 'Sunset caldera views from cliffside villa',
      );
      _places[p3.id] = p3;
      c2.placeIds.add(p3.id);
    }
  }

  bool isPlaceSaved(String destinationId) {
    return _places.containsKey(destinationId);
  }

  bool isPlaceInCollection(String destinationId, String collectionId) {
    final col = _collections[collectionId];
    return col != null && col.placeIds.contains(destinationId);
  }

  List<SavedPlaceItem> getPlacesForCollection(String collectionId) {
    final col = _collections[collectionId];
    if (col == null) return [];
    return col.placeIds
        .map((pid) => _places[pid])
        .whereType<SavedPlaceItem>()
        .toList();
  }

  List<SavedCollection> getCollectionsForPlace(String destinationId) {
    return _collections.values
        .where((col) => col.placeIds.contains(destinationId))
        .toList();
  }

  void savePlace(VideoItem video, {List<String>? toCollectionIds, String? notes}) {
    final destId = video.destination.id;
    if (!_places.containsKey(destId)) {
      _places[destId] = SavedPlaceItem(
        id: destId,
        destination: video.destination,
        video: video,
        savedAt: DateTime.now(),
        customNotes: notes,
      );
    } else if (notes != null) {
      _places[destId]!.customNotes = notes;
    }

    video.isSaved = true;

    // If no collections specified, save to default 'Want to Visit'
    final targets = (toCollectionIds == null || toCollectionIds.isEmpty)
        ? ['want_to_visit']
        : toCollectionIds;

    for (final colId in targets) {
      final col = _collections[colId];
      if (col != null && !col.placeIds.contains(destId)) {
        col.placeIds.add(destId);
      }
    }

    notifyListeners();
  }

  void updatePlaceCollections(VideoItem video, List<String> selectedCollectionIds) {
    final destId = video.destination.id;

    if (selectedCollectionIds.isEmpty) {
      // Remove place completely
      removePlaceEverywhere(destId);
      video.isSaved = false;
      return;
    }

    // Ensure place exists
    if (!_places.containsKey(destId)) {
      _places[destId] = SavedPlaceItem(
        id: destId,
        destination: video.destination,
        video: video,
        savedAt: DateTime.now(),
      );
    }

    video.isSaved = true;

    for (final col in _collections.values) {
      if (selectedCollectionIds.contains(col.id)) {
        if (!col.placeIds.contains(destId)) {
          col.placeIds.add(destId);
        }
      } else {
        col.placeIds.remove(destId);
      }
    }

    notifyListeners();
  }

  void togglePlaceInCollection(VideoItem video, String collectionId) {
    final destId = video.destination.id;
    final col = _collections[collectionId];
    if (col == null) return;

    if (col.placeIds.contains(destId)) {
      col.placeIds.remove(destId);
      // Check if place is in any other collection
      final anyOther = _collections.values.any((c) => c.placeIds.contains(destId));
      if (!anyOther) {
        _places.remove(destId);
        video.isSaved = false;
      }
    } else {
      if (!_places.containsKey(destId)) {
        _places[destId] = SavedPlaceItem(
          id: destId,
          destination: video.destination,
          video: video,
          savedAt: DateTime.now(),
        );
      }
      col.placeIds.add(destId);
      video.isSaved = true;
    }

    notifyListeners();
  }

  void removePlaceFromCollection(String destinationId, String collectionId) {
    final col = _collections[collectionId];
    if (col != null) {
      col.placeIds.remove(destinationId);
      final anyOther = _collections.values.any((c) => c.placeIds.contains(destinationId));
      if (!anyOther) {
        _places.remove(destinationId);
      }
      notifyListeners();
    }
  }

  void removePlaceEverywhere(String destinationId) {
    _places.remove(destinationId);
    for (final col in _collections.values) {
      col.placeIds.remove(destinationId);
    }
    notifyListeners();
  }

  SavedCollection createCollection({
    required String name,
    required String emoji,
    String description = '',
  }) {
    final id = 'col_${DateTime.now().millisecondsSinceEpoch}';
    final col = SavedCollection(
      id: id,
      name: name.trim().isEmpty ? 'Untitled Playlist' : name.trim(),
      emoji: emoji.trim().isEmpty ? '📍' : emoji.trim(),
      description: description.trim(),
      createdAt: DateTime.now(),
    );
    _collections[id] = col;
    notifyListeners();
    return col;
  }

  void deleteCollection(String collectionId) {
    _collections.remove(collectionId);
    // Remove any orphan places
    final activePlaceIds = _collections.values.expand((c) => c.placeIds).toSet();
    _places.removeWhere((id, _) => !activePlaceIds.contains(id));
    notifyListeners();
  }
}
