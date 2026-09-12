import 'package:flutter/material.dart';
import 'video_item.dart';

class BillSplitInfo {
  final String title;
  final double totalAmount;
  final String currency;
  final String paidBy;
  final int splitAmongCount;
  final double amountPerPerson;
  final List<String> participants;
  final bool isSettled;

  const BillSplitInfo({
    required this.title,
    required this.totalAmount,
    this.currency = 'USD',
    required this.paidBy,
    required this.splitAmongCount,
    required this.amountPerPerson,
    required this.participants,
    this.isSettled = false,
  });

  BillSplitInfo copyWith({bool? isSettled}) {
    return BillSplitInfo(
      title: title,
      totalAmount: totalAmount,
      currency: currency,
      paidBy: paidBy,
      splitAmongCount: splitAmongCount,
      amountPerPerson: amountPerPerson,
      participants: participants,
      isSettled: isSettled ?? this.isSettled,
    );
  }
}

class QrPaymentInfo {
  final String payeeName;
  final double amount;
  final String currency;
  final String referenceNote;
  final String qrPayload;
  final bool isPaid;

  const QrPaymentInfo({
    required this.payeeName,
    required this.amount,
    this.currency = 'USD',
    required this.referenceNote,
    required this.qrPayload,
    this.isPaid = false,
  });

  QrPaymentInfo copyWith({bool? isPaid}) {
    return QrPaymentInfo(
      payeeName: payeeName,
      amount: amount,
      currency: currency,
      referenceNote: referenceNote,
      qrPayload: qrPayload,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}

class GroupBookingLinkInfo {
  final String id;
  final String title;
  final String hotelOrStayName;
  final String destination;
  final String dates;
  final double pricePerPerson;
  final String currency;
  final int totalSpots;
  final List<String> bookedMembers;
  final List<String> allMembers;
  final String bookingRef;
  final String shareableUrl;
  final String createdBy;
  final DateTime createdAt;
  final bool isLocked;

  const GroupBookingLinkInfo({
    required this.id,
    required this.title,
    required this.hotelOrStayName,
    required this.destination,
    required this.dates,
    required this.pricePerPerson,
    this.currency = 'USD',
    required this.totalSpots,
    this.bookedMembers = const [],
    this.allMembers = const [],
    required this.bookingRef,
    required this.shareableUrl,
    required this.createdBy,
    required this.createdAt,
    this.isLocked = false,
  });

  bool get isFull => bookedMembers.length >= totalSpots;
  int get remainingSpots => (totalSpots - bookedMembers.length).clamp(0, totalSpots);
  bool isBookedBy(String name) => bookedMembers.contains(name);

  GroupBookingLinkInfo copyWith({
    String? id,
    String? title,
    String? hotelOrStayName,
    String? destination,
    String? dates,
    double? pricePerPerson,
    String? currency,
    int? totalSpots,
    List<String>? bookedMembers,
    List<String>? allMembers,
    String? bookingRef,
    String? shareableUrl,
    String? createdBy,
    DateTime? createdAt,
    bool? isLocked,
  }) {
    return GroupBookingLinkInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      hotelOrStayName: hotelOrStayName ?? this.hotelOrStayName,
      destination: destination ?? this.destination,
      dates: dates ?? this.dates,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      currency: currency ?? this.currency,
      totalSpots: totalSpots ?? this.totalSpots,
      bookedMembers: bookedMembers ?? this.bookedMembers,
      allMembers: allMembers ?? this.allMembers,
      bookingRef: bookingRef ?? this.bookingRef,
      shareableUrl: shareableUrl ?? this.shareableUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderName;
  final String senderHandle;
  final String? senderAvatar;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final String? sharedVideoId;
  final String? sharedVideoTitle;
  final String? sharedVideoCreator;
  final BillSplitInfo? billSplit;
  final QrPaymentInfo? qrPayment;
  final GroupBookingLinkInfo? groupBooking;

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.senderHandle,
    this.senderAvatar,
    required this.text,
    required this.timestamp,
    this.isMe = false,
    this.sharedVideoId,
    this.sharedVideoTitle,
    this.sharedVideoCreator,
    this.billSplit,
    this.qrPayment,
    this.groupBooking,
  });
}

class SquadAnnouncement {
  final String id;
  final String title;
  final String content;
  final String author;
  final String authorRole;
  final DateTime timestamp;
  final bool isPinned;
  final BillSplitInfo? billSplit;
  final QrPaymentInfo? qrPayment;
  final GroupBookingLinkInfo? groupBooking;
  final bool isEnquiryClosed;
  final String? closedBy;
  final DateTime? closedAt;

  const SquadAnnouncement({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    this.authorRole = 'Squad Member',
    required this.timestamp,
    this.isPinned = false,
    this.billSplit,
    this.qrPayment,
    this.groupBooking,
    this.isEnquiryClosed = false,
    this.closedBy,
    this.closedAt,
  });

  SquadAnnouncement copyWith({
    bool? isEnquiryClosed,
    String? closedBy,
    DateTime? closedAt,
    BillSplitInfo? billSplit,
    QrPaymentInfo? qrPayment,
    GroupBookingLinkInfo? groupBooking,
  }) {
    return SquadAnnouncement(
      id: id,
      title: title,
      content: content,
      author: author,
      authorRole: authorRole,
      timestamp: timestamp,
      isPinned: isPinned,
      billSplit: billSplit ?? this.billSplit,
      qrPayment: qrPayment ?? this.qrPayment,
      groupBooking: groupBooking ?? this.groupBooking,
      isEnquiryClosed: isEnquiryClosed ?? this.isEnquiryClosed,
      closedBy: closedBy ?? this.closedBy,
      closedAt: closedAt ?? this.closedAt,
    );
  }
}

class GroupChat {
  final String id;
  final String title;
  final String destination;
  final String destinationTag;
  final List<String> memberNames;
  final List<Color> memberAvatarColors;
  final String lastMessage;
  final String lastMessageSender;
  final String lastMessageTime;
  final int unreadCount;
  final String? pinnedItinerary;
  final String? sharedReelTitle;
  final bool isTyping;
  final String? typingUser;
  final List<ChatMessage> messages;
  final List<SquadAnnouncement> announcements;

