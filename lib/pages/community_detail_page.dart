import 'package:flutter/material.dart';
import '../models/social_community.dart';
import '../theme/app_theme.dart';
import '../widgets/group_booking_sheets.dart';

class CommunityDetailPage extends StatefulWidget {
  final String communityId;

  const CommunityDetailPage({
    super.key,
    required this.communityId,
  });

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _loungePostController = TextEditingController();
  final repo = SocialCommunityRepository.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loungePostController.dispose();
    super.dispose();
  }

  void _showAddActivityDialog(String tripPlanId, int dayNumber) {
    final titleController = TextEditingController();
    final locController = TextEditingController();
    final timeController = TextEditingController(text: '02:00 PM');
    final costController = TextEditingController(text: '20');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
          color: AppTheme.cinemaSlate,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: AppTheme.vapourIon, width: 1.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Activity to Day Itinerary',
              style: TextStyle(color: AppTheme.ghostIce, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Activity Name',
                filled: true,
                fillColor: AppTheme.midnightObsidian,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: locController,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Location / Landmark',
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: timeController,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Time Slot',
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: costController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Estimated Cost Per Person (\$)',
                filled: true,
                fillColor: AppTheme.midnightObsidian,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.vapourIon,
                  foregroundColor: AppTheme.midnightObsidian,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isNotEmpty) {
                    repo.addTripActivity(
                      communityId: widget.communityId,
                      tripPlanId: tripPlanId,
                      dayNumber: dayNumber,
                      time: timeController.text.trim(),
                      title: title,
                      location: locController.text.trim(),
                      estimatedCost: double.tryParse(costController.text.trim()) ?? 0.0,
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add to Itinerary', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final community = repo.communities.firstWhere(
          (c) => c.id == widget.communityId,
          orElse: () => repo.communities.first,
        );

        return Scaffold(
          backgroundColor: AppTheme.midnightObsidian,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildSliverHeader(community),
                SliverToBoxAdapter(
                  child: _buildCommunityQuickBar(community),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppTheme.vapourIon,
                      indicatorWeight: 3,
                      labelColor: AppTheme.ghostIce,
                      unselectedLabelColor: AppTheme.mutedPhosphor,
                      labelStyle: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                      tabs: [
                        Tab(text: 'TRIPS (${community.tripPlans.length})'),
                        Tab(text: 'BOOKINGS (${community.groupBookings.length})'),
                        Tab(text: 'POLLS'),
                        Tab(text: 'LOUNGE (${community.posts.length})'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildTripsTab(community),
                _buildGroupBookingsTab(community),
                _buildPollsTab(community),
                _buildLoungeTab(community),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverHeader(CommunityGroup c) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppTheme.cinemaSlate,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.ghostIce, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            c.isJoined ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
            color: c.isJoined ? AppTheme.solarAmber : AppTheme.mutedPhosphor,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppTheme.cinemaSlate,
                content: Text(c.isJoined ? 'Community notifications active.' : 'Join community to enable trip alerts.'),
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    c.bannerGradient.first.withValues(alpha: 0.85),
                    c.bannerGradient.last.withValues(alpha: 0.95),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Subtle Grid/Texture overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    AppTheme.midnightObsidian.withValues(alpha: 0.92),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Header Content
            Positioned(
              bottom: 16,
              left: 18,
              right: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          c.badgeText,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.solarAmber,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${c.memberCount} members',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.ghostIce,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.tagline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.ghostIce.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityQuickBar(CommunityGroup c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.cinemaSlate,
        border: Border(bottom: BorderSide(color: AppTheme.frameBorder, width: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags Row
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: c.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.midnightObsidian,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.frameBorder),
                ),
                child: Text(
                  '#$tag',
                  style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 10.5),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Action Buttons: Join Community, Plan a Trip, Propose Group Booking
          Row(
            children: [
              // Join / Leave Button
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.isJoined ? AppTheme.slateCard : AppTheme.vapourIon,
                    foregroundColor: c.isJoined ? AppTheme.ghostIce : AppTheme.midnightObsidian,
                    side: BorderSide(
                      color: c.isJoined ? AppTheme.frameBorder : Colors.transparent,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    repo.toggleJoinCommunity(c.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.cinemaSlate,
                        content: Text(
                          c.isJoined ? 'Left ${c.name}' : 'Joined ${c.name}! Welcome to the guild.',
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    c.isJoined ? Icons.check_circle_outline_rounded : Icons.group_add_rounded,
                    size: 16,
                    color: c.isJoined ? AppTheme.cyberEmerald : AppTheme.midnightObsidian,
                  ),
                  label: Text(
                    c.isJoined ? 'Joined Club' : 'Join Guild',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Plan Trip Button
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.solarAmber,
                    foregroundColor: AppTheme.midnightObsidian,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    PlanTripModalSheet.show(context, c.id, c.destinationFocus);
                  },
                  icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                  label: const Text(
                    'Plan Trip',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Propose Group Booking Button
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.midnightObsidian,
                  side: const BorderSide(color: AppTheme.frameBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_home_work_rounded, color: AppTheme.cyberEmerald, size: 18),
                tooltip: 'Launch Group Booking Pool',
                onPressed: () {
                  CreateGroupBookingSheet.show(context, c.id, c.destinationFocus);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 1: TRIPS & EXPEDITIONS ---
  Widget _buildTripsTab(CommunityGroup c) {
    if (c.tripPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore_off_rounded, color: AppTheme.mutedPhosphor, size: 40),
            const SizedBox(height: 10),
            const Text(
              'No active group trips yet.',
              style: TextStyle(color: AppTheme.ghostIce, fontSize: 14),
            ),
            const SizedBox(height: 6),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.solarAmber),
              onPressed: () => PlanTripModalSheet.show(context, c.id, c.destinationFocus),
              child: const Text('Be First to Plan a Trip', style: TextStyle(color: AppTheme.midnightObsidian)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: c.tripPlans.length,
      itemBuilder: (context, index) {
        final trip = c.tripPlans[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.frameBorder),
          ),
          child: Material(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.circular(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Trip Header
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
                            color: AppTheme.solarAmber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            trip.status,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: AppTheme.solarAmber,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '\$${trip.targetBudget.toStringAsFixed(0)} target budget',
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
                    Row(
                      children: [
                        const Icon(Icons.date_range_rounded, color: AppTheme.mutedPhosphor, size: 14),
                        const SizedBox(width: 4),
                        Text(trip.dates, style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12)),
                        const SizedBox(width: 12),
                        const Icon(Icons.person_rounded, color: AppTheme.mutedPhosphor, size: 14),
                        const SizedBox(width: 4),
                        Text('Lead: ${trip.organizer}', style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Participants
                    Row(
                      children: [
                        const Text('Joined: ', style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11)),
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            children: trip.participants.map((p) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.midnightObsidian,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.frameBorder),
                                ),
                                child: Text(p, style: const TextStyle(color: AppTheme.ghostIce, fontSize: 10)),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: AppTheme.frameBorder, height: 1),

              // Itinerary Days
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: const Text(
                    'Collaborative Day-by-Day Itinerary',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.vapourIon,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  children: [
                    ...trip.days.map((day) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.midnightObsidian,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  day.dayTitle,
                                  style: const TextStyle(
                                    color: AppTheme.ghostIce,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _showAddActivityDialog(trip.id, day.dayNumber),
                                  icon: const Icon(Icons.add, size: 14, color: AppTheme.vapourIon),
                                  label: const Text('Add Stop', style: TextStyle(fontSize: 11, color: AppTheme.vapourIon)),
                                ),
                              ],
                            ),
                            ...day.activities.map((act) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      act.time,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        color: AppTheme.solarAmber,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            act.title,
                                            style: const TextStyle(
                                              color: AppTheme.ghostIce,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${act.location} • \$${act.estimatedCost.toStringAsFixed(0)}/person',
                                            style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.slateCard,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.thumb_up_alt_outlined, size: 11, color: AppTheme.cyberEmerald),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${act.votes}',
                                            style: const TextStyle(color: AppTheme.cyberEmerald, fontSize: 11, fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
    );
  }

  // --- TAB 2: GROUP BOOKINGS ---
  Widget _buildGroupBookingsTab(CommunityGroup c) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Top Banner for Proposing Booking
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.vapourIon.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.vapourIon.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home_work_rounded, color: AppTheme.vapourIon, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Takeover a Villa or Chalet',
                      style: TextStyle(color: AppTheme.ghostIce, fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Lock down private properties & split wholesale group rates.',
                      style: TextStyle(color: AppTheme.mutedPhosphor.withValues(alpha: 0.8), fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.vapourIon,
                  foregroundColor: AppTheme.midnightObsidian,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  CreateGroupBookingSheet.show(context, c.id, c.destinationFocus);
                },
                child: const Text('Propose', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (c.groupBookings.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Text(
                'No group bookings currently active in this community.',
                style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 13),
              ),
            ),
          )
        else
          ...c.groupBookings.map((b) => _buildGroupBookingCard(c, b)),
      ],
    );
  }

  Widget _buildGroupBookingCard(CommunityGroup c, CommunityGroupBooking b) {
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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: b.status == 'FILLING FAST'
                            ? AppTheme.crimsonPulse.withValues(alpha: 0.2)
                            : AppTheme.cyberEmerald.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        b.status,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: b.status == 'FILLING FAST' ? AppTheme.crimsonPulse : AppTheme.cyberEmerald,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
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
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${b.stayName} • ${b.destination}',
                  style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                ),
              ],
            ),
          ),

          // Pricing & Capacity Bar
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
                        const Text('Rate per person', style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11)),
                        Text(
                          '\$${b.pricePerPerson.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppTheme.cyberEmerald,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${b.confirmedMembers.length} / ${b.totalSpots} spots filled',
                          style: const TextStyle(color: AppTheme.ghostIce, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${b.spotsRemaining} spots remaining',
                          style: const TextStyle(color: AppTheme.solarAmber, fontSize: 11),
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

          // Amenities & Action
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: b.amenities.take(3).map((a) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.slateCard,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(a, style: const TextStyle(color: AppTheme.ghostIce, fontSize: 10.5)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: b.hasUserBooked ? AppTheme.slateCard : AppTheme.vapourIon,
                      foregroundColor: b.hasUserBooked ? AppTheme.cyberEmerald : AppTheme.midnightObsidian,
                      side: BorderSide(
                        color: b.hasUserBooked ? AppTheme.cyberEmerald : Colors.transparent,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      GroupBookingCheckoutSheet.show(context, b, c.id);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          b.hasUserBooked ? Icons.check_circle_rounded : Icons.lock_clock_rounded,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          b.hasUserBooked ? 'You Claimed a Spot (Manage)' : 'Claim Your Spot (\$${b.pricePerPerson.toStringAsFixed(0)})',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: POLLS ---
  Widget _buildPollsTab(CommunityGroup c) {
    final allPolls = <Map<String, dynamic>>[];
    for (final trip in c.tripPlans) {
      for (final poll in trip.polls) {
        allPolls.add({'trip': trip, 'poll': poll});
      }
    }

    if (allPolls.isEmpty) {
      return const Center(
        child: Text('No active voting polls.', style: TextStyle(color: AppTheme.mutedPhosphor)),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: allPolls.length,
      itemBuilder: (context, index) {
        final item = allPolls[index];
        final trip = item['trip'] as CommunityTripPlan;
        final poll = item['poll'] as TripPoll;
        final totalVotes = poll.totalVotes;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.frameBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.vapourIon.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      trip.title,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.vapourIon,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '$totalVotes votes',
                    style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                poll.question,
                style: const TextStyle(
                  color: AppTheme.ghostIce,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),

              // Options
              ...poll.options.map((opt) {
                final pct = totalVotes > 0 ? (opt.voteCount / totalVotes) : 0.0;
                final isVoted = opt.isUserVoted;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      repo.voteOnPoll(
                        communityId: c.id,
                        tripPlanId: trip.id,
                        pollId: poll.id,
                        optionId: opt.id,
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isVoted ? AppTheme.vapourIon.withValues(alpha: 0.15) : AppTheme.midnightObsidian,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isVoted ? AppTheme.vapourIon : AppTheme.frameBorder,
                          width: isVoted ? 1.4 : 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  opt.text,
                                  style: TextStyle(
                                    color: isVoted ? AppTheme.ghostIce : AppTheme.mutedPhosphor,
                                    fontSize: 13,
                                    fontWeight: isVoted ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '${(pct * 100).toStringAsFixed(0)}% (${opt.voteCount})',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: isVoted ? AppTheme.solarAmber : AppTheme.mutedPhosphor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: AppTheme.slateCard,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isVoted ? AppTheme.vapourIon : AppTheme.mutedPhosphor.withValues(alpha: 0.5),
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 4: LOUNGE & CHAT ---
  Widget _buildLoungeTab(CommunityGroup c) {
    return Column(
      children: [
        // Posts Feed
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: c.posts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final post = c.posts[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cinemaSlate,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.frameBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: post.avatarColor,
                          child: Text(
                            post.authorName[0],
                            style: const TextStyle(
                              color: AppTheme.midnightObsidian,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.authorName,
                                style: const TextStyle(
                                  color: AppTheme.ghostIce,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${post.authorTag} • ${post.timeAgo}',
                                style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      post.content,
                      style: const TextStyle(
                        color: AppTheme.ghostIce,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.favorite_rounded, color: AppTheme.crimsonPulse, size: 14),
                        const SizedBox(width: 4),
                        Text('${post.likeCount}', style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11)),
                        const SizedBox(width: 16),
                        const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.mutedPhosphor, size: 14),
                        const SizedBox(width: 4),
                        Text('${post.replyCount} replies', style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Text composer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: AppTheme.cinemaSlate,
            border: Border(top: BorderSide(color: AppTheme.frameBorder)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _loungePostController,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Share a trip question or tip with the community...',
                      hintStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppTheme.vapourIon),
                  onPressed: () {
                    final text = _loungePostController.text.trim();
                    if (text.isNotEmpty) {
                      repo.postCommunityMessage(
                        communityId: c.id,
                        content: text,
                      );
                      _loungePostController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.midnightObsidian,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
