import 'package:flutter/material.dart';
import 'travel_booking.dart';

/// Represents a public or semi-private travel community/club.
class CommunityGroup {
  final String id;
  final String name;
  final String tagline;
  final String category; // 'Adventure', 'Nomads', 'Culture', 'Luxury', 'Solo'
  final String destinationFocus;
  final int memberCount;
  final String badgeText;
  final List<Color> bannerGradient;
  final List<String> tags;
  final List<String> rules;
  final String emoji;
  final bool isJoined;
  final List<CommunityGroupBooking> groupBookings;
  final List<CommunityTripPlan> tripPlans;
  final List<CommunityPost> posts;

  const CommunityGroup({
    required this.id,
    required this.name,
    required this.tagline,
    required this.category,
    required this.destinationFocus,
    required this.memberCount,
    required this.badgeText,
    required this.bannerGradient,
    required this.tags,
    required this.rules,
    required this.emoji,
    this.isJoined = false,
    this.groupBookings = const [],
    this.tripPlans = const [],
    this.posts = const [],
  });

  CommunityGroup copyWith({
    bool? isJoined,
    int? memberCount,
    List<CommunityGroupBooking>? groupBookings,
    List<CommunityTripPlan>? tripPlans,
    List<CommunityPost>? posts,
  }) {
    return CommunityGroup(
      id: id,
      name: name,
      tagline: tagline,
      category: category,
      destinationFocus: destinationFocus,
      memberCount: memberCount ?? this.memberCount,
      badgeText: badgeText,
      bannerGradient: bannerGradient,
      tags: tags,
      rules: rules,
      emoji: emoji,
      isJoined: isJoined ?? this.isJoined,
      groupBookings: groupBookings ?? this.groupBookings,
      tripPlans: tripPlans ?? this.tripPlans,
      posts: posts ?? this.posts,
    );
  }
}

/// Represents a collaborative group booking pool (e.g. Villa takeover, Chalet block, Yacht charter)
class CommunityGroupBooking {
  final String id;
  final String communityId;
  final String communityName;
  final String title;
  final String stayName;
  final String destination;
  final String dates;
  final double totalPrice;
  final double pricePerPerson;
  final int totalSpots;
  final List<String> confirmedMembers;
  final double depositRequired;
  final List<String> amenities;
  final String status; // 'OPEN', 'FILLING FAST', 'LOCKED'
  final String organizerName;
  final String bookingRef;
  final bool hasUserBooked;

  const CommunityGroupBooking({
    required this.id,
    required this.communityId,
    required this.communityName,
    required this.title,
    required this.stayName,
    required this.destination,
    required this.dates,
    required this.totalPrice,
    required this.pricePerPerson,
    required this.totalSpots,
    required this.confirmedMembers,
    required this.depositRequired,
    required this.amenities,
    this.status = 'OPEN',
    required this.organizerName,
    required this.bookingRef,
    this.hasUserBooked = false,
  });

  int get spotsRemaining => totalSpots - confirmedMembers.length;
  double get fillPercentage => totalSpots > 0 ? (confirmedMembers.length / totalSpots).clamp(0.0, 1.0) : 0.0;

  CommunityGroupBooking copyWith({
    List<String>? confirmedMembers,
    String? status,
    bool? hasUserBooked,
  }) {
    return CommunityGroupBooking(
      id: id,
      communityId: communityId,
      communityName: communityName,
      title: title,
      stayName: stayName,
      destination: destination,
      dates: dates,
      totalPrice: totalPrice,
      pricePerPerson: pricePerPerson,
      totalSpots: totalSpots,
      confirmedMembers: confirmedMembers ?? this.confirmedMembers,
      depositRequired: depositRequired,
      amenities: amenities,
      status: status ?? this.status,
      organizerName: organizerName,
      bookingRef: bookingRef,
      hasUserBooked: hasUserBooked ?? this.hasUserBooked,
    );
  }
}

/// Collaborative trip proposal created within a community
class CommunityTripPlan {
  final String id;
  final String communityId;
  final String title;
  final String destination;
  final String dates;
  final String organizer;
  final double targetBudget;
  final List<String> participants;
  final List<TripItineraryDay> days;
  final List<TripPoll> polls;
  final String status; // 'CO-PLANNING', 'POLL ACTIVE', 'CONFIRMED'
  final bool isUserJoined;

  const CommunityTripPlan({
    required this.id,
    required this.communityId,
    required this.title,
    required this.destination,
    required this.dates,
    required this.organizer,
    required this.targetBudget,
    required this.participants,
    required this.days,
    required this.polls,
    this.status = 'CO-PLANNING',
    this.isUserJoined = false,
  });

