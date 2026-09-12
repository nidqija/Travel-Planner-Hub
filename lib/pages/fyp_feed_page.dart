import 'package:flutter/material.dart';
import '../models/group_chat.dart';
import '../models/travel_booking.dart';
import '../models/video_item.dart';
import '../theme/app_theme.dart';
import '../widgets/viewfinder_frame.dart';
import '../widgets/video_canvas_view.dart';
import '../widgets/action_rail.dart';
import '../widgets/comments_sheet.dart';
import '../widgets/openclaw_agent_widget.dart';
import '../widgets/nearby_hotels_sheet.dart';
import '../widgets/save_to_collection_sheet.dart';
import 'budget_planner_page.dart';
import 'ideation_page.dart';
import 'saved_collections_page.dart';
import 'social_home_page.dart';

class FypFeedPage extends StatefulWidget {
  const FypFeedPage({super.key});

  @override
  State<FypFeedPage> createState() => _FypFeedPageState();
}

class _FypFeedPageState extends State<FypFeedPage> {
  late PageController _pageController;
  late List<VideoItem> _videos;
  int _currentIndex = 0;
  bool _isPlaying = true;
  String _selectedCategory = 'For You';

  final List<String> _categories = [
    'For You',
    'Ideation',
    'Chats',
    'Saved',
    'Bookings',
    'Budget',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _videos = VideoItem.getSampleFeed();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String category) {
    if (category == 'Ideation') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IdeationPage(
            onSwitchToFyp: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (category == 'Chats') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SocialHomePage(),
        ),
      );
      return;
    }
    if (category == 'Saved') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SavedCollectionsPage(),
        ),
      );
      return;
    }
    if (category == 'Bookings') {
      _showBookingsSheet();
      return;
    }
    if (category == 'Budget') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BudgetPlannerPage(allVideos: _videos),
        ),
      );
      return;
    }

    setState(() {
      _selectedCategory = category;
      _videos = VideoItem.getSampleFeed();
      _currentIndex = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.cinemaSlate,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppTheme.vapourIon, width: 1),
        ),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppTheme.solarAmber, size: 16),
            const SizedBox(width: 8),
            Text(
              'FYP channel: $category activated',
              style: const TextStyle(
                fontFamily: 'monospace',
                color: AppTheme.ghostIce,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.80,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            final manager = TravelBookingsManager.instance;
            return ListenableBuilder(
              listenable: manager,
              builder: (context, _) {
                final bookings = manager.bookings;
                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cinemaSlate,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(color: AppTheme.vapourIon, width: 1.2),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.mutedPhosphor.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.confirmation_number_rounded, color: AppTheme.solarAmber, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'MY TRAVEL BOOKINGS',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: AppTheme.ghostIce,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppTheme.mutedPhosphor),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${bookings.length} active ${bookings.length == 1 ? "itinerary" : "itineraries"} confirmed via OpenClaw AI Concierge',
                        style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: bookings.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.hotel_rounded, size: 48, color: AppTheme.mutedPhosphor.withValues(alpha: 0.5)),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'No confirmed bookings yet',
                                      style: TextStyle(color: AppTheme.ghostIce, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Ask OpenClaw AI to reserve your dream stay',
                                      style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: bookings.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 14),
                                itemBuilder: (context, i) {
                                  final b = bookings[i];
                                  return _buildBookingCard(
                                    destinationTitle: b.destinationTitle,
                                    hotelName: b.hotelName,
                                    roomType: b.roomType,
                                    dates: b.dates,
                                    bookingRef: b.bookingRef,
                                    totalPrice: b.totalPrice,
                                    status: b.status,
                                    statusColor: b.statusColor,
                                    guestName: b.guestName,
                                    guestCount: b.guestCount,
                                    isGroupTrip: b.isGroupTrip,
                                    groupMembers: b.groupMembers,
                                    perPersonPrice: b.perPersonPrice,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBookingCard({
    required String destinationTitle,
    required String hotelName,
    required String roomType,
    required String dates,
    required String bookingRef,
    required String totalPrice,
    required String status,
    required Color statusColor,
    String? guestName,
    int? guestCount,
    bool isGroupTrip = false,
    List<String> groupMembers = const [],
    String? perPersonPrice,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.slateCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.frameBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        destinationTitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.solarAmber,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isGroupTrip) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppTheme.solarAmber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.solarAmber.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.groups_rounded, color: AppTheme.solarAmber, size: 10),
                            const SizedBox(width: 3),
                            Text(
                              'GROUP (${guestCount ?? 2})',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: AppTheme.solarAmber,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: statusColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hotelName,
            style: const TextStyle(
              color: AppTheme.ghostIce,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            roomType,
            style: const TextStyle(
              color: AppTheme.mutedPhosphor,
              fontSize: 12,
            ),
          ),
          if (guestName != null && guestName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  isGroupTrip ? Icons.groups_outlined : Icons.person_outline_rounded,
                  color: AppTheme.vapourIon,
                  size: 13,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    isGroupTrip ? 'Lead: $guestName' : 'Guest: $guestName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.ghostIce,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (isGroupTrip && groupMembers.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 5,
              runSpacing: 4,
              children: groupMembers.map((member) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.midnightObsidian,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppTheme.frameBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person, color: AppTheme.mutedPhosphor, size: 10),
                      const SizedBox(width: 3),
                      Text(
                        member,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.ghostIce,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.date_range_rounded, color: AppTheme.vapourIon, size: 14),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  dates,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.ghostIce,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Ref: $bookingRef',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: AppTheme.mutedPhosphor,
                  fontSize: 11,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total: $totalPrice',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.solarAmber,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isGroupTrip && perPersonPrice != null)
                    Text(
                      perPersonPrice,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.cyberEmerald,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
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

  void _showShareToSquadSheet(VideoItem video) {
    final repo = GroupChatRepository.instance;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppTheme.solarAmber, width: 1.5)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(Icons.group_add_rounded, color: AppTheme.solarAmber, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Share Reel to Travel Squad',
                    style: TextStyle(
                      color: AppTheme.ghostIce,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Send "${video.indexLabel}: ${video.title}" to squad chat:',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.mutedPhosphor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              ...repo.chats.map((chat) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: chat.memberAvatarColors.first,
                    child: Text(
                      chat.title[0],
                      style: const TextStyle(
                        color: AppTheme.midnightObsidian,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  title: Text(
                    chat.title,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    chat.destinationTag,
                    style: const TextStyle(fontFamily: 'monospace', color: AppTheme.solarAmber, fontSize: 10),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.solarAmber,
                      foregroundColor: AppTheme.midnightObsidian,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: const Size(60, 32),
                    ),
                    onPressed: () {
                      repo.shareVideoToChat(
                        chat.id,
                        video,
                        comment: 'Check out this travel reel for our upcoming trip! 🎬✨',
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.cinemaSlate,
                          content: Text('Reel shared with ${chat.title}!'),
                        ),
                      );
                    },
                    child: const Text('Send', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _shareVideo(VideoItem video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: AppTheme.frameBorder)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Share "${video.title}"',
                style: const TextStyle(
                  color: AppTheme.ghostIce,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${video.indexLabel} • ${(video.algorithmMatchScore * 100).toStringAsFixed(1)}% match',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: AppTheme.mutedPhosphor,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(Icons.link_rounded, 'Copy Link'),
                  _buildShareOption(Icons.send_rounded, 'Direct'),
                  _buildShareOption(Icons.download_rounded, 'Save MP4'),
                  _buildShareOption(Icons.qr_code_rounded, 'Vector QR'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption(IconData icon, String label) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.cinemaSlate,
            content: Text('Selected: $label', style: const TextStyle(color: AppTheme.ghostIce)),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.midnightObsidian,
              border: Border.all(color: AppTheme.frameBorder),
            ),
            child: Icon(icon, color: AppTheme.vapourIon, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.midnightObsidian,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: Brand & Channel Selector Tabs (fits cleanly above the mobile viewfinder frame)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 4),
              child: _buildTopHeader(),
            ),

            // Vertical Snapping Video Feed (Mobile Viewfinder Frame)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: _videos.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _isPlaying = true;
                  });
                },
                itemBuilder: (context, index) {
                  final video = _videos[index];
                  final isCurrent = index == _currentIndex;

                  return ViewfinderFrame(
                    video: video,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Video Motion Graphics Canvas
                        VideoCanvasView(
                          video: video,
                          isPlaying: isCurrent && _isPlaying,
                          onTogglePlay: () {
                            setState(() {
                              _isPlaying = !_isPlaying;
                            });
                          },
                          onDoubleTapLike: () {
                            setState(() {
                              if (!video.isLiked) {
                                video.isLiked = true;
                                video.likes += 1;
                              }
                            });
                          },
                        ),

                        // Bottom Metadata Overlay (Creator, Destination Tag, Title, Description, Audio)
                        Positioned(
                          left: 14,
                          right: 70,
                          bottom: 18,
                          child: _buildBottomMetadata(video),
                        ),

                        // Right-Side Action Rail
                        Positioned(
                          right: 10,
                          bottom: 18,
                          child: ActionRail(
                            video: video,
                            onLikeToggled: () {
                              setState(() {
                                video.isLiked = !video.isLiked;
                                video.likes += video.isLiked ? 1 : -1;
                              });
                            },
                            onSaveToggled: () {
                              SaveToCollectionSheet.show(context, video: video);
                            },
                            onOpenComments: () {
                              CommentsSheet.show(context, video);
                            },
                            onShare: () {
                              _shareVideo(video);
                            },
                            onShareToSquad: () {
                              _showShareToSquadSheet(video);
                            },
                          ),
                        ),

                        // OpenClaw AI Travel Agent Floating Companion
                        // Positioned strictly inside the mobile viewfinder frame above bottom metadata
                        Positioned(
                          left: 12,
                          right: 70,
                          bottom: 188,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: OpenClawAgentWidget(
                              key: ValueKey('openclaw-agent-${video.id}'),
                              destination: video.destination,
                              isNewVideo: isCurrent,
                              onTap: () {
                                NearbyHotelsSheet.show(
                                  context,
                                  destination: video.destination,
                                  onOpenBookings: _showBookingsSheet,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand Glyph
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.midnightObsidian.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: AppTheme.vapourIon.withValues(alpha: 0.6)),
              ),
              child: const Icon(
                Icons.camera_rounded,
                color: AppTheme.vapourIon,
                size: 13,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'APERTURE',
              style: TextStyle(
                fontFamily: 'monospace',
                color: AppTheme.ghostIce,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),

        // Category Selector Tabs
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: AppTheme.midnightObsidian.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.frameBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _categories.map((cat) {
                    final isSelected = cat == _selectedCategory;
                    return GestureDetector(
                      onTap: () => _onCategorySelected(cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.vapourIon : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: isSelected ? AppTheme.midnightObsidian : AppTheme.mutedPhosphor,
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Search / Discover
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Search & Explore catalog'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppTheme.midnightObsidian.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.frameBorder),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: AppTheme.ghostIce,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomMetadata(VideoItem video) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Creator Handle and Follow Pill
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                video.creatorHandle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.ghostIce,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.solarAmber.withValues(alpha: 0.8)),
              ),
              child: const Text(
                'FOLLOW',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: AppTheme.solarAmber,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),

        // Destination Badge and Quick Save Pill (Wrapped to prevent right overflow)
        Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Location destination badge
            GestureDetector(
              onTap: () {
                NearbyHotelsSheet.show(
                  context,
                  destination: video.destination,
                  onOpenBookings: _showBookingsSheet,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.midnightObsidian.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.frameBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(video.destination.flagEmoji, style: const TextStyle(fontSize: 10)),
                    const SizedBox(width: 4),
                    Text(
                      video.destination.cityCountry.split(',').first,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.ghostIce,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Save Destination to Collection
            GestureDetector(
              onTap: () {
                SaveToCollectionSheet.show(context, video: video);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.midnightObsidian.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.solarAmber.withValues(alpha: 0.7)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_add_rounded, color: AppTheme.solarAmber, size: 10),
                    SizedBox(width: 3),
                    Text(
                      'SAVE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.solarAmber,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),

        // Video Title
        Text(
          video.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.ghostIce,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 3),

        // Description
        Text(
          video.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppTheme.ghostIce.withValues(alpha: 0.85),
            fontSize: 11.5,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),

        // Tags
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: video.tags
              .take(3)
              .map(
                (tag) => Text(
                  tag,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.vapourIon,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),

        // Audio Pill with waveform icon
        Container(
          constraints: const BoxConstraints(maxWidth: 240),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
          decoration: BoxDecoration(
            color: AppTheme.midnightObsidian.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.frameBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.graphic_eq_rounded,
                color: AppTheme.solarAmber,
                size: 13,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  '${video.audioTitle} • ${video.audioArtist}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.ghostIce,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
