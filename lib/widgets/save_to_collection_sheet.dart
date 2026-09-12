import 'package:flutter/material.dart';
import '../models/saved_collection.dart';
import '../models/video_item.dart';
import '../pages/saved_collections_page.dart';
import '../theme/app_theme.dart';

class SaveToCollectionSheet extends StatefulWidget {
  final VideoItem video;

  const SaveToCollectionSheet({
    super.key,
    required this.video,
  });

  static Future<void> show(BuildContext context, {required VideoItem video}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SaveToCollectionSheet(video: video),
    );
  }

  @override
  State<SaveToCollectionSheet> createState() => _SaveToCollectionSheetState();
}

class _SaveToCollectionSheetState extends State<SaveToCollectionSheet> {
  final SavedCollectionsManager _manager = SavedCollectionsManager.instance;
  bool _isCreatingCollection = false;
  final TextEditingController _nameController = TextEditingController();
  String _selectedEmoji = '📍';

  final List<String> _emojiOptions = [
    '📍', '✈️', '🌸', '🏔️', '🏖️', '⛩️', '🌟', '🎒', '☕', '🍕'
  ];

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onManagerUpdate);
  }

  @override
  void dispose() {
    _manager.removeListener(_onManagerUpdate);
    _nameController.dispose();
    super.dispose();
  }

  void _onManagerUpdate() {
    if (mounted) setState(() {});
  }

  void _handleCreateCollection() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final newCol = _manager.createCollection(
      name: name,
      emoji: _selectedEmoji,
    );

    // Automatically add current place to the new collection
    _manager.togglePlaceInCollection(widget.video, newCol.id);

    _nameController.clear();
    setState(() {
      _isCreatingCollection = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.cinemaSlate,
        content: Text('Created "$name" and saved ${widget.video.destination.locationName}!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dest = widget.video.destination;
    final collections = _manager.collections;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppTheme.midnightObsidian,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppTheme.vapourIon.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.vapourIon.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: -2,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Grab Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.frameBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.cinemaSlate,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bookmark_add_rounded, color: AppTheme.solarAmber, size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SAVE PLACE TO PLAYLIST',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: AppTheme.ghostIce,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              'Curate your travel itinerary & bucket lists',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.cinemaSlate,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.frameBorder),
                    ),
                    child: const Icon(Icons.close_rounded, color: AppTheme.mutedPhosphor, size: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Target Place Preview Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cinemaSlate,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.frameBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.slateCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.vapourIon.withValues(alpha: 0.4)),
                    ),
                    child: Center(
                      child: Text(dest.flagEmoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                dest.cityCountry,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.ghostIce,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppTheme.vapourIon.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.video.indexLabel,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: AppTheme.vapourIon,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${dest.travelTime.split('+').first.trim()} • Best: ${dest.optimalVisitingMonths.split('(').first.trim()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.mutedPhosphor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Playlists Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'SELECT PLAYLISTS / COLLECTIONS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.solarAmber,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isCreatingCollection = !_isCreatingCollection;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        _isCreatingCollection ? Icons.remove_rounded : Icons.add_rounded,
                        color: AppTheme.vapourIon,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _isCreatingCollection ? 'Cancel' : 'New Playlist',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.vapourIon,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Inline New Collection Creator Box
            if (_isCreatingCollection) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.slateCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.vapourIon.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create Custom Travel Playlist:',
                      style: TextStyle(color: AppTheme.ghostIce, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Selected Emoji Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.midnightObsidian,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.frameBorder),
                          ),
                          child: Text(_selectedEmoji, style: const TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Playlist Name (e.g. Honeymoon Stays)',
                              hintStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11.5),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Emoji Selector Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _emojiOptions.map((emoji) {
                          final isPicked = emoji == _selectedEmoji;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedEmoji = emoji),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: isPicked ? AppTheme.vapourIon.withValues(alpha: 0.3) : AppTheme.midnightObsidian,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isPicked ? AppTheme.vapourIon : AppTheme.frameBorder,
                                ),
                              ),
                              child: Text(emoji, style: const TextStyle(fontSize: 14)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Create & Add Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.vapourIon,
                          foregroundColor: AppTheme.midnightObsidian,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: _handleCreateCollection,
                        child: const Text(
                          'Create & Add Place',
                          style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w800, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),

            // List of Collections with Checkbox Toggles
            ...collections.map((col) {
              final isInCollection = col.placeIds.contains(dest.id);
              return GestureDetector(
                onTap: () {
                  _manager.togglePlaceInCollection(widget.video, col.id);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isInCollection ? AppTheme.slateCard : AppTheme.cinemaSlate,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isInCollection ? AppTheme.solarAmber.withValues(alpha: 0.6) : AppTheme.frameBorder,
                      width: isInCollection ? 1.2 : 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(col.emoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    col.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppTheme.ghostIce,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${col.placeIds.length} places saved',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      color: AppTheme.mutedPhosphor,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isInCollection ? AppTheme.solarAmber : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isInCollection ? AppTheme.solarAmber : AppTheme.mutedPhosphor,
                            width: 1.4,
                          ),
                        ),
                        child: isInCollection
                            ? const Icon(Icons.check_rounded, color: AppTheme.midnightObsidian, size: 16)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Bottom Actions: Done Button & View Collections
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.vapourIon),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SavedCollectionsPage()),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.collections_bookmark_rounded, color: AppTheme.vapourIon, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'View Collections',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.vapourIon,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.solarAmber,
                      foregroundColor: AppTheme.midnightObsidian,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