  CommunityTripPlan copyWith({
    List<String>? participants,
    List<TripItineraryDay>? days,
    List<TripPoll>? polls,
    String? status,
    bool? isUserJoined,
  }) {
    return CommunityTripPlan(
      id: id,
      communityId: communityId,
      title: title,
      destination: destination,
      dates: dates,
      organizer: organizer,
      targetBudget: targetBudget,
      participants: participants ?? this.participants,
      days: days ?? this.days,
      polls: polls ?? this.polls,
      status: status ?? this.status,
      isUserJoined: isUserJoined ?? this.isUserJoined,
    );
  }
}

class TripItineraryDay {
  final int dayNumber;
  final String dayTitle;
  final List<TripActivityItem> activities;

  const TripItineraryDay({
    required this.dayNumber,
    required this.dayTitle,
    required this.activities,
  });

  TripItineraryDay copyWith({
    List<TripActivityItem>? activities,
  }) {
    return TripItineraryDay(
      dayNumber: dayNumber,
      dayTitle: dayTitle,
      activities: activities ?? this.activities,
    );
  }
}

class TripActivityItem {
  final String id;
  final String time;
  final String title;
  final String location;
  final double estimatedCost;
  final int votes;
  final bool hasVoted;

  const TripActivityItem({
    required this.id,
    required this.time,
    required this.title,
    required this.location,
    required this.estimatedCost,
    this.votes = 0,
    this.hasVoted = false,
  });

  TripActivityItem copyWith({
    int? votes,
    bool? hasVoted,
  }) {
    return TripActivityItem(
      id: id,
      time: time,
      title: title,
      location: location,
      estimatedCost: estimatedCost,
      votes: votes ?? this.votes,
      hasVoted: hasVoted ?? this.hasVoted,
    );
  }
}

class TripPoll {
  final String id;
  final String question;
  final List<TripPollOption> options;
  final String author;
  final bool isOpen;

  const TripPoll({
    required this.id,
    required this.question,
    required this.options,
    required this.author,
    this.isOpen = true,
  });

  int get totalVotes => options.fold(0, (sum, opt) => sum + opt.voteCount);

  TripPoll copyWith({
    List<TripPollOption>? options,
    bool? isOpen,
  }) {
    return TripPoll(
      id: id,
      question: question,
      options: options ?? this.options,
      author: author,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}

class TripPollOption {
  final String id;
  final String text;
  final int voteCount;
  final bool isUserVoted;

  const TripPollOption({
    required this.id,
    required this.text,
    this.voteCount = 0,
    this.isUserVoted = false,
  });

  TripPollOption copyWith({
    int? voteCount,
    bool? isUserVoted,
  }) {
    return TripPollOption(
      id: id,
      text: text,
      voteCount: voteCount ?? this.voteCount,
      isUserVoted: isUserVoted ?? this.isUserVoted,
    );
  }
}

class CommunityPost {
  final String id;
  final String authorName;
  final String authorTag;
  final String timeAgo;
  final String content;
  final int likeCount;
  final bool isLiked;
  final int replyCount;
  final Color avatarColor;

  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorTag,
    required this.timeAgo,
    required this.content,
    this.likeCount = 0,
    this.isLiked = false,
    this.replyCount = 0,
    required this.avatarColor,
  });

  CommunityPost copyWith({
    int? likeCount,
    bool? isLiked,
    int? replyCount,
  }) {
    return CommunityPost(
      id: id,
      authorName: authorName,
      authorTag: authorTag,
      timeAgo: timeAgo,
      content: content,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      replyCount: replyCount ?? this.replyCount,
      avatarColor: avatarColor,
    );
  }
}

/// Global repository and state manager for Social Communities
class SocialCommunityRepository with ChangeNotifier {
  static final SocialCommunityRepository instance = SocialCommunityRepository._internal();

  SocialCommunityRepository._internal() {
    _initSampleData();
  }

  final List<CommunityGroup> _communities = [];

  List<CommunityGroup> get communities => List.unmodifiable(_communities);

  List<CommunityGroupBooking> get allGroupBookings {
    final list = <CommunityGroupBooking>[];
    for (final c in _communities) {
      list.addAll(c.groupBookings);
    }
    return list;
  }

  List<CommunityTripPlan> get allTripPlans {
    final list = <CommunityTripPlan>[];
    for (final c in _communities) {
      list.addAll(c.tripPlans);
    }
    return list;
  }