  GroupChat({
    required this.id,
    required this.title,
    required this.destination,
    required this.destinationTag,
    required this.memberNames,
    required this.memberAvatarColors,
    required this.lastMessage,
    required this.lastMessageSender,
    required this.lastMessageTime,
    required this.unreadCount,
    this.pinnedItinerary,
    this.sharedReelTitle,
    this.isTyping = false,
    this.typingUser,
    required this.messages,
    this.announcements = const [],
  });
}

class TravelSquadStory {
  final String id;
  final String name;
  final String destination;
  final String status;
  final Color ringColor;
  final String emoji;

  const TravelSquadStory({
    required this.id,
    required this.name,
    required this.destination,
    required this.status,
    required this.ringColor,
    required this.emoji,
  });
}

class GroupChatRepository with ChangeNotifier {
  static final GroupChatRepository instance = GroupChatRepository._internal();
  GroupChatRepository._internal() {
    _initData();
  }

  late List<GroupChat> _chats;
  late List<TravelSquadStory> _stories;

  List<GroupChat> get chats => List.unmodifiable(_chats);
  List<TravelSquadStory> get stories => List.unmodifiable(_stories);

  void _initData() {
    _stories = const [
      TravelSquadStory(
        id: 's-1',
        name: 'Alex & Crew',
        destination: 'Bali, ID',
        status: 'Surfing Echo Beach 🌊',
        ringColor: Color(0xFF00E699),
        emoji: '🏄‍♂️',
      ),
      TravelSquadStory(
        id: 's-2',
        name: 'Elena Rostova',
        destination: 'Kyoto, JP',
        status: 'Bamboo Grove at Dawn 🎋',
        ringColor: Color(0xFF5686F5),
        emoji: '⛩️',
      ),
      TravelSquadStory(
        id: 's-3',
        name: 'Kenji & Maya',
        destination: 'Grindelwald, CH',
        status: 'First Cliff Walk 🏔️',
        ringColor: Color(0xFFF5A623),
        emoji: '❄️',
      ),
      TravelSquadStory(
        id: 's-4',
        name: 'Sofia Martinez',
        destination: 'Seoul, KR',
        status: 'Gwangjang Food Hunt 🥢',
        ringColor: Color(0xFFFF4757),
        emoji: '🍜',
      ),
      TravelSquadStory(
        id: 's-5',
        name: 'Liam Channing',
        destination: 'Reykjavik, IS',
        status: 'Aurora chasing tonight 🌌',
        ringColor: Color(0xFFB066FF),
        emoji: '✨',
      ),
    ];

    _chats = [
      GroupChat(
        id: 'chat-bali',
        title: 'Bali Tropical Nomads \'26',
        destination: 'Ubud & Canggu, Bali',
        destinationTag: 'BALI 🌴',
        memberNames: ['You', 'Alex Rivera', 'Maya Chen', 'Leo Vance'],
        memberAvatarColors: [
          const Color(0xFF5686F5),
          const Color(0xFF00E699),
          const Color(0xFFF5A623),
          const Color(0xFFFF4757),
        ],
        lastMessage: 'Alex: Split \$120.00 for Jimbaran Seafood BBQ',
        lastMessageSender: 'Alex Rivera',
        lastMessageTime: '12m ago',
        unreadCount: 3,
        pinnedItinerary: '5-Day Ubud Jungle Villa + Canggu Co-work (\$850 / pax)',
        sharedReelTitle: 'VIDEO 01 • Hyper-Dimensional Fluid Motion',
        isTyping: false,
        messages: [
          ChatMessage(
            id: 'm-1',
            senderName: 'Alex Rivera',
            senderHandle: '@alex.explores',
            text: 'Hey squad! The flight tickets to Denpasar just got discounted for August.',
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          ),
          ChatMessage(
            id: 'm-2',
            senderName: 'Leo Vance',
            senderHandle: '@leovance',
            text: 'Count me in! Are we staying around Ubud rice terraces or beachside Canggu?',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            id: 'm-3',
            senderName: 'Maya Chen',
            senderHandle: '@mayachen',
            text: 'I found an insane kinetic eco-resort on the FYP reel. Look at this:',
            timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
            sharedVideoId: 'vid-1',
            sharedVideoTitle: 'Hyper-Dimensional Fluid Motion (Bali Kinetic Stay)',
            sharedVideoCreator: '@aperture.motion',
          ),
          // Sample Bill Split message
          ChatMessage(
            id: 'm-split-1',
            senderName: 'Alex Rivera',
            senderHandle: '@alex.explores',
            text: 'I covered our seafood dinner deposit at Jimbaran Bay sunset lounge.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
            billSplit: const BillSplitInfo(
              title: 'Jimbaran Sunset Seafood BBQ',
              totalAmount: 120.00,
              currency: 'USD',
              paidBy: 'Alex Rivera',
              splitAmongCount: 4,
              amountPerPerson: 30.00,
              participants: ['You', 'Alex Rivera', 'Maya Chen', 'Leo Vance'],
              isSettled: false,
            ),
          ),
          // Sample QR Pay Request message
          ChatMessage(
            id: 'm-qr-1',
            senderName: 'Maya Chen',
            senderHandle: '@mayachen',
            text: 'Here is the QR code for the Nusa Penida speedboat pass if you haven\'t paid yet!',
            timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
            qrPayment: const QrPaymentInfo(
              payeeName: 'Maya Chen',
              amount: 25.00,
              currency: 'USD',
              referenceNote: 'Speedboat Nusa Penida',
              qrPayload: 'aperture://pay/maya.chen?amt=25.00&curr=USD&ref=NusaPenida',
              isPaid: false,
            ),
          ),
          ChatMessage(
            id: 'm-bk-1',
            senderName: 'Alex Rivera',
            senderHandle: '@alex.explores',
            text: '🔗 Group Booking Link created for Canggu Kinetic Eco-Resort! Each squad member books & pays their own spot individually (\$210.00 / person). 2 of 4 spots locked.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            groupBooking: GroupBookingLinkInfo(
              id: 'gbl-bali-1',
              title: 'Canggu Kinetic Eco-Resort Villa',
              hotelOrStayName: 'Canggu Kinetic Eco-Resort & Spa',
              destination: 'Ubud & Canggu, Bali 🌴',
              dates: 'Oct 15 – Oct 18, 2026 (3 nights)',
              pricePerPerson: 210.00,
              currency: 'USD',
              totalSpots: 4,
              bookedMembers: ['Alex Rivera', 'Maya Chen'],
              allMembers: ['Alex Rivera', 'Maya Chen', 'Leo Vance', 'You'],
              bookingRef: '#GRP-BALI-8841',
              shareableUrl: 'https://aperture.travel/grp/bali-8841',
              createdBy: 'Alex Rivera',
              createdAt: DateTime(2026, 10, 1),
            ),
          ),
        ],
        announcements: [
          SquadAnnouncement(
            id: 'ann-bali-bk-1',
            title: 'Group Booking: Canggu Kinetic Eco-Resort',
            content: 'Master squad reservation locked. Book your own spot individually using this link (\$210.00 / pax). 2 of 4 squad spots claimed.',
            author: 'Alex Rivera',
            authorRole: 'Trip Lead',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            groupBooking: GroupBookingLinkInfo(
              id: 'gbl-bali-1',
              title: 'Canggu Kinetic Eco-Resort Villa',
              hotelOrStayName: 'Canggu Kinetic Eco-Resort & Spa',
              destination: 'Ubud & Canggu, Bali 🌴',
              dates: 'Oct 15 – Oct 18, 2026 (3 nights)',
              pricePerPerson: 210.00,
              currency: 'USD',
              totalSpots: 4,
              bookedMembers: ['Alex Rivera', 'Maya Chen'],
              allMembers: ['Alex Rivera', 'Maya Chen', 'Leo Vance', 'You'],
              bookingRef: '#GRP-BALI-8841',
              shareableUrl: 'https://aperture.travel/grp/bali-8841',
              createdBy: 'Alex Rivera',
              createdAt: DateTime(2026, 10, 1),
            ),
            isEnquiryClosed: false,
          ),
          SquadAnnouncement(
            id: 'ann-bali-pin-1',
            title: 'Echo Beach Villa Keypad & Wi-Fi',
            content: 'Private gate security code: #8821 • High-speed Starlink Wi-Fi: CangguNomads26 (pass: sunsetvibes)',
            author: 'Alex Rivera',
            authorRole: 'Trip Lead',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isPinned: true,
            isEnquiryClosed: false,
          ),
          SquadAnnouncement(
            id: 'ann-bali-split-1',
            title: 'Jimbaran Sunset Seafood BBQ',
            content: 'Group dinner bill split. Total \$120.00 split among 4 squad members (\$30.00 / person).',
            author: 'Alex Rivera',
            authorRole: 'Treasurer',
            timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
            billSplit: const BillSplitInfo(
              title: 'Jimbaran Sunset Seafood BBQ',
              totalAmount: 120.00,
              currency: 'USD',
              paidBy: 'Alex Rivera',
              splitAmongCount: 4,
              amountPerPerson: 30.00,
              participants: ['You', 'Alex Rivera', 'Maya Chen', 'Leo Vance'],
              isSettled: false,
            ),
            isEnquiryClosed: false,
          ),
          SquadAnnouncement(
            id: 'ann-bali-qr-1',
            title: 'Speedboat Nusa Penida Transfer Passes',
            content: 'Scan Maya\'s QR code or DuitNow to settle the high-speed transfer ticket (\$25.00).',
            author: 'Maya Chen',
            authorRole: 'Navigator',
            timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
            qrPayment: const QrPaymentInfo(
              payeeName: 'Maya Chen',
              amount: 25.00,
              currency: 'USD',
              referenceNote: 'Speedboat Nusa Penida',
              qrPayload: 'aperture://pay/maya.chen?amt=25.00&curr=USD&ref=NusaPenida',
              isPaid: false,
            ),
            isEnquiryClosed: false,
          ),
          SquadAnnouncement(
            id: 'ann-bali-settled-1',
            title: 'Denpasar Airport Private Van Pickup',
            content: 'Airport transfer deposit for 4 passengers with surfboards luggage (\$45.00 total • \$11.25 / pax).',
            author: 'Leo Vance',
            authorRole: 'Explorer',
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
            billSplit: const BillSplitInfo(
              title: 'Airport Van Pickup',
              totalAmount: 45.00,
              currency: 'USD',
              paidBy: 'Leo Vance',
              splitAmongCount: 4,
              amountPerPerson: 11.25,
              participants: ['You', 'Alex Rivera', 'Maya Chen', 'Leo Vance'],
              isSettled: true,
            ),
            isEnquiryClosed: true,
            closedBy: 'You',
            closedAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      GroupChat(
        id: 'chat-tokyo',
        title: 'Tokyo Sakura Photographers',
        destination: 'Shibuya & Nakameguro, Tokyo',
        destinationTag: 'TOKYO 📸',
        memberNames: ['You', 'Ren Tanaka', 'Chloe Dubois', 'Sarah Lin', 'Marcus'],
        memberAvatarColors: [
          const Color(0xFF5686F5),
          const Color(0xFFB066FF),
          const Color(0xFFFF4757),
          const Color(0xFF00E699),
          const Color(0xFFF5A623),
        ],
        lastMessage: 'Ren: Split \$85.00 for Studio Gear Rental',
        lastMessageSender: 'Ren Tanaka',
        lastMessageTime: '34m ago',
        unreadCount: 5,
        pinnedItinerary: 'Night Photography Walk: Omoide Yokocho -> Shibuya Sky',
        sharedReelTitle: 'VIDEO 02 • Quantum Lattice Cyberpunk Tokyo',
        messages: [
          ChatMessage(
            id: 'tm-1',
            senderName: 'Sarah Lin',
            senderHandle: '@sarah_wander',
            text: 'Has anyone locked in their camera gear rentals for Tokyo?',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          ),
          ChatMessage(
            id: 'tm-2',
            senderName: 'Chloe Dubois',
            senderHandle: '@chloe.lens',
            text: 'Bringing two prime lenses (35mm & 85mm). We need to shoot Nakameguro canal illuminated lanterns.',
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          ),
          ChatMessage(
            id: 'tm-split-1',
            senderName: 'Ren Tanaka',
            senderHandle: '@ren_tanaka',
            text: 'Paid the group lighting kit & tripod rental deposit for Shibuya street shoots.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 34)),
            billSplit: const BillSplitInfo(
              title: 'Camera Gear & Lighting Rental',
              totalAmount: 85.00,
              currency: 'USD',
              paidBy: 'Ren Tanaka',
              splitAmongCount: 5,
              amountPerPerson: 17.00,
              participants: ['You', 'Ren Tanaka', 'Chloe Dubois', 'Sarah Lin', 'Marcus'],
              isSettled: false,
            ),
          ),
        ],
        announcements: [
          SquadAnnouncement(
            id: 'ann-tokyo-split-1',
            title: 'Camera Gear & Lighting Rental',
            content: 'Studio lighting kit & tripod rental deposit for Shibuya street shoots (\$85.00 total • \$17.00 / pax).',
            author: 'Ren Tanaka',
            authorRole: 'Lead Photographer',
            timestamp: DateTime.now().subtract(const Duration(minutes: 34)),
            billSplit: const BillSplitInfo(
              title: 'Camera Gear & Lighting Rental',
              totalAmount: 85.00,
              currency: 'USD',
              paidBy: 'Ren Tanaka',
              splitAmongCount: 5,
              amountPerPerson: 17.00,
              participants: ['You', 'Ren Tanaka', 'Chloe Dubois', 'Sarah Lin', 'Marcus'],
              isSettled: false,
            ),
            isEnquiryClosed: false,
          ),
          SquadAnnouncement(
            id: 'ann-tokyo-pin-1',
            title: 'Shibuya Sky Sunset Golden Hour Slot',
            content: 'Reserved rooftop observatory slot at 17:30 JST. Please bring wide lenses and meet at elevator B.',
            author: 'Sarah Lin',
            authorRole: 'Organizer',
            timestamp: DateTime.now().subtract(const Duration(hours: 6)),
            isPinned: true,
            isEnquiryClosed: false,
          ),
        ],
      ),
      GroupChat(
        id: 'chat-swiss',
        title: 'Swiss Alps Glaciers Trek',
        destination: 'Zermatt & Grindelwald, CH',
        destinationTag: 'ALPS 🏔️',
        memberNames: ['You', 'David Miller', 'Katya Weber'],
        memberAvatarColors: [
          const Color(0xFF5686F5),
          const Color(0xFF00E699),
          const Color(0xFFF5A623),
        ],
        lastMessage: 'David: Pack thermal layers, morning alpine temperature is -4°C ❄️',
        lastMessageSender: 'David Miller',
        lastMessageTime: '2h ago',
        unreadCount: 0,
        pinnedItinerary: 'Matterhorn Sunrise Hike + Glacier Express Train',
        messages: [
          ChatMessage(
            id: 'sm-1',
            senderName: 'Katya Weber',
            senderHandle: '@katya.alps',
            text: 'Cable car tickets to Klein Matterhorn are confirmed!',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ChatMessage(
            id: 'sm-2',
            senderName: 'David Miller',
            senderHandle: '@david_mtn',
            text: 'Pack thermal layers, morning alpine temperature is -4°C ❄️',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      GroupChat(
        id: 'chat-seoul',
        title: 'Seoul Night Market Foodies',
        destination: 'Myeongdong & Hongdae, Seoul',
        destinationTag: 'SEOUL 🥢',
        memberNames: ['You', 'Minho Park', 'Sora Kim', 'Daniel Wu'],
        memberAvatarColors: [
          const Color(0xFF5686F5),
          const Color(0xFFFF4757),
          const Color(0xFF00E699),
          const Color(0xFFB066FF),
        ],
        lastMessage: 'Sora: Saved 4 hot street food spots from our FYP ideation board!',
        lastMessageSender: 'Sora Kim',
        lastMessageTime: '5h ago',
        unreadCount: 1,
        pinnedItinerary: 'K-BBQ Crawl -> Han River Night Ramen Picnic',
        messages: [
          ChatMessage(
            id: 'sem-1',
            senderName: 'Minho Park',
            senderHandle: '@minhopark',
            text: 'I made reservations for the samgyeopsal spot in Seongsu-dong!',
            timestamp: DateTime.now().subtract(const Duration(hours: 8)),
          ),
          ChatMessage(
            id: 'sem-2',
            senderName: 'Sora Kim',
            senderHandle: '@sora.k',
            text: 'Saved 4 hot street food spots from our FYP ideation board!',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          ),
        ],
      ),
      GroupChat(
        id: 'chat-iceland',
        title: 'Reykjavik Aurora Chasers',
        destination: 'Golden Circle & Vik, Iceland',
        destinationTag: 'ICELAND 🌌',
        memberNames: ['You', 'Liam Channing', 'Freja Lind'],
        memberAvatarColors: [
          const Color(0xFF5686F5),
          const Color(0xFFB066FF),
          const Color(0xFF00E699),
        ],
        lastMessage: 'Liam: 4x4 campervan booked with winter spike tires 🚐',
        lastMessageSender: 'Liam Channing',
        lastMessageTime: '1d ago',
        unreadCount: 0,
        pinnedItinerary: '7-Day Ring Road Camper Expedition + Blue Lagoon',
        messages: [
          ChatMessage(
            id: 'im-1',
            senderName: 'Liam Channing',
            senderHandle: '@liam.channing',
            text: '4x4 campervan booked with winter spike tires 🚐',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
    ];
  }

  void sendMessage(
    String chatId,
    String text, {
    String? sharedVideoId,
    String? sharedVideoTitle,
    String? sharedVideoCreator,
    BillSplitInfo? billSplit,
    QrPaymentInfo? qrPayment,
  }) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index == -1) return;

    final currentChat = _chats[index];
    final newMessage = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      senderName: 'You',
      senderHandle: '@you',
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
      sharedVideoId: sharedVideoId,
      sharedVideoTitle: sharedVideoTitle,
      sharedVideoCreator: sharedVideoCreator,
      billSplit: billSplit,
      qrPayment: qrPayment,
    );

    final updatedMessages = List<ChatMessage>.from(currentChat.messages)..add(newMessage);

    _chats[index] = GroupChat(
      id: currentChat.id,
      title: currentChat.title,
      destination: currentChat.destination,
      destinationTag: currentChat.destinationTag,
      memberNames: currentChat.memberNames,
      memberAvatarColors: currentChat.memberAvatarColors,
      lastMessage: 'You: $text',
      lastMessageSender: 'You',
      lastMessageTime: 'Just now',
      unreadCount: 0,
      pinnedItinerary: currentChat.pinnedItinerary,
      sharedReelTitle: sharedVideoTitle ?? currentChat.sharedReelTitle,
      isTyping: false,
      messages: updatedMessages,
      announcements: currentChat.announcements,
    );

    notifyListeners();
  }

  void sendBillSplit(String chatId, BillSplitInfo bill) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index == -1) return;

    final currentChat = _chats[index];
    final newMessage = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      senderName: 'You',
      senderHandle: '@you',
      text: 'Created bill split: "${bill.title}" (\$${bill.totalAmount.toStringAsFixed(2)})',
      timestamp: DateTime.now(),
      isMe: true,
      billSplit: bill,
    );

    final newAnnouncement = SquadAnnouncement(
      id: 'ann-split-${DateTime.now().millisecondsSinceEpoch}',
      title: bill.title,
      content: 'Group expense split: \$${bill.totalAmount.toStringAsFixed(2)} split among ${bill.splitAmongCount} squad members (\$${bill.amountPerPerson.toStringAsFixed(2)} / person). Paid upfront by ${bill.paidBy}.',
      author: bill.paidBy,
      authorRole: 'Treasurer',
      timestamp: DateTime.now(),
      billSplit: bill,
      isEnquiryClosed: false,
    );

    final updatedMessages = List<ChatMessage>.from(currentChat.messages)..add(newMessage);
    final updatedAnnouncements = [newAnnouncement, ...currentChat.announcements];

    _chats[index] = GroupChat(
      id: currentChat.id,
      title: currentChat.title,
      destination: currentChat.destination,
      destinationTag: currentChat.destinationTag,
      memberNames: currentChat.memberNames,
      memberAvatarColors: currentChat.memberAvatarColors,
      lastMessage: 'You: Split \$${bill.totalAmount.toStringAsFixed(2)} for ${bill.title}',
      lastMessageSender: 'You',
      lastMessageTime: 'Just now',
      unreadCount: 0,
      pinnedItinerary: currentChat.pinnedItinerary,
      sharedReelTitle: currentChat.sharedReelTitle,
      isTyping: false,
      messages: updatedMessages,
      announcements: updatedAnnouncements,
    );

    notifyListeners();
  }

  void sendQrPayment(String chatId, QrPaymentInfo qr) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index == -1) return;

    final currentChat = _chats[index];
    final newMessage = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      senderName: 'You',
      senderHandle: '@you',
      text: 'Sent QR Payment Request for \$${qr.amount.toStringAsFixed(2)} (${qr.referenceNote})',
      timestamp: DateTime.now(),
      isMe: true,
      qrPayment: qr,
    );

    final newAnnouncement = SquadAnnouncement(
      id: 'ann-qr-${DateTime.now().millisecondsSinceEpoch}',
      title: 'QR Debt: ${qr.referenceNote}',
      content: 'Direct squad settlement enquiry of \$${qr.amount.toStringAsFixed(2)} payable to ${qr.payeeName}.',
      author: qr.payeeName,
      authorRole: 'Payee',
      timestamp: DateTime.now(),
      qrPayment: qr,
      isEnquiryClosed: false,
    );

    final updatedMessages = List<ChatMessage>.from(currentChat.messages)..add(newMessage);
    final updatedAnnouncements = [newAnnouncement, ...currentChat.announcements];

    _chats[index] = GroupChat(
      id: currentChat.id,
      title: currentChat.title,
      destination: currentChat.destination,
      destinationTag: currentChat.destinationTag,
      memberNames: currentChat.memberNames,
      memberAvatarColors: currentChat.memberAvatarColors,
      lastMessage: 'You: QR Pay \$${qr.amount.toStringAsFixed(2)} (${qr.referenceNote})',
      lastMessageSender: 'You',
      lastMessageTime: 'Just now',
      unreadCount: 0,
      pinnedItinerary: currentChat.pinnedItinerary,
      sharedReelTitle: currentChat.sharedReelTitle,
      isTyping: false,
      messages: updatedMessages,
      announcements: updatedAnnouncements,
    );

    notifyListeners();
  }

