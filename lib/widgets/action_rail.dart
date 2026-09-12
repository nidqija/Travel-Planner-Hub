import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/video_item.dart';
import '../theme/app_theme.dart';

class ActionRail extends StatefulWidget {
  final VideoItem video;
  final VoidCallback onLikeToggled;
  final VoidCallback onSaveToggled;
  final VoidCallback onOpenComments;
  final VoidCallback onShare;
  final VoidCallback onShareToSquad;

  const ActionRail({
    super.key,
    required this.video,
    required this.onLikeToggled,
    required this.onSaveToggled,
    required this.onOpenComments,
    required this.onShare,
    required this.onShareToSquad,
  });

  @override
  State<ActionRail> createState() => _ActionRailState();
}

class _ActionRailState extends State<ActionRail>
    with SingleTickerProviderStateMixin {
  late AnimationController _discController;

  @override
  void initState() {
    super.initState();
    _discController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _discController.dispose();
    super.dispose();
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Creator Avatar with Follow Badge
        _buildAvatar(),
        const SizedBox(height: 18),

        // Like Button
        _buildActionButton(
          icon: widget.video.isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
          iconColor: widget.video.isLiked ? AppTheme.crimsonPulse : AppTheme.ghostIce,
          label: _formatCount(widget.video.likes),
          onTap: widget.onLikeToggled,
          highlight: widget.video.isLiked,
        ),
        const SizedBox(height: 16),

        // Comments Button
        _buildActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          iconColor: AppTheme.ghostIce,
          label: _formatCount(widget.video.comments),
          onTap: widget.onOpenComments,
        ),
        const SizedBox(height: 16),

        // Save / Bookmark Button
        _buildActionButton(
          icon: widget.video.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          iconColor: widget.video.isSaved ? AppTheme.solarAmber : AppTheme.ghostIce,
          label: _formatCount(widget.video.saves),
          onTap: widget.onSaveToggled,
          highlight: widget.video.isSaved,
        ),
        const SizedBox(height: 16),

        // Share Button
        _buildActionButton(
          icon: Icons.share_rounded,
          iconColor: AppTheme.ghostIce,
          label: _formatCount(widget.video.shares),
          onTap: widget.onShare,
        ),
        const SizedBox(height: 16),

        // Social Travel Squad Share Button
        _buildSquadShareButton(),
        const SizedBox(height: 18),

        // Rotating Audio Disc
        _buildRotatingAudioDisc(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.vapourIon, width: 2),
            gradient: const LinearGradient(
              colors: [AppTheme.vapourIon, AppTheme.slateCard],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              widget.video.creatorName.isNotEmpty
                  ? widget.video.creatorName[0].toUpperCase()
                  : 'A',
              style: const TextStyle(
                color: AppTheme.ghostIce,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -7,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.solarAmber,
            ),
            child: const Icon(
              Icons.add,
              color: AppTheme.midnightObsidian,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.midnightObsidian.withValues(alpha: 0.65),
              border: Border.all(
                color: highlight ? iconColor.withValues(alpha: 0.6) : AppTheme.frameBorder,
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'monospace',
              color: highlight ? iconColor : AppTheme.ghostIce,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquadShareButton() {
    return GestureDetector(
      onTap: widget.onShareToSquad,
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.vapourIon, AppTheme.solarAmber],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.solarAmber.withValues(alpha: 0.35),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.group_add_rounded,
                color: AppTheme.midnightObsidian,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Squad',
            style: TextStyle(
              fontFamily: 'monospace',
              color: AppTheme.solarAmber,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotatingAudioDisc() {
    return AnimatedBuilder(
      animation: _discController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _discController.value * 2 * math.pi,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.midnightObsidian,
              border: Border.all(
                color: AppTheme.mutedPhosphor.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.slateCard,
                ),
                child: const Center(
                  child: Icon(
                    Icons.music_note_rounded,
                    color: AppTheme.solarAmber,
                    size: 11,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
