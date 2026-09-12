import 'package:flutter/material.dart';
import '../models/video_item.dart';
import '../theme/app_theme.dart';

class CommentsSheet extends StatefulWidget {
  final VideoItem video;

  const CommentsSheet({super.key, required this.video});

  static void show(BuildContext context, VideoItem video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CommentsSheet(video: video),
    );
  }

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [
    {
      'author': 'Elena Vance',
      'handle': '@elena.arch',
      'text': 'The phase cancellation on the third wave harmonic is pristine.',
      'time': '2h ago',
      'likes': 142,
      'isLiked': false,
    },
    {
      'author': 'Kaelen Mori',
      'handle': '@kmori_art',
      'text': 'What shader pass are you using for the volumetric dispersion?',
      'time': '5h ago',
      'likes': 89,
      'isLiked': true,
    },
    {
      'author': 'Sora Tanaka',
      'handle': '@sora.compute',
      'text': 'The algorithm served this directly into my feed right when I was researching Chladni oscillations. Spot on!',
      'time': '8h ago',
      'likes': 56,
      'isLiked': false,
    },
  ];

  void _postComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.insert(0, {
        'author': 'You',
        'handle': '@current_user',
        'text': text,
        'time': 'Just now',
        'likes': 0,
        'isLiked': false,
      });
      widget.video.comments += 1;
      _commentController.clear();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.frameBorder, width: 1.5),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.mutedPhosphor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.video.comments} Comments',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.ghostIce,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.mutedPhosphor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.frameBorder, height: 1),

          // Comment List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              itemCount: _comments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final c = _comments[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.slateCard,
                      child: Text(
                        (c['author'] as String)[0],
                        style: const TextStyle(
                          color: AppTheme.ghostIce,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                c['author'],
                                style: const TextStyle(
                                  color: AppTheme.ghostIce,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                c['time'],
                                style: const TextStyle(
                                  color: AppTheme.mutedPhosphor,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c['text'],
                            style: const TextStyle(
                              color: AppTheme.ghostIce,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          c['isLiked'] = !(c['isLiked'] as bool);
                          c['likes'] = (c['likes'] as int) + (c['isLiked'] ? 1 : -1);
                        });
                      },
                      child: Column(
                        children: [
                          Icon(
                            c['isLiked'] ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: c['isLiked'] ? AppTheme.crimsonPulse : AppTheme.mutedPhosphor,
                            size: 16,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${c['likes']}',
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
                );
              },
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppTheme.midnightObsidian,
              border: Border(
                top: BorderSide(color: AppTheme.frameBorder, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Add an observation...',
                      hintStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 13),
                      filled: true,
                      fillColor: AppTheme.cinemaSlate,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppTheme.frameBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppTheme.frameBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppTheme.vapourIon),
                      ),
                    ),
                    onSubmitted: (_) => _postComment(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppTheme.vapourIon),
                  onPressed: _postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
