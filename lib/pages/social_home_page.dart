import 'package:flutter/material.dart';
import '../models/group_chat.dart';
import '../models/social_community.dart';
import '../theme/app_theme.dart';
import '../widgets/group_booking_sheets.dart';
import 'community_detail_page.dart';
import 'group_chat_detail_page.dart';

enum SocialSection { squads, community, groupBookings, tripPlanner }

class SocialHomePage extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const SocialHomePage({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<SocialHomePage> createState() => _SocialHomePageState();
}

class _SocialHomePageState extends State<SocialHomePage> {
  final repo = GroupChatRepository.instance;
  final communityRepo = SocialCommunityRepository.instance;

  SocialSection _activeSection = SocialSection.squads;

  // Squad filters
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _filters = [
    'All',
    'Active Trips',
    'Planning',
  ];

  // Community filters
  String _selectedCommunityCategory = 'All';
  final List<String> _communityCategories = [
    'All',
    'Nomads',
    'Adventure',
    'Culture',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateSquadDialog() {
    final titleController = TextEditingController();
    final destController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppTheme.vapourIon, width: 1.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.mutedPhosphor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'New Travel Squad',
                style: TextStyle(
                  color: AppTheme.ghostIce,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                style: const TextStyle(color: AppTheme.ghostIce, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Squad Name',
                  labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 13),
                  hintText: 'e.g. Kyoto Cherry Blossom Crew',
                  hintStyle: const TextStyle(color: AppTheme.frameBorder, fontSize: 13),
                  filled: true,
                  fillColor: AppTheme.midnightObsidian,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.frameBorder),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: destController,
                style: const TextStyle(color: AppTheme.ghostIce, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Destination',
                  labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 13),
                  hintText: 'e.g. Tokyo & Kyoto',
                  hintStyle: const TextStyle(color: AppTheme.frameBorder, fontSize: 13),
                  filled: true,
                  fillColor: AppTheme.midnightObsidian,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.frameBorder),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.vapourIon,
                    foregroundColor: AppTheme.midnightObsidian,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    final dest = destController.text.trim();
                    if (title.isNotEmpty) {
                      Navigator.pop(context);
                      final destSuffix = dest.isNotEmpty ? ' for $dest' : '';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.cinemaSlate,
                          content: Text('Created "$title"$destSuffix squad.'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Create Squad',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStoryPreview(TravelSquadStory story) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppTheme.frameBorder)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.mutedPhosphor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: story.ringColor.withValues(alpha: 0.2),
                    child: Text(
                      story.name[0],
                      style: TextStyle(
                        color: story.ringColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.name,
                          style: const TextStyle(
                            color: AppTheme.ghostIce,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          story.destination,
                          style: const TextStyle(
                            color: AppTheme.mutedPhosphor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                story.status,
                style: const TextStyle(
                  color: AppTheme.ghostIce,
                  fontSize: 13.5,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.ghostIce,
                        side: const BorderSide(color: AppTheme.frameBorder),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Direct message started with ${story.name}')),
                        );
                      },
                      child: const Text('Message'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.vapourIon,
                        foregroundColor: AppTheme.midnightObsidian,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onNavigateTab?.call(1);
                      },
                      child: const Text('Watch Reels', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.midnightObsidian,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section Switcher Navigation (Squads / Community / Bookings / Co-Planner)
            _buildTopSegmentedBar(),

            // Content Area depending on section
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildCurrentSectionContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSegmentedBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: const BoxDecoration(
        color: AppTheme.midnightObsidian,
        border: Border(bottom: BorderSide(color: AppTheme.frameBorder, width: 0.8)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildSectionPill(
              section: SocialSection.squads,
              title: 'Squads',
              icon: Icons.chat_bubble_outline_rounded,
            ),
            const SizedBox(width: 8),
            _buildSectionPill(
              section: SocialSection.community,
              title: 'Community Hub',
              icon: Icons.hub_outlined,
              isHighlight: true,
            ),
            const SizedBox(width: 8),
            _buildSectionPill(
              section: SocialSection.groupBookings,
              title: 'Group Bookings',
              icon: Icons.home_work_outlined,
            ),
            const SizedBox(width: 8),
            _buildSectionPill(
              section: SocialSection.tripPlanner,
              title: 'Trip Co-Planner',
              icon: Icons.edit_calendar_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionPill({
    required SocialSection section,
    required String title,
    required IconData icon,
    bool isHighlight = false,
  }) {
    final isSelected = _activeSection == section;

    return GestureDetector(
      onTap: () => setState(() => _activeSection = section),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isHighlight ? AppTheme.solarAmber.withValues(alpha: 0.2) : AppTheme.vapourIon.withValues(alpha: 0.18))
              : AppTheme.cinemaSlate,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isHighlight ? AppTheme.solarAmber : AppTheme.vapourIon)
                : AppTheme.frameBorder,
            width: isSelected ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? (isHighlight ? AppTheme.solarAmber : AppTheme.vapourIon)
                  : AppTheme.mutedPhosphor,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppTheme.ghostIce : AppTheme.mutedPhosphor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSectionContent() {
    switch (_activeSection) {
      case SocialSection.squads:
        return _buildSquadsSection();
      case SocialSection.community:
        return _buildCommunitySection();
      case SocialSection.groupBookings:
        return _buildGroupBookingsSection();
      case SocialSection.tripPlanner:
        return _buildTripPlannerSection();
    }
  }

  // ==========================================
  // SECTION 1: MY SQUADS (Direct Chats & Stories)
  // ==========================================
  Widget _buildSquadsSection() {
    return Column(
      key: const ValueKey('section_squads'),
      children: [
        _buildMinimalHeader(),
        Expanded(
          child: ListenableBuilder(
            listenable: repo,
            builder: (context, _) {
              final filteredChats = repo.chats.where((chat) {
                final matchesSearch = _searchQuery.isEmpty ||
                    chat.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    chat.destination.toLowerCase().contains(_searchQuery.toLowerCase());

                if (!matchesSearch) return false;

                if (_selectedFilter == 'Active Trips') {
                  return chat.id == 'chat-bali' || chat.id == 'chat-swiss' || chat.id == 'chat-tokyo';
                } else if (_selectedFilter == 'Planning') {
                  return chat.id == 'chat-seoul' || chat.id == 'chat-iceland';
                }
                return true;
              }).toList();

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  _buildMinimalStoriesRail(),
                  const SizedBox(height: 16),
                  _buildMinimalFilterChips(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CHATS',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.mutedPhosphor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          '${filteredChats.length}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.mutedPhosphor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (filteredChats.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: const Text(
                        'No chats found',
                        style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 13),
                      ),
                    )
                  else
                    ...filteredChats.map((chat) => _buildMinimalGroupChatTile(chat)),
                  const SizedBox(height: 20),
                  _buildMinimalCommunityBanner(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Squads',
                      style: TextStyle(
                        color: AppTheme.ghostIce,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Private travel chats & shared ledgers',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.mutedPhosphor.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showCreateSquadDialog,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cinemaSlate,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.frameBorder),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: AppTheme.vapourIon, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'New',
                        style: TextStyle(
                          color: AppTheme.ghostIce,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.cinemaSlate,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.mutedPhosphor, size: 17),
                hintText: 'Search chats or destinations...',
                hintStyle: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12.5),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalStoriesRail() {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: repo.stories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final story = repo.stories[index];
          final firstName = story.name.split(' ').first;

          return GestureDetector(
            onTap: () => _showStoryPreview(story),
            child: SizedBox(
              width: 54,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: story.ringColor, width: 1.8),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.cinemaSlate,
                      child: Text(
                        firstName[0],
                        style: TextStyle(
                          color: story.ringColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    firstName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.ghostIce,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMinimalFilterChips() {
    return Row(
      children: _filters.map((filter) {
        final isSelected = filter == _selectedFilter;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.slateCard : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppTheme.vapourIon.withValues(alpha: 0.5) : AppTheme.frameBorder,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? AppTheme.ghostIce : AppTheme.mutedPhosphor,
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMinimalGroupChatTile(GroupChat chat) {
    final words = chat.title.split(' ');
    final initials = words.length > 1
        ? '${words[0][0]}${words[1][0]}'
        : (chat.title.isNotEmpty ? chat.title[0] : 'S');

    final cleanDestination = chat.destination.split(',').first.trim();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupChatDetailPage(chatId: chat.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.frameBorder, width: 0.6),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        chat.memberAvatarColors.first,
                        chat.memberAvatarColors.last,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: AppTheme.midnightObsidian,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                if (chat.isTyping)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.vapourIon,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.midnightObsidian, width: 2),
                      ),
                    ),
                  ),
              ],
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
                          chat.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.ghostIce,
                            fontSize: 14,
                            fontWeight: chat.unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '• $cleanDestination',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.mutedPhosphor.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  chat.isTyping
                      ? Text(
                          '${chat.typingUser ?? 'Someone'} is typing...',
                          style: const TextStyle(
                            color: AppTheme.vapourIon,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: chat.unreadCount > 0
                                ? AppTheme.ghostIce
                                : AppTheme.mutedPhosphor.withValues(alpha: 0.8),
                            fontSize: 12.5,
                            fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  chat.lastMessageTime,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: chat.unreadCount > 0 ? AppTheme.solarAmber : AppTheme.mutedPhosphor,
                    fontSize: 10,
                    fontWeight: chat.unreadCount > 0 ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                if (chat.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.vapourIon,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: const TextStyle(
                        color: AppTheme.midnightObsidian,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalCommunityBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.frameBorder, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.hub_rounded, color: AppTheme.solarAmber, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Explore Social Communities',
                      style: TextStyle(
                        color: AppTheme.ghostIce,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Join verified clubs for Tokyo, Bali, Swiss Alps & Iceland',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.mutedPhosphor.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _activeSection = SocialSection.community;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.solarAmber,
              foregroundColor: AppTheme.midnightObsidian,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Browse',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 2: COMMUNITY HUB (Discover & Enter Guilds)
  // ==========================================
  Widget _buildCommunitySection() {
    return ListenableBuilder(
      key: const ValueKey('section_community'),
      listenable: communityRepo,
      builder: (context, _) {
        final communities = communityRepo.communities.where((c) {
          if (_selectedCommunityCategory == 'All') return true;
          return c.category.toLowerCase() == _selectedCommunityCategory.toLowerCase();
        }).toList();

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Travel Communities',
                        style: TextStyle(
                          color: AppTheme.ghostIce,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      Text(
                        'Enter public guilds to co-plan and book together',
                        style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.cinemaSlate,
                    side: const BorderSide(color: AppTheme.frameBorder),
                  ),
                  icon: const Icon(Icons.add_location_alt_rounded, color: AppTheme.vapourIon, size: 18),
                  tooltip: 'Propose New Community',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppTheme.cinemaSlate,
                        content: Text('Verified community application form opened.'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _communityCategories.map((cat) {
                  final isSel = cat == _selectedCommunityCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCommunityCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.slateCard : AppTheme.cinemaSlate,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSel ? AppTheme.vapourIon : AppTheme.frameBorder,
                            width: isSel ? 1.4 : 0.8,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: isSel ? AppTheme.ghostIce : AppTheme.mutedPhosphor,
                            fontSize: 11.5,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Community Cards
            ...communities.map((c) => _buildCommunityCard(c)),
          ],
        );
      },
    );
  }

  Widget _buildCommunityCard(CommunityGroup c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: c.isJoined ? AppTheme.vapourIon.withValues(alpha: 0.6) : AppTheme.frameBorder,
          width: c.isJoined ? 1.2 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              gradient: LinearGradient(
                colors: [
                  c.bannerGradient.first.withValues(alpha: 0.7),
                  c.bannerGradient.last.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Center(
                    child: Text(c.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              c.badgeText,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: AppTheme.solarAmber,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${c.memberCount} members',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.name,
                        style: const TextStyle(
                          color: AppTheme.ghostIce,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.tagline,
                  style: TextStyle(
                    color: AppTheme.ghostIce.withValues(alpha: 0.9),
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: c.tags.take(3).map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.midnightObsidian,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.frameBorder),
                      ),
                      child: Text(
                        '#$t',
                        style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 10.5),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Quick Activity Stats: Group Bookings & Trips
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.midnightObsidian,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.home_work_rounded, size: 14, color: AppTheme.cyberEmerald),
                          const SizedBox(width: 5),
                          Text(
                            '${c.groupBookings.length} Group Stays',
                            style: const TextStyle(color: AppTheme.ghostIce, fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 16, color: AppTheme.frameBorder),
                      Row(
                        children: [
                          const Icon(Icons.edit_calendar_rounded, size: 14, color: AppTheme.solarAmber),
                          const SizedBox(width: 5),
                          Text(
                            '${c.tripPlans.length} Planned Trips',
                            style: const TextStyle(color: AppTheme.ghostIce, fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Action Buttons: Enter Community Hub & Join toggle
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.vapourIon,
                          foregroundColor: AppTheme.midnightObsidian,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CommunityDetailPage(communityId: c.id),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Enter Community',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 15),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: c.isJoined ? AppTheme.cyberEmerald : AppTheme.ghostIce,
                          side: BorderSide(
                            color: c.isJoined ? AppTheme.cyberEmerald : AppTheme.frameBorder,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          communityRepo.toggleJoinCommunity(c.id);
                        },
                        child: Text(
                          c.isJoined ? 'Joined' : 'Join Guild',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
    );
  }

  // ==========================================
  // SECTION 3: GROUP BOOKINGS HUB
  // ==========================================
  Widget _buildGroupBookingsSection() {
    return ListenableBuilder(
      key: const ValueKey('section_group_bookings'),
      listenable: communityRepo,
      builder: (context, _) {
        final allBookings = communityRepo.allGroupBookings;

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grouped Bookings',
                        style: TextStyle(
                          color: AppTheme.ghostIce,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      Text(
                        'Shared villa takeovers & private room blocks',
                        style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cyberEmerald,
                    foregroundColor: AppTheme.midnightObsidian,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final defaultComm = communityRepo.communities.first;
                    CreateGroupBookingSheet.show(context, defaultComm.id, defaultComm.destinationFocus);
                  },
                  icon: const Icon(Icons.add, size: 15),
                  label: const Text('Propose', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (allBookings.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('No group bookings active.', style: TextStyle(color: AppTheme.mutedPhosphor)),
                ),
              )
            else
              ...allBookings.map((b) => _buildGroupBookingItem(b)),
          ],
        );
      },
    );
  }

  Widget _buildGroupBookingItem(CommunityGroupBooking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: b.hasUserBooked ? AppTheme.cyberEmerald : AppTheme.frameBorder,
          width: b.hasUserBooked ? 1.5 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.vapourIon.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        b.communityName.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.vapourIon,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      b.bookingRef,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.solarAmber,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  b.title,
                  style: const TextStyle(
                    color: AppTheme.ghostIce,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppTheme.mutedPhosphor, size: 14),
                    const SizedBox(width: 4),
                    Text('${b.stayName} • ${b.destination}', style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: AppTheme.mutedPhosphor, size: 13),
                    const SizedBox(width: 4),
                    Text(b.dates, style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11.5)),
                  ],
                ),
              ],
            ),
          ),

          // Pricing Box
          Container(
            padding: const EdgeInsets.all(12),
            color: AppTheme.midnightObsidian,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Group Split', style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11)),
                        Text(
                          '\$${b.pricePerPerson.toStringAsFixed(0)} / person',
                          style: const TextStyle(
                            color: AppTheme.cyberEmerald,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${b.confirmedMembers.length} / ${b.totalSpots} spots claimed',
                          style: const TextStyle(color: AppTheme.ghostIce, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${b.spotsRemaining} spots left',
                          style: TextStyle(
                            color: b.spotsRemaining <= 2 ? AppTheme.crimsonPulse : AppTheme.solarAmber,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: b.fillPercentage,
                    backgroundColor: AppTheme.slateCard,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      b.spotsRemaining <= 2 ? AppTheme.crimsonPulse : AppTheme.cyberEmerald,
                    ),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),

          // Claim Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: b.hasUserBooked ? AppTheme.slateCard : AppTheme.vapourIon,
                  foregroundColor: b.hasUserBooked ? AppTheme.cyberEmerald : AppTheme.midnightObsidian,
                  side: BorderSide(color: b.hasUserBooked ? AppTheme.cyberEmerald : Colors.transparent),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  GroupBookingCheckoutSheet.show(context, b, b.communityId);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(b.hasUserBooked ? Icons.check_circle_rounded : Icons.lock_clock_rounded, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      b.hasUserBooked ? 'Spot Reserved (View / Manage)' : 'Claim Your Spot (\$${b.pricePerPerson.toStringAsFixed(0)})',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 4: TRIP CO-PLANNER
  // ==========================================
  Widget _buildTripPlannerSection() {
    return ListenableBuilder(
      key: const ValueKey('section_trip_planner'),
      listenable: communityRepo,
      builder: (context, _) {
        final allTrips = communityRepo.allTripPlans;

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trip Co-Planner',
                        style: TextStyle(
                          color: AppTheme.ghostIce,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      Text(
                        'Collaborative itineraries, day stops & member voting',
                        style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.solarAmber,
                    foregroundColor: AppTheme.midnightObsidian,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final defaultComm = communityRepo.communities.first;
                    PlanTripModalSheet.show(context, defaultComm.id, defaultComm.destinationFocus);
                  },
                  icon: const Icon(Icons.edit_calendar_rounded, size: 15),
                  label: const Text('New Plan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (allTrips.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('No collaborative trip plans active.', style: TextStyle(color: AppTheme.mutedPhosphor)),
                ),
              )
            else
              ...allTrips.map((trip) => _buildTripPlanCard(trip)),
          ],
        );
      },
    );
  }

  Widget _buildTripPlanCard(CommunityTripPlan trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.frameBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.solarAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trip.status,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.solarAmber,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      'Target: \$${trip.targetBudget.toStringAsFixed(0)}/person',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.cyberEmerald,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  trip.title,
                  style: const TextStyle(
                    color: AppTheme.ghostIce,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${trip.destination} • ${trip.dates}',
                  style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                ),
              ],
            ),
          ),

          // Itinerary Preview
          Container(
            padding: const EdgeInsets.all(12),
            color: AppTheme.midnightObsidian,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ITINERARY STOPS',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.vapourIon,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                ...trip.days.expand((d) => d.activities).take(3).map((act) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Text(
                          act.time,
                          style: const TextStyle(fontFamily: 'monospace', color: AppTheme.solarAmber, fontSize: 10),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            act.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppTheme.ghostIce, fontSize: 12),
                          ),
                        ),
                        Text(
                          '${act.votes} votes',
                          style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 10.5),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Poll preview if any
          if (trip.polls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.how_to_vote_rounded, size: 14, color: AppTheme.solarAmber),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Live Poll: ${trip.polls.first.question}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.ghostIce, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...trip.polls.first.options.map((opt) {
                    final total = trip.polls.first.totalVotes;
                    final pct = total > 0 ? (opt.voteCount / total) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        onTap: () {
                          communityRepo.voteOnPoll(
                            communityId: trip.communityId,
                            tripPlanId: trip.id,
                            pollId: trip.polls.first.id,
                            optionId: opt.id,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: opt.isUserVoted ? AppTheme.vapourIon.withValues(alpha: 0.15) : AppTheme.midnightObsidian,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: opt.isUserVoted ? AppTheme.vapourIon : AppTheme.frameBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  opt.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: AppTheme.ghostIce, fontSize: 11.5),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(pct * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(fontFamily: 'monospace', color: AppTheme.solarAmber, fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

          // Open Community Button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.ghostIce,
                  side: const BorderSide(color: AppTheme.frameBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommunityDetailPage(communityId: trip.communityId),
                    ),
                  );
                },
                child: const Text('Open in Community Hub', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
