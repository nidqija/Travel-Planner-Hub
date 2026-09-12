import 'package:flutter/material.dart';
import '../models/saved_collection.dart';
import '../theme/app_theme.dart';
import '../widgets/nearby_hotels_sheet.dart';
import '../widgets/save_to_collection_sheet.dart';

class SavedCollectionsPage extends StatefulWidget {
  final Function(String videoId)? onSelectVideo;

  const SavedCollectionsPage({
    super.key,
    this.onSelectVideo,
  });

  @override
  State<SavedCollectionsPage> createState() => _SavedCollectionsPageState();
}

class _SavedCollectionsPageState extends State<SavedCollectionsPage> {
  final SavedCollectionsManager _manager = SavedCollectionsManager.instance;
  String _selectedCollectionId = 'all'; // 'all' or specific collection ID

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onManagerUpdate);
  }

  @override
  void dispose() {
    _manager.removeListener(_onManagerUpdate);
    super.dispose();
  }

  void _onManagerUpdate() {
    if (mounted) setState(() {});
  }

  void _showCreateCollectionDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedEmoji = '📍';

    final emojis = ['📍', '✈️', '🌸', '🏔️', '🏖️', '⛩️', '🌟', '🎒', '☕', '🍕', '🛥️', '⛺'];

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.cinemaSlate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: AppTheme.vapourIon, width: 1.2),
              ),
              title: const Row(
                children: [
                  Icon(Icons.playlist_add_rounded, color: AppTheme.solarAmber, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Create Travel Playlist',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.ghostIce,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose an icon:',
                    style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: emojis.map((e) {
                        final isPicked = e == selectedEmoji;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedEmoji = e),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isPicked
                                  ? AppTheme.vapourIon.withValues(alpha: 0.25)
                                  : AppTheme.midnightObsidian,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isPicked ? AppTheme.vapourIon : AppTheme.frameBorder,
                              ),
                            ),
                            child: Text(e, style: const TextStyle(fontSize: 16)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Playlist Title (e.g. Dream Japan 2026)',
                      hintStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                      isDense: true,
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.frameBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.vapourIon),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 12),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Description or travel vibe notes (optional)',
                      hintStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11.5),
                      isDense: true,
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.frameBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.vapourIon),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.mutedPhosphor)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.solarAmber,
                    foregroundColor: AppTheme.midnightObsidian,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isNotEmpty) {
                      final newCol = _manager.createCollection(
                        name: name,
                        emoji: selectedEmoji,
                        description: descCtrl.text.trim(),
                      );
                      setState(() {
                        _selectedCollectionId = newCol.id;
                      });
                      Navigator.pop(dialogCtx);
                    }
                  },
                  child: const Text('Create Playlist', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final collections = _manager.collections;
    final allPlaces = _manager.allPlaces;

    final displayedPlaces = _selectedCollectionId == 'all'
        ? allPlaces
        : _manager.getPlacesForCollection(_selectedCollectionId);

    final selectedCollection = _selectedCollectionId == 'all'
        ? null
        : collections.firstWhere((c) => c.id == _selectedCollectionId, orElse: () => collections.first);

    return Scaffold(
      backgroundColor: AppTheme.midnightObsidian,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopBar(),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                children: [
                  // Hero Stats Bar
                  _buildStatsBanner(allPlaces.length, collections.length),

                  const SizedBox(height: 14),

                  // Playlists / Collections Carousel Selector
                  _buildCollectionsSelector(collections, allPlaces.length),

                  const SizedBox(height: 16),

                  // Section Title: Active Playlist Name & Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              _selectedCollectionId == 'all' ? Icons.travel_explore_rounded : Icons.bookmark_rounded,
                              color: AppTheme.solarAmber,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _selectedCollectionId == 'all'
                                    ? 'ALL SAVED PLACES (${displayedPlaces.length})'
                                    : '${selectedCollection?.emoji ?? '📍'} ${selectedCollection?.name.toUpperCase() ?? 'PLAYLIST'} (${displayedPlaces.length})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: AppTheme.ghostIce,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (selectedCollection != null && selectedCollection.id.startsWith('col_'))
                        GestureDetector(
                          onTap: () {
                            _manager.deleteCollection(selectedCollection.id);
                            setState(() => _selectedCollectionId = 'all');
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, color: AppTheme.crimsonPulse, size: 13),
                              SizedBox(width: 3),
                              Text(
                                'Delete Playlist',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: AppTheme.crimsonPulse,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  if (selectedCollection != null && selectedCollection.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      selectedCollection.description,
                      style: const TextStyle(
                        color: AppTheme.mutedPhosphor,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Places List or Empty State
                  if (displayedPlaces.isEmpty)
                    _buildEmptyState()
                  else
                    ...displayedPlaces.map((place) => _buildSavedPlaceCard(place)),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
      decoration: const BoxDecoration(
        color: AppTheme.midnightObsidian,
        border: Border(bottom: BorderSide(color: AppTheme.frameBorder, width: 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back to Feed
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.cinemaSlate,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.frameBorder),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.ghostIce, size: 12),
                  SizedBox(width: 6),
                  Text(
                    'FEED',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.ghostIce,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Title & Live Badge
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cyberEmerald,
                  ),
                ),
                const SizedBox(width: 6),
                const Flexible(
                  child: Text(
                    'SAVED COLLECTIONS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.ghostIce,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // + New Playlist Button
          GestureDetector(
            onTap: _showCreateCollectionDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.vapourIon.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.vapourIon.withValues(alpha: 0.6)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: AppTheme.vapourIon, size: 13),
                  SizedBox(width: 4),
                  Text(
                    'NEW',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.vapourIon,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBanner(int totalPlaces, int totalCollections) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.frameBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatTile(
              label: 'SAVED PLACES',
              value: '$totalPlaces',
              color: AppTheme.solarAmber,
              icon: Icons.place_rounded,
            ),
          ),
          Container(width: 1, height: 32, color: AppTheme.frameBorder),
          Expanded(
            child: _buildStatTile(
              label: 'PLAYLISTS',
              value: '$totalCollections',
              color: AppTheme.vapourIon,
              icon: Icons.folder_special_rounded,
            ),
          ),
          Container(width: 1, height: 32, color: AppTheme.frameBorder),
          Expanded(
            child: _buildStatTile(
              label: 'SYNCED FYP',
              value: 'Active',
              color: AppTheme.cyberEmerald,
              icon: Icons.sync_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: AppTheme.mutedPhosphor,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionsSelector(List<SavedCollection> collections, int allCount) {
    return SizedBox(
      height: 78,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // "All Places" Option
          _buildCollectionPill(
            id: 'all',
            name: 'All Places',
            emoji: '🌐',
            count: allCount,
            isSelected: _selectedCollectionId == 'all',
          ),

          // User & Default Collections
          ...collections.map((col) {
            return _buildCollectionPill(
              id: col.id,
              name: col.name,
              emoji: col.emoji,
              count: col.placeIds.length,
              isSelected: _selectedCollectionId == col.id,
            );
          }),

          // + Quick Add Card
          GestureDetector(
            onTap: _showCreateCollectionDialog,
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.slateCard.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.frameBorder, style: BorderStyle.solid),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline_rounded, color: AppTheme.vapourIon, size: 20),
                  SizedBox(height: 4),
                  Text(
                    'Add Playlist',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.vapourIon,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionPill({
    required String id,
    required String name,
    required String emoji,
    required int count,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCollectionId = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cinemaSlate : AppTheme.slateCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.solarAmber : AppTheme.frameBorder,
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.solarAmber.withValues(alpha: 0.15),
                blurRadius: 10,
                spreadRadius: -1,
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: isSelected ? AppTheme.solarAmber : AppTheme.mutedPhosphor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? AppTheme.ghostIce : AppTheme.mutedPhosphor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPlaceCard(SavedPlaceItem place) {
    final dest = place.destination;
    final video = place.video;

    final botHotel = dest.hotels.firstWhere(
      (h) => h.dealBadge == 'AI TOP PICK',
      orElse: () => dest.hotels.first,
    );

    final assignedCollections = _manager.getCollectionsForPlace(dest.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.frameBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Flag, City, Video Tag & Action Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(dest.flagEmoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dest.cityCountry,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.ghostIce,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${video.indexLabel} • ${video.creatorHandle}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    color: AppTheme.vapourIon,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Manage Collections Pill
              GestureDetector(
                onTap: () {
                  SaveToCollectionSheet.show(context, video: video);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.slateCard,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.frameBorder),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_note_rounded, color: AppTheme.solarAmber, size: 13),
                      SizedBox(width: 4),
                      Text(
                        'Playlists',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.solarAmber,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Contextual Reason / Vibe
          Text(
            dest.contextualRecommendation,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppTheme.ghostIce.withValues(alpha: 0.85),
              fontSize: 11.5,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          // Telemetry row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.midnightObsidian,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.flight_takeoff_rounded, color: AppTheme.vapourIon, size: 12),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    '${dest.travelTime.split('+').first.trim()} • Arr: ${dest.estimatedArrivalTime} • Best: ${dest.optimalVisitingMonths.split('(').first.trim()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.mutedPhosphor,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Assigned Collection Tags
          Wrap(
            spacing: 5,
            runSpacing: 4,
            children: assignedCollections.map((col) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.slateCard,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.frameBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(col.emoji, style: const TextStyle(fontSize: 10)),
                    const SizedBox(width: 3),
                    Text(
                      col.name,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.ghostIce,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Bot Recommended Hotel Highlight & Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bot Hotel preview
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.smart_toy_rounded, color: AppTheme.solarAmber, size: 11),
                        const SizedBox(width: 4),
                        const Text(
                          'BOT PICK:',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.solarAmber,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            botHotel.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.ghostIce,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${botHotel.pricePerNight} / night • ${botHotel.roomType}',
                      style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 10),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Action buttons: Explore Stays & Remove
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      NearbyHotelsSheet.show(context, destination: dest);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.vapourIon.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.vapourIon.withValues(alpha: 0.6)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.hotel_rounded, color: AppTheme.vapourIon, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Stays',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: AppTheme.vapourIon,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      if (_selectedCollectionId == 'all') {
                        _manager.removePlaceEverywhere(dest.id);
                      } else {
                        _manager.removePlaceFromCollection(dest.id, _selectedCollectionId);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppTheme.slateCard,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.frameBorder),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: AppTheme.mutedPhosphor, size: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.frameBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.bookmark_border_rounded, color: AppTheme.solarAmber, size: 36),
          const SizedBox(height: 10),
          const Text(
            'No places in this playlist yet',
            style: TextStyle(
              color: AppTheme.ghostIce,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap the bookmark button on any video in your FYP feed to add places to this travel playlist.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11.5, height: 1.3),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.solarAmber,
              foregroundColor: AppTheme.midnightObsidian,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Browse Feed', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