  void toggleAnnouncementSettled(String chatId, String announcementId) {
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex == -1) return;
    final currentChat = _chats[chatIndex];

    final annIndex = currentChat.announcements.indexWhere((a) => a.id == announcementId);
    if (annIndex == -1) return;

    final ann = currentChat.announcements[annIndex];
    final bool newClosed = !ann.isEnquiryClosed;

    final updatedAnn = ann.copyWith(
      isEnquiryClosed: newClosed,
      closedBy: newClosed ? 'You' : null,
      closedAt: newClosed ? DateTime.now() : null,
      billSplit: ann.billSplit?.copyWith(isSettled: newClosed),
      qrPayment: ann.qrPayment?.copyWith(isPaid: newClosed),
    );

    final updatedAnnouncements = List<SquadAnnouncement>.from(currentChat.announcements);
    updatedAnnouncements[annIndex] = updatedAnn;

    // Synchronize matching message in messages list if present
    final updatedMessages = currentChat.messages.map((m) {
      if (ann.billSplit != null && m.billSplit != null && m.billSplit!.title == ann.billSplit!.title) {
        return ChatMessage(
          id: m.id,
          senderName: m.senderName,
          senderHandle: m.senderHandle,
          senderAvatar: m.senderAvatar,
          text: m.text,
          timestamp: m.timestamp,
          isMe: m.isMe,
          sharedVideoId: m.sharedVideoId,
          sharedVideoTitle: m.sharedVideoTitle,
          sharedVideoCreator: m.sharedVideoCreator,
          billSplit: m.billSplit!.copyWith(isSettled: newClosed),
          qrPayment: m.qrPayment,
        );
      }
      if (ann.qrPayment != null && m.qrPayment != null && m.qrPayment!.referenceNote == ann.qrPayment!.referenceNote) {
        return ChatMessage(
          id: m.id,
          senderName: m.senderName,
          senderHandle: m.senderHandle,
          senderAvatar: m.senderAvatar,
          text: m.text,
          timestamp: m.timestamp,
          isMe: m.isMe,
          sharedVideoId: m.sharedVideoId,
          sharedVideoTitle: m.sharedVideoTitle,
          sharedVideoCreator: m.sharedVideoCreator,
          billSplit: m.billSplit,
          qrPayment: m.qrPayment!.copyWith(isPaid: newClosed),
        );
      }
      return m;
    }).toList();

