import 'package:flutter/material.dart';
import '../models/group_chat.dart';
import '../theme/app_theme.dart';
import 'fyp_feed_page.dart';
import 'ideation_page.dart';
import 'saved_collections_page.dart';
import 'social_home_page.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;
  final repo = GroupChatRepository.instance;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  int get _totalUnreadMessages {
    int total = 0;
    for (final chat in repo.chats) {
      total += chat.unreadCount;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final unreadCount = _totalUnreadMessages;

        return Scaffold(
          backgroundColor: AppTheme.midnightObsidian,
          body: IndexedStack(
            index: _currentIndex,
            children: [
              // Tab 0: Main Home Page (Social & Group Chats)
              SocialHomePage(
                onNavigateTab: (idx) => _onTabTapped(idx),
              ),

              // Tab 1: For You Page (FYP Video Reel)
              const FypFeedPage(),

              // Tab 2: Ideation Section (AI Algorithm & Trip Sparks)
              IdeationPage(
                onSwitchToFyp: () => _onTabTapped(1),
              ),

              // Tab 3: Saved Collections & Bookings
              const SavedCollectionsPage(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppTheme.midnightObsidian,
              border: Border(
                top: BorderSide(
                  color: AppTheme.frameBorder,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.forum_rounded,
                      activeIcon: Icons.forum,
                      label: 'Home',
                      badgeCount: unreadCount,
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.play_circle_outline_rounded,
                      activeIcon: Icons.play_circle_fill_rounded,
                      label: 'For You',
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: Icons.psychology_outlined,
                      activeIcon: Icons.psychology_rounded,
                      label: 'Ideation',
                      isAiHighlight: true,
                    ),
                    _buildNavItem(
                      index: 3,
                      icon: Icons.bookmark_border_rounded,
                      activeIcon: Icons.bookmark_rounded,
                      label: 'Saved',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int badgeCount = 0,
    bool isAiHighlight = false,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (isAiHighlight ? AppTheme.solarAmber.withValues(alpha: 0.15) : AppTheme.vapourIon.withValues(alpha: 0.15))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? (isAiHighlight ? AppTheme.solarAmber : AppTheme.vapourIon)
                      : AppTheme.mutedPhosphor,
                  size: 22,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: const BoxDecoration(
                        color: AppTheme.crimsonPulse,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                if (isAiHighlight && !isSelected)
                  Positioned(
                    right: -4,
                    top: -2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.solarAmber,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? (isAiHighlight ? AppTheme.solarAmber : AppTheme.ghostIce)
                    : AppTheme.mutedPhosphor,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