  void _initSampleData() {
    _communities.clear();

    // 1. Tokyo Midnight & Street Culture
    _communities.add(
      CommunityGroup(
        id: 'comm-tokyo',
        name: 'Tokyo Midnight & Street Culture',
        tagline: 'Hidden alleyways, cyberpunk vistas, and rooftop izakaya hops.',
        category: 'Culture',
        destinationFocus: 'Tokyo & Kyoto, Japan 🇯🇵',
        memberCount: 2840,
        badgeText: 'VERIFIED GUILD',
        emoji: '🏮',
        bannerGradient: const [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
        tags: ['Nightlife', 'Izakaya', 'Photography', 'Group Stays'],
        rules: [
          'Be respectful of local traditions and neighborhood noise levels.',
          'Group stays require confirmation 7 days prior to check-in.',
          'Share real insider spots and culinary gems.'
        ],
        isJoined: true,
        groupBookings: [
          const CommunityGroupBooking(
            id: 'gb-tokyo-1',
            communityId: 'comm-tokyo',
            communityName: 'Tokyo Midnight & Street Culture',
            title: 'Shibuya Sky Penthouse & Tatami Suites Takeover',
            stayName: 'Cerulean Panoramic Suites Shibuya',
            destination: 'Shibuya, Tokyo',
            dates: 'Nov 12 – Nov 17, 2026 (5 nights)',
            totalPrice: 4200.0,
            pricePerPerson: 700.0,
            totalSpots: 6,
            confirmedMembers: ['Alex Mercer (You)', 'Kenji Sato', 'Elena Rostova', 'Marcus Wu'],
            depositRequired: 150.0,
            amenities: ['Panoramic Tokyo View', 'Private Tatami Lounge', 'High-Speed Wi-Fi', 'Daily Espresso Bar'],
            status: 'FILLING FAST',
            organizerName: 'Kenji Sato',
            bookingRef: '#GB-TKY-8921',
            hasUserBooked: true,
          ),
          const CommunityGroupBooking(
            id: 'gb-tokyo-2',
            communityId: 'comm-tokyo',
            communityName: 'Tokyo Midnight & Street Culture',
            title: 'Kyoto Machiya Traditional Villa Retreat',
            stayName: 'Gion Heritage Machiya Residence',
            destination: 'Gion, Kyoto',
            dates: 'Nov 18 – Nov 22, 2026 (4 nights)',
            totalPrice: 3200.0,
            pricePerPerson: 400.0,
            totalSpots: 8,
            confirmedMembers: ['Sofia M.', 'Chloe B.', 'Jordan H.'],
            depositRequired: 100.0,
            amenities: ['Private Zen Garden', 'Cedar Hinoki Tub', 'Tea Master Experience', 'Luggage Courier'],
            status: 'OPEN',
            organizerName: 'Elena Rostova',
            bookingRef: '#GB-KYT-4309',
            hasUserBooked: false,
          ),
        ],
        tripPlans: [
          CommunityTripPlan(
            id: 'tp-tokyo-1',
            communityId: 'comm-tokyo',
            title: 'Autumn Neon & Temple Expedition \'26',
            destination: 'Tokyo & Kyoto',
            dates: 'Nov 12 – Nov 22, 2026',
            organizer: 'Kenji Sato',
            targetBudget: 1850.0,
            participants: ['Alex Mercer (You)', 'Kenji Sato', 'Elena Rostova', 'Marcus Wu', 'Sofia M.'],
            status: 'CO-PLANNING',
            isUserJoined: true,
            days: const [
              TripItineraryDay(
                dayNumber: 1,
                dayTitle: 'Arrival & Shinjuku Neon Walk',
                activities: [
                  TripActivityItem(
                    id: 'act-1',
                    time: '04:00 PM',
                    title: 'Check-in at Shibuya Suites',
                    location: 'Shibuya Station East Exit',
                    estimatedCost: 0.0,
                    votes: 4,
                    hasVoted: true,
                  ),
                  TripActivityItem(
                    id: 'act-2',
                    time: '07:30 PM',
                    title: 'Omoide Yokocho Yakitori Crawl',
                    location: 'Shinjuku Memory Lane',
                    estimatedCost: 35.0,
                    votes: 5,
                    hasVoted: true,
                  ),
                ],
              ),
              TripItineraryDay(
                dayNumber: 2,
                dayTitle: 'Akihabara Tech & Senso-ji Sunset',
                activities: [
                  TripActivityItem(
                    id: 'act-3',
                    time: '10:00 AM',
                    title: 'Vintage Retro Gaming & Audio Quest',
                    location: 'Akihabara Electric Town',
                    estimatedCost: 20.0,
                    votes: 3,
                    hasVoted: false,
                  ),
                  TripActivityItem(
                    id: 'act-4',
                    time: '05:00 PM',
                    title: 'Golden Hour Lantern Walk at Senso-ji',
                    location: 'Asakusa',
                    estimatedCost: 0.0,
                    votes: 6,
                    hasVoted: true,
                  ),
                ],
              ),
            ],
            polls: const [
              TripPoll(
                id: 'poll-1',
                question: 'Which Ramen institution for our group dinner on Day 3?',
                author: 'Kenji Sato',
                options: [
                  TripPollOption(id: 'opt-1', text: 'Afuri Yuzu Shio Ramen (Ebisu)', voteCount: 5, isUserVoted: true),
                  TripPollOption(id: 'opt-2', text: 'Ichiran Shibuya No-Talking Booths', voteCount: 2, isUserVoted: false),
                  TripPollOption(id: 'opt-3', text: 'Fuunji Tsukemen (Shinjuku)', voteCount: 4, isUserVoted: false),
                ],
              ),
            ],
          ),
        ],
        posts: const [
          CommunityPost(
            id: 'post-tky-1',
            authorName: 'Kenji Sato',
            authorTag: 'Host • Tokyo Lead',
            timeAgo: '2h ago',
            content: 'Just locked in the Shibuya Penthouse! We have 2 spots left if anyone wants in on the split rate (\$700 for 5 nights with epic Tokyo skyline views). Hit the Group Booking tab to claim your spot!',
            likeCount: 24,
            isLiked: true,
            replyCount: 8,
            avatarColor: Color(0xFF5686F5),
          ),
          CommunityPost(
            id: 'post-tky-2',
            authorName: 'Maya Lin',
            authorTag: 'Member',
            timeAgo: '5h ago',
            content: 'Pro tip for anyone taking the Shinkansen down to Kyoto with large luggage: remember to reserve the oversized baggage seat in advance via SmartEX app!',
            likeCount: 15,
            isLiked: false,
            replyCount: 3,
            avatarColor: Color(0xFF00E699),
          ),
        ],
      ),
    );

    // 2. Bali Nomads & Villa Collective
    _communities.add(
      CommunityGroup(
        id: 'comm-bali',
        name: 'Bali Nomads & Villa Collective',
        tagline: 'Co-working sunrises, surf squads, and shared jungle compound takeovers.',
        category: 'Nomads',
        destinationFocus: 'Canggu & Ubud, Bali 🌴',
        memberCount: 4120,
        badgeText: 'HOT SPOT',
        emoji: '🌴',
        bannerGradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
        tags: ['Co-Working', 'Surf', 'Villa Takeovers', 'Vegan Food'],
        rules: [
          'High speed wifi is a non-negotiable requirement for all booked compounds.',
          'Respect quiet hours after 11 PM in co-living spaces.',
          'Help each other with local scooter and visa tips.'
        ],
        isJoined: false,
        groupBookings: [
          const CommunityGroupBooking(
            id: 'gb-bali-1',
            communityId: 'comm-bali',
            communityName: 'Bali Nomads & Villa Collective',
            title: 'Canggu 6-Bedroom Infinity Jungle Villa',
            stayName: 'Villa Cempaka Sanctuary Canggu',
            destination: 'Canggu, Bali',
            dates: 'Dec 01 – Dec 08, 2026 (7 nights)',
            totalPrice: 2800.0,
            pricePerPerson: 350.0,
            totalSpots: 8,
            confirmedMembers: ['Alex Rivera', 'Tara Gomez', 'Samira Khan', 'Liam Hayes', 'Liam Channing'],
            depositRequired: 80.0,
            amenities: ['1 Gbps Fiber Wi-Fi', 'Private 18m Pool', 'Daily Maid & Breakfast', 'Scooter Parking'],
            status: 'OPEN',
            organizerName: 'Alex Rivera',
            bookingRef: '#GB-DPS-1092',
            hasUserBooked: false,
          ),
        ],
        tripPlans: [
          CommunityTripPlan(
            id: 'tp-bali-1',
            communityId: 'comm-bali',
            title: 'Canggu Surf & Digital Sprint Week',
            destination: 'Canggu & Uluwatu',
            dates: 'Dec 01 – Dec 08, 2026',
            organizer: 'Alex Rivera',
            targetBudget: 650.0,
            participants: ['Alex Rivera', 'Tara Gomez', 'Samira Khan', 'Liam Hayes'],
            status: 'OPEN FOR JOINING',
            isUserJoined: false,
            days: const [
              TripItineraryDay(
                dayNumber: 1,
                dayTitle: 'Arrival & Sunset Bintang at Echo Beach',
                activities: [
                  TripActivityItem(
                    id: 'act-b1',
                    time: '05:00 PM',
                    title: 'Sunset Session & Surf Check',
                    location: 'Echo Beach, Canggu',
                    estimatedCost: 10.0,
                    votes: 3,
                    hasVoted: false,
                  ),
                ],
              ),
            ],
            polls: const [
              TripPoll(
                id: 'poll-b1',
                question: 'Should we hire a private chef for daily breakfast at the villa?',
                author: 'Alex Rivera',
                options: [
                  TripPollOption(id: 'opt-b1', text: 'Yes, \$8/day per person for smoothie bowls & eggs', voteCount: 6, isUserVoted: false),
                  TripPollOption(id: 'opt-b2', text: 'No, let\'s explore Canggu cafes', voteCount: 2, isUserVoted: false),
                ],
              ),
            ],
          ),
        ],
        posts: const [
          CommunityPost(
            id: 'post-bali-1',
            authorName: 'Alex Rivera',
            authorTag: 'Host',
            timeAgo: '1d ago',
            content: '3 spots open for our Dec 1-8 Canggu Villa takeover! Direct pool access from all rooms and fiber internet tested at 450Mbps. Come join the crew.',
            likeCount: 31,
            isLiked: false,
            replyCount: 12,
            avatarColor: Color(0xFF00E699),
          ),
        ],
      ),
    );

    // 3. Swiss Alpine Summit Seekers
    _communities.add(
      CommunityGroup(
        id: 'comm-swiss',
        name: 'Swiss Alpine Summit Seekers',
        tagline: 'High-altitude ridges, glacier expeditions, and fondue firesides.',
        category: 'Adventure',
        destinationFocus: 'Grindelwald & Zermatt, Switzerland 🇨🇭',
        memberCount: 1980,
        badgeText: 'ALPINE EXPERTS',
        emoji: '🏔️',
        bannerGradient: const [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
        tags: ['Trekking', 'Skiing', 'Chalets', 'Mountain Passes'],
        rules: [
          'Safety gear (avalanche beepers / crampons) mandatory for red/black trails.',
          'Pack in, pack out. Leave no trace in the Alps.',
        ],
        isJoined: false,
        groupBookings: [
          const CommunityGroupBooking(
            id: 'gb-swiss-1',
            communityId: 'comm-swiss',
            communityName: 'Swiss Alpine Summit Seekers',
            title: 'Grindelwald Luxury Chalet with Mountain View Sauna',
            stayName: 'Chalet Eiger Panorama Lodge',
            destination: 'Grindelwald, Switzerland',
            dates: 'Jan 15 – Jan 21, 2027 (6 nights)',
            totalPrice: 5400.0,
            pricePerPerson: 900.0,
            totalSpots: 6,
            confirmedMembers: ['Maya Chen', 'Felix Weber', 'Jonas Becker'],
            depositRequired: 250.0,
            amenities: ['Eiger North Face View', 'Finnish Sauna & Hot Tub', 'Ski-in Ski-out Access', 'Fireplace'],
            status: 'OPEN',
            organizerName: 'Maya Chen',
            bookingRef: '#GB-SWI-9920',
            hasUserBooked: false,
          ),
        ],
        tripPlans: [
          CommunityTripPlan(
            id: 'tp-swiss-1',
            communityId: 'comm-swiss',
            title: 'First Cliff Walk & Glacier Trek 2027',
            destination: 'Jungfrau Region',
            dates: 'Jan 15 – Jan 21, 2027',
            organizer: 'Maya Chen',
            targetBudget: 2200.0,
            participants: ['Maya Chen', 'Felix Weber', 'Jonas Becker'],
            status: 'CO-PLANNING',
            isUserJoined: false,
            days: const [
              TripItineraryDay(
                dayNumber: 1,
                dayTitle: 'Chalet Check-in & Gear Tuning',
                activities: [
                  TripActivityItem(
                    id: 'act-s1',
                    time: '03:00 PM',
                    title: 'Ski Pass Pick-up & Equipment Fitting',
                    location: 'Grindelwald Terminal',
                    estimatedCost: 75.0,
                    votes: 3,
                    hasVoted: false,
                  ),
                ],
              ),
            ],
            polls: const [
              TripPoll(
                id: 'poll-s1',
                question: 'Should we do a group day trip to Jungfraujoch Top of Europe?',
                author: 'Maya Chen',
                options: [
                  TripPollOption(id: 'opt-s1', text: 'Yes, full morning train ticket', voteCount: 4, isUserVoted: false),
                  TripPollOption(id: 'opt-s2', text: 'Skip it and ski First/Männlichen instead', voteCount: 2, isUserVoted: false),
                ],
              ),
            ],
          ),
        ],
        posts: const [
          CommunityPost(
            id: 'post-swiss-1',
            authorName: 'Maya Chen',
            authorTag: 'Expedition Guide',
            timeAgo: '3h ago',
            content: 'The first snowfall dusted the Eiger ridge this morning! Booking for the January chalet is halfway full.',
            likeCount: 42,
            isLiked: false,
            replyCount: 6,
            avatarColor: Color(0xFFF5A623),
          ),
        ],
      ),
    );

    // 4. Nordic Aurora & Ice Hunters
    _communities.add(
      CommunityGroup(
        id: 'comm-nordic',
        name: 'Nordic Aurora & Ice Hunters',
        tagline: 'Chasing the Green Lady, geothermal lagoons, and glacier snowmobiles.',
        category: 'Adventure',
        destinationFocus: 'Reykjavik & Tromsø 🌌',
        memberCount: 2310,
        badgeText: 'AURORA RADAR',
        emoji: '🌌',
        bannerGradient: const [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        tags: ['Northern Lights', 'Geothermal', 'Ice Caves', 'Roadtrip'],
        rules: [
          'Aurora forecasts are monitored daily using Kp index telemetry.',
          'Studded 4x4 vehicles only for gravel ring road segments.'
        ],
        isJoined: false,
        groupBookings: [
          const CommunityGroupBooking(
            id: 'gb-ice-1',
            communityId: 'comm-nordic',
            communityName: 'Nordic Aurora & Ice Hunters',
            title: 'Glass Igloo & Geothermal Lodge Compound',
            stayName: 'Aurora Glass Cabins & Geothermal Spa',
            destination: 'Selfoss & Golden Circle, Iceland',
            dates: 'Dec 18 – Dec 24, 2026 (6 nights)',
            totalPrice: 4800.0,
            pricePerPerson: 800.0,
            totalSpots: 6,
            confirmedMembers: ['Liam Channing', 'Astrid Nygard', 'Soren Berg'],
            depositRequired: 200.0,
            amenities: ['Glass Ceiling Aurora View', 'Outdoor Geothermal Hot Tub', '4x4 Superjeep Included', 'Thermal Parkas'],
            status: 'OPEN',
            organizerName: 'Liam Channing',
            bookingRef: '#GB-KEF-7741',
            hasUserBooked: false,
          ),
        ],
        tripPlans: [
          CommunityTripPlan(
            id: 'tp-nordic-1',
            communityId: 'comm-nordic',
            title: 'South Coast Ice Caves & Aurora Hunt',
            destination: 'South Iceland',
            dates: 'Dec 18 – Dec 24, 2026',
            organizer: 'Liam Channing',
            targetBudget: 1950.0,
            participants: ['Liam Channing', 'Astrid Nygard', 'Soren Berg'],
            status: 'OPEN FOR JOINING',
            isUserJoined: false,
            days: const [
              TripItineraryDay(
                dayNumber: 1,
                dayTitle: 'Blue Lagoon & Night Aurora Watch',
                activities: [
                  TripActivityItem(
                    id: 'act-n1',
                    time: '06:00 PM',
                    title: 'Evening Geothermal Soak',
                    location: 'Blue Lagoon, Grindavík',
                    estimatedCost: 90.0,
                    votes: 5,
                    hasVoted: false,
                  ),
                ],
              ),
            ],
            polls: const [
              TripPoll(
                id: 'poll-n1',
                question: 'Do we want to book the Katla Crystal Ice Cave Superjeep Tour?',
                author: 'Liam Channing',
                options: [
                  TripPollOption(id: 'opt-n1', text: 'Yes, must do! (\$180/person)', voteCount: 4, isUserVoted: false),
                  TripPollOption(id: 'opt-n2', text: 'Prefer glacier hiking on Solheimajokull', voteCount: 1, isUserVoted: false),
                ],
              ),
            ],
          ),
        ],
        posts: const [
          CommunityPost(
            id: 'post-ice-1',
            authorName: 'Liam Channing',
            authorTag: 'Aurora Chaser',
            timeAgo: '6h ago',
            content: 'Solar cycle 25 is peaking right now! The Kp index has been hitting 5-6 regularly. December trip will have insane geomagnetic storm potential.',
            likeCount: 38,
            isLiked: false,
            replyCount: 9,
            avatarColor: Color(0xFFB066FF),
          ),
        ],
      ),
    );
  }

  // --- ACTIONS ---

  void toggleJoinCommunity(String communityId) {
    final index = _communities.indexWhere((c) => c.id == communityId);
    if (index == -1) return;

    final comm = _communities[index];
    final willJoin = !comm.isJoined;
    _communities[index] = comm.copyWith(
      isJoined: willJoin,
      memberCount: willJoin ? comm.memberCount + 1 : comm.memberCount - 1,
    );
    notifyListeners();
  }

  /// Claim / Book a spot in a group booking
  bool bookSpotInGroupBooking({
    required String communityId,
    required String bookingId,
    required String userName,
    required String userEmail,
    required String userPhone,
    String? specialRequests,
  }) {
    final commIndex = _communities.indexWhere((c) => c.id == communityId);
    if (commIndex == -1) return false;

    final comm = _communities[commIndex];
    final gbIndex = comm.groupBookings.indexWhere((b) => b.id == bookingId);
    if (gbIndex == -1) return false;

    final booking = comm.groupBookings[gbIndex];
    if (booking.confirmedMembers.length >= booking.totalSpots && !booking.hasUserBooked) {
      return false; // Full
    }

    final updatedMembers = List<String>.from(booking.confirmedMembers);
    bool isNowBooked;

    if (booking.hasUserBooked) {
      // Leave booking
      updatedMembers.removeWhere((m) => m.contains(userName) || m.contains('(You)'));
      isNowBooked = false;
    } else {
      // Join booking
      updatedMembers.add('$userName (You)');
      isNowBooked = true;

      // Sync into TravelBookingsManager.instance!
      final confirmedBooking = TravelBooking(
        id: 'bk-grp-${DateTime.now().millisecondsSinceEpoch}',
        destinationTitle: booking.destination,
        hotelName: booking.stayName,
        roomType: 'Reserved Group Suite / Private Room',
        dates: booking.dates,
        bookingRef: booking.bookingRef,
        totalPrice: '\$${booking.totalPrice.toStringAsFixed(0)} (Your Share: \$${booking.pricePerPerson.toStringAsFixed(0)})',
        status: 'CONFIRMED',
        statusColor: const Color(0xFF00E699),
        guestName: userName,
        guestPassport: 'P${DateTime.now().millisecondsSinceEpoch % 100000000}',
        guestNationality: 'Verified Member',
        guestEmail: userEmail,
        guestPhone: userPhone,
        specialRequests: specialRequests ?? 'Community Group Booking via Aperture Social',
        createdAt: DateTime.now(),
        guestCount: booking.totalSpots,
        isGroupTrip: true,
        groupMembers: updatedMembers,
        perPersonPrice: '\$${booking.pricePerPerson.toStringAsFixed(0)} / person',
      );

      TravelBookingsManager.instance.addBooking(confirmedBooking);
    }

    final updatedGb = booking.copyWith(
      confirmedMembers: updatedMembers,
      hasUserBooked: isNowBooked,
      status: updatedMembers.length >= booking.totalSpots ? 'LOCKED' : (updatedMembers.length >= (booking.totalSpots * 0.7) ? 'FILLING FAST' : 'OPEN'),
    );

    final updatedGroupBookings = List<CommunityGroupBooking>.from(comm.groupBookings);
    updatedGroupBookings[gbIndex] = updatedGb;

    _communities[commIndex] = comm.copyWith(groupBookings: updatedGroupBookings);
    notifyListeners();
    return true;
  }

  /// Create a new collaborative group booking in a community
  void createGroupBooking({
    required String communityId,
    required String title,
    required String stayName,
    required String destination,
    required String dates,
    required double totalPrice,
    required int totalSpots,
    required double depositRequired,
    required List<String> amenities,
  }) {
    final commIndex = _communities.indexWhere((c) => c.id == communityId);
    if (commIndex == -1) return;

    final comm = _communities[commIndex];
    final pricePerPerson = totalPrice / (totalSpots > 0 ? totalSpots : 1);
    final ref = '#GB-${destination.substring(0, 3).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch % 10000}';

    final newBooking = CommunityGroupBooking(
      id: 'gb-custom-${DateTime.now().millisecondsSinceEpoch}',
      communityId: communityId,
      communityName: comm.name,
      title: title,
      stayName: stayName,
      destination: destination,
      dates: dates,
      totalPrice: totalPrice,
      pricePerPerson: pricePerPerson,
      totalSpots: totalSpots,
      confirmedMembers: ['You (Organizer)'],
      depositRequired: depositRequired,
      amenities: amenities,
      status: 'OPEN',
      organizerName: 'You',
      bookingRef: ref,
      hasUserBooked: true,
    );

    final updatedList = List<CommunityGroupBooking>.from(comm.groupBookings)..insert(0, newBooking);
    _communities[commIndex] = comm.copyWith(groupBookings: updatedList);
    notifyListeners();
  }

  /// Vote on a trip poll
  void voteOnPoll({
    required String communityId,
    required String tripPlanId,
    required String pollId,
    required String optionId,
  }) {
    final commIndex = _communities.indexWhere((c) => c.id == communityId);
    if (commIndex == -1) return;

    final comm = _communities[commIndex];
    final tripIndex = comm.tripPlans.indexWhere((t) => t.id == tripPlanId);
    if (tripIndex == -1) return;

    final trip = comm.tripPlans[tripIndex];
    final pollIndex = trip.polls.indexWhere((p) => p.id == pollId);
    if (pollIndex == -1) return;

    final poll = trip.polls[pollIndex];
    final updatedOptions = poll.options.map((opt) {
      if (opt.id == optionId) {
        return opt.copyWith(
          voteCount: opt.isUserVoted ? opt.voteCount - 1 : opt.voteCount + 1,
          isUserVoted: !opt.isUserVoted,
        );
      } else if (opt.isUserVoted) {
        return opt.copyWith(
          voteCount: opt.voteCount - 1,
          isUserVoted: false,
        );
      }
      return opt;
    }).toList();

    final updatedPoll = poll.copyWith(options: updatedOptions);
    final updatedPolls = List<TripPoll>.from(trip.polls);
    updatedPolls[pollIndex] = updatedPoll;

    final updatedTrip = trip.copyWith(polls: updatedPolls);
    final updatedTrips = List<CommunityTripPlan>.from(comm.tripPlans);
    updatedTrips[tripIndex] = updatedTrip;

    _communities[commIndex] = comm.copyWith(tripPlans: updatedTrips);
    notifyListeners();
  }

  /// Add an activity to a day in a trip plan
  void addTripActivity({
    required String communityId,
    required String tripPlanId,
    required int dayNumber,
    required String time,
    required String title,
    required String location,
    required double estimatedCost,
  }) {
    final commIndex = _communities.indexWhere((c) => c.id == communityId);
    if (commIndex == -1) return;

    final comm = _communities[commIndex];
    final tripIndex = comm.tripPlans.indexWhere((t) => t.id == tripPlanId);
    if (tripIndex == -1) return;

    final trip = comm.tripPlans[tripIndex];
    final dayIndex = trip.days.indexWhere((d) => d.dayNumber == dayNumber);
    if (dayIndex == -1) return;

    final day = trip.days[dayIndex];
    final newActivity = TripActivityItem(
      id: 'act-${DateTime.now().millisecondsSinceEpoch}',
      time: time,
      title: title,
      location: location,
      estimatedCost: estimatedCost,
      votes: 1,
      hasVoted: true,
    );

    final updatedActivities = List<TripActivityItem>.from(day.activities)..add(newActivity);
    final updatedDay = day.copyWith(activities: updatedActivities);
    final updatedDays = List<TripItineraryDay>.from(trip.days);
    updatedDays[dayIndex] = updatedDay;

    final updatedTrip = trip.copyWith(days: updatedDays);
    final updatedTrips = List<CommunityTripPlan>.from(comm.tripPlans);
    updatedTrips[tripIndex] = updatedTrip;

    _communities[commIndex] = comm.copyWith(tripPlans: updatedTrips);
    notifyListeners();
  }

  /// Create a new collaborative trip plan in a community
  void createTripPlan({
    required String communityId,
    required String title,
    required String destination,
    required String dates,
    required double targetBudget,
    required String firstActivityTitle,
    required String firstActivityLocation,
    required String pollQuestion,
    required List<String> pollOptions,
  }) {
    final commIndex = _communities.indexWhere((c) => c.id == communityId);
    if (commIndex == -1) return;

    final comm = _communities[commIndex];

    final initialDay = TripItineraryDay(
      dayNumber: 1,
      dayTitle: 'Day 1: Arrival & Group Kickoff',
      activities: [
        TripActivityItem(
          id: 'act-init-1',
          time: '04:00 PM',
          title: firstActivityTitle.isNotEmpty ? firstActivityTitle : 'Check-in & Welcome Drink',
          location: firstActivityLocation.isNotEmpty ? firstActivityLocation : destination,
          estimatedCost: 25.0,
          votes: 1,
          hasVoted: true,
        ),
      ],
    );

    final initialPoll = TripPoll(
      id: 'poll-init-${DateTime.now().millisecondsSinceEpoch}',
      question: pollQuestion.isNotEmpty ? pollQuestion : 'What group activity should we prioritize?',
      author: 'You',
      options: pollOptions.isNotEmpty
          ? pollOptions.map((text) => TripPollOption(
              id: 'opt-${text.hashCode}',
              text: text,
              voteCount: 1,
              isUserVoted: false,
            )).toList()
          : const [
              TripPollOption(id: 'opt-d1', text: 'Sunset Cruise / Boat Tour', voteCount: 2),
              TripPollOption(id: 'opt-d2', text: 'Food & Night Market Walking Tour', voteCount: 3),
              TripPollOption(id: 'opt-d3', text: 'Private Chef Dinner in Villa', voteCount: 1),
            ],
    );

    final newTrip = CommunityTripPlan(
      id: 'tp-custom-${DateTime.now().millisecondsSinceEpoch}',
      communityId: communityId,
      title: title,
      destination: destination,
      dates: dates,
      organizer: 'You',
      targetBudget: targetBudget,
      participants: ['You (Organizer)'],
      days: [initialDay],
      polls: [initialPoll],
      status: 'CO-PLANNING',
      isUserJoined: true,
    );

    final updatedTrips = List<CommunityTripPlan>.from(comm.tripPlans)..insert(0, newTrip);
    _communities[commIndex] = comm.copyWith(tripPlans: updatedTrips);
    notifyListeners();
  }

  /// Post a message or question in community lounge
  void postCommunityMessage({
    required String communityId,
    required String content,
  }) {
    final commIndex = _communities.indexWhere((c) => c.id == communityId);
    if (commIndex == -1) return;

    final comm = _communities[commIndex];
    final newPost = CommunityPost(
      id: 'post-${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'Alex Mercer',
      authorTag: 'Member (You)',
      timeAgo: 'Just now',
      content: content,
      likeCount: 1,
      isLiked: true,
      replyCount: 0,
      avatarColor: const Color(0xFF5686F5),
    );

    final updatedPosts = List<CommunityPost>.from(comm.posts)..insert(0, newPost);
    _communities[commIndex] = comm.copyWith(posts: updatedPosts);
    notifyListeners();
  }
}