    _chats[chatIndex] = GroupChat(
      id: currentChat.id,
      title: currentChat.title,
      destination: currentChat.destination,
      destinationTag: currentChat.destinationTag,
      memberNames: currentChat.memberNames,
      memberAvatarColors: currentChat.memberAvatarColors,
      lastMessage: newClosed ? 'Enquiry closed: "${ann.title}"' : currentChat.lastMessage,
      lastMessageSender: 'You',
      lastMessageTime: 'Just now',
      unreadCount: currentChat.unreadCount,
      pinnedItinerary: currentChat.pinnedItinerary,
      sharedReelTitle: currentChat.sharedReelTitle,
      isTyping: currentChat.isTyping,
      typingUser: currentChat.typingUser,
      messages: updatedMessages,
      announcements: updatedAnnouncements,
    );

    notifyListeners();
  }

  void addAnnouncement(String chatId, SquadAnnouncement announcement) {
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex == -1) return;
    final currentChat = _chats[chatIndex];

    final updatedAnnouncements = [announcement, ...currentChat.announcements];

    _chats[chatIndex] = GroupChat(
      id: currentChat.id,
      title: currentChat.title,
      destination: currentChat.destination,
      destinationTag: currentChat.destinationTag,
      memberNames: currentChat.memberNames,
      memberAvatarColors: currentChat.memberAvatarColors,
      lastMessage: '📢 ${announcement.title}',
      lastMessageSender: announcement.author,
      lastMessageTime: 'Just now',
      unreadCount: 0,
      pinnedItinerary: currentChat.pinnedItinerary,
      sharedReelTitle: currentChat.sharedReelTitle,
      isTyping: currentChat.isTyping,
      typingUser: currentChat.typingUser,
      messages: currentChat.messages,
      announcements: updatedAnnouncements,
    );

    notifyListeners();
  }

  void toggleBillSettled(String chatId, String messageId) {
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex == -1) return;
    final currentChat = _chats[chatIndex];

    final msgIndex = currentChat.messages.indexWhere((m) => m.id == messageId);
    if (msgIndex == -1) return;

    final msg = currentChat.messages[msgIndex];
    if (msg.billSplit == null) return;

    final newSettled = !msg.billSplit!.isSettled;
    final updatedBill = msg.billSplit!.copyWith(isSettled: newSettled);
    final updatedMsg = ChatMessage(
      id: msg.id,
      senderName: msg.senderName,
      senderHandle: msg.senderHandle,
      senderAvatar: msg.senderAvatar,
      text: msg.text,
      timestamp: msg.timestamp,
      isMe: msg.isMe,
      sharedVideoId: msg.sharedVideoId,
      sharedVideoTitle: msg.sharedVideoTitle,
      sharedVideoCreator: msg.sharedVideoCreator,
      billSplit: updatedBill,
      qrPayment: msg.qrPayment,
    );

    final updatedMessages = List<ChatMessage>.from(currentChat.messages);
    updatedMessages[msgIndex] = updatedMsg;

    // Synchronize matching announcement
    final updatedAnnouncements = currentChat.announcements.map((a) {
      if (a.billSplit != null && a.billSplit!.title == msg.billSplit!.title) {
        return a.copyWith(
          isEnquiryClosed: newSettled,
          closedBy: newSettled ? 'You' : null,
          closedAt: newSettled ? DateTime.now() : null,
          billSplit: a.billSplit!.copyWith(isSettled: newSettled),
        );
      }
      return a;
    }).toList();

    _chats[chatIndex] = GroupChat(
      id: currentChat.id,
      title: currentChat.title,
      destination: currentChat.destination,
      destinationTag: currentChat.destinationTag,
      memberNames: currentChat.memberNames,
      memberAvatarColors: currentChat.memberAvatarColors,
      lastMessage: currentChat.lastMessage,
      lastMessageSender: currentChat.lastMessageSender,
      lastMessageTime: currentChat.lastMessageTime,
      unreadCount: currentChat.unreadCount,
      pinnedItinerary: currentChat.pinnedItinerary,
      sharedReelTitle: currentChat.sharedReelTitle,
      isTyping: currentChat.isTyping,
      typingUser: currentChat.typingUser,
      messages: updatedMessages,
      announcements: updatedAnnouncements,
    );

    notifyListeners();
  }

  void toggleQrPaid(String chatId, String messageId) {
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex == -1) return;
    final currentChat = _chats[chatIndex];

    final msgIndex = currentChat.messages.indexWhere((m) => m.id == messageId);
    if (msgIndex == -1) return;

    final msg = currentChat.messages[msgIndex];
    if (msg.qrPayment == null) return;

    final newPaid = !msg.qrPayment!.isPaid;
    final updatedQr = msg.qrPayment!.copyWith(isPaid: newPaid);
    final updatedMsg = ChatMessage(
      id: msg.id,
      senderName: msg.senderName,
      senderHandle: msg.senderHandle,
      senderAvatar: msg.senderAvatar,
      text: msg.text,
      timestamp: msg.timestamp,
      isMe: msg.isMe,
      sharedVideoId: msg.sharedVideoId,
      sharedVideoTitle: msg.sharedVideoTitle,
      sharedVideoCreator: msg.sharedVideoCreator,
      billSplit: msg.billSplit,
      qrPayment: updatedQr,
    );

    final updatedMessages = List<ChatMessage>.from(currentChat.messages);
    updatedMessages[msgIndex] = updatedMsg;

    // Synchronize matching announcement
    final updatedAnnouncements = currentChat.announcements.map((a) {
      if (a.qrPayment != null && a.qrPayment!.referenceNote == msg.qrPayment!.referenceNote) {
        return a.copyWith(
          isEnquiryClosed: newPaid,
          closedBy: newPaid ? 'You' : null,
          closedAt: newPaid ? DateTime.now() : null,
          qrPayment: a.qrPayment!.copyWith(isPaid: newPaid),
        );
      }
      return a;
    }).toList();

    _chats[chatIndex] = GroupChat(
      id: currentChat.id,
      title: currentChat.title,
      destination: currentChat.destination,
      destinationTag: currentChat.destinationTag,
      memberNames: currentChat.memberNames,
      memberAvatarColors: currentChat.memberAvatarColors,
      lastMessage: currentChat.lastMessage,
      lastMessageSender: currentChat.lastMessageSender,
      lastMessageTime: currentChat.lastMessageTime,
      unreadCount: currentChat.unreadCount,
      pinnedItinerary: currentChat.pinnedItinerary,
      sharedReelTitle: currentChat.sharedReelTitle,
      isTyping: currentChat.isTyping,
      typingUser: currentChat.typingUser,
      messages: updatedMessages,
      announcements: updatedAnnouncements,
    );

    notifyListeners();
  }

  void createGroupBookingLink(String chatId, GroupBookingLinkInfo booking) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index == -1) return;

    final currentChat = _chats[index];
    final senderName = booking.createdBy.isEmpty ? 'You' : booking.createdBy;
    final newMessage = ChatMessage(
      id: 'msg-bk-${DateTime.now().millisecondsSinceEpoch}',
      senderName: senderName,
      senderHandle: '@${senderName.toLowerCase().replaceAll(' ', '_')}',
      text: '🔗 Group Booking Link created! Book your own spot for ${booking.hotelOrStayName} (\$${booking.pricePerPerson.toStringAsFixed(0)} / person). Claim your spot below!',
      timestamp: DateTime.now(),
      isMe: senderName == 'You',
      groupBooking: booking,
    );

    final newAnnouncement = SquadAnnouncement(
      id: 'ann-bk-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Group Booking: ${booking.hotelOrStayName}',
      content: 'Master squad reservation. Book your individual spot directly (\$${booking.pricePerPerson.toStringAsFixed(0)} / person) for ${booking.dates}. Ref: ${booking.bookingRef}.',
      author: senderName,
      authorRole: 'Trip Lead',
      timestamp: DateTime.now(),
      groupBooking: booking,
      isEnquiryClosed: false,
    );

    final updatedMessages = List<ChatMessage>.from(currentChat.messages)..add(newMessage);
    final updatedAnnouncements = [newAnnouncement, ...currentChat.announcements];

    _chats[index] = GroupChat(
      id: currentChat.id,
      title: currentChat.title,
      destination: currentChat.destination,
      destinationTag: currentChat.destinationTag,
      memberNames: currentChat.memberNames,
      memberAvatarColors: currentChat.memberAvatarColors,
      lastMessage: '$senderName: Group Booking Link (${booking.bookedMembers.length}/${booking.totalSpots} booked)',
      lastMessageSender: senderName,
      lastMessageTime: 'Just now',
      unreadCount: 0,
      pinnedItinerary: currentChat.pinnedItinerary,
      sharedReelTitle: currentChat.sharedReelTitle,
      isTyping: false,
      messages: updatedMessages,
      announcements: updatedAnnouncements,
    );

    notifyListeners();
  }

  void bookIndividualSpot(String chatId, String bookingId, String memberName) {
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex == -1) return;
    final currentChat = _chats[chatIndex];

    GroupBookingLinkInfo? targetBooking;
    for (final ann in currentChat.announcements) {
      if (ann.groupBooking != null && ann.groupBooking!.id == bookingId) {
        targetBooking = ann.groupBooking;
        break;
      }
    }
    if (targetBooking == null) {
      for (final msg in currentChat.messages) {
        if (msg.groupBooking != null && msg.groupBooking!.id == bookingId) {
          targetBooking = msg.groupBooking;
          break;
        }
      }
    }

    if (targetBooking == null) return;
    if (targetBooking.bookedMembers.contains(memberName)) return;

    final updatedBooked = List<String>.from(targetBooking.bookedMembers)..add(memberName);
    final isFull = updatedBooked.length >= targetBooking.totalSpots;
    final updatedBooking = targetBooking.copyWith(
      bookedMembers: updatedBooked,
      isLocked: isFull,
    );

    final updatedAnnouncements = currentChat.announcements.map((ann) {
      if (ann.groupBooking != null && ann.groupBooking!.id == bookingId) {
        return ann.copyWith(
          groupBooking: updatedBooking,
          isEnquiryClosed: isFull,
          closedBy: isFull ? 'Squad Full' : null,
          closedAt: isFull ? DateTime.now() : null,
        );
      }
      return ann;
    }).toList();

    final updatedMessages = currentChat.messages.map((msg) {
      if (msg.groupBooking != null && msg.groupBooking!.id == bookingId) {
        return ChatMessage(
          id: msg.id,
          senderName: msg.senderName,
          senderHandle: msg.senderHandle,
          senderAvatar: msg.senderAvatar,
          text: msg.text,
          timestamp: msg.timestamp,
          isMe: msg.isMe,
          sharedVideoId: msg.sharedVideoId,
          sharedVideoTitle: msg.sharedVideoTitle,
          sharedVideoCreator: msg.sharedVideoCreator,
          billSplit: msg.billSplit,
          qrPayment: msg.qrPayment,
          groupBooking: updatedBooking,
        );
      }
      return msg;
    }).toList();

    // Add automated confirmation message
    final confirmMsg = ChatMessage(
      id: 'msg-conf-${DateTime.now().millisecondsSinceEpoch}',
      senderName: memberName,
      senderHandle: '@${memberName.toLowerCase().replaceAll(' ', '_')}',
      text: '🎉 $memberName just booked their individual spot for ${targetBooking.hotelOrStayName} (${targetBooking.bookingRef})! ${updatedBooked.length} of ${targetBooking.totalSpots} spots locked.',
      timestamp: DateTime.now(),
      isMe: memberName == 'You',
    );
    updatedMessages.add(confirmMsg);

    _chats[chatIndex] = GroupChat(
      id: currentChat.id,
      title: currentChat.title,
      destination: currentChat.destination,
      destinationTag: currentChat.destinationTag,
      memberNames: currentChat.memberNames,
      memberAvatarColors: currentChat.memberAvatarColors,
      lastMessage: '$memberName booked spot (${updatedBooked.length}/${targetBooking.totalSpots})',
      lastMessageSender: memberName,
      lastMessageTime: 'Just now',
      unreadCount: 0,
      pinnedItinerary: currentChat.pinnedItinerary,
      sharedReelTitle: currentChat.sharedReelTitle,
      isTyping: false,
      messages: updatedMessages,
      announcements: updatedAnnouncements,
    );

    notifyListeners();
  }

  void shareVideoToChat(String chatId, VideoItem video, {String comment = 'Check out this travel reel!'}) {
    sendMessage(
      chatId,
      comment,
      sharedVideoId: video.id,
      sharedVideoTitle: '${video.indexLabel} • ${video.title}',
      sharedVideoCreator: video.creatorHandle,
    );
  }

  void markChatAsRead(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index == -1) return;
    final currentChat = _chats[index];
    if (currentChat.unreadCount > 0) {
      _chats[index] = GroupChat(
        id: currentChat.id,
        title: currentChat.title,
        destination: currentChat.destination,
        destinationTag: currentChat.destinationTag,
        memberNames: currentChat.memberNames,
        memberAvatarColors: currentChat.memberAvatarColors,
        lastMessage: currentChat.lastMessage,
        lastMessageSender: currentChat.lastMessageSender,
        lastMessageTime: currentChat.lastMessageTime,
        unreadCount: 0,
        pinnedItinerary: currentChat.pinnedItinerary,
        sharedReelTitle: currentChat.sharedReelTitle,
        isTyping: currentChat.isTyping,
        typingUser: currentChat.typingUser,
        messages: currentChat.messages,
        announcements: currentChat.announcements,
      );
      notifyListeners();
    }
  }
}
