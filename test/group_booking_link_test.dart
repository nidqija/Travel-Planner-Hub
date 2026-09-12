import 'package:flutter_test/flutter_test.dart';
import 'package:cn26app/models/group_chat.dart';
import 'package:cn26app/models/travel_booking.dart';

void main() {
  group('Group Booking Link Unit & State Tests', () {
    late GroupChatRepository repo;

    setUp(() {
      repo = GroupChatRepository.instance;
    });

    test('GroupBookingLinkInfo tracks occupancy and member status accurately', () {
      final info = GroupBookingLinkInfo(
        id: 'gbl-test-1',
        title: 'Ubud Private Pool Villa',
        hotelOrStayName: 'Canggu Kinetic Eco-Resort',
        destination: 'Bali, Indonesia',
        dates: 'Oct 15 – Oct 18, 2026',
        pricePerPerson: 210.0,
        currency: 'USD',
        totalSpots: 4,
        bookedMembers: const ['Alex Rivera'],
        allMembers: const ['Alex Rivera', 'Maya Chen', 'Leo Vance', 'You'],
        bookingRef: '#GRP-BALI-9901',
        shareableUrl: 'https://aperture.travel/grp/bali-9901',
        createdBy: 'Alex Rivera',
        createdAt: DateTime.now(),
      );

      expect(info.totalSpots, 4);
      expect(info.bookedMembers.length, 1);
      expect(info.remainingSpots, 3);
      expect(info.isFull, false);
      expect(info.isBookedBy('Alex Rivera'), true);
      expect(info.isBookedBy('You'), false);

      final updated = info.copyWith(
        bookedMembers: ['Alex Rivera', 'Maya Chen', 'Leo Vance', 'You'],
      );
      expect(updated.isFull, true);
      expect(updated.remainingSpots, 0);
      expect(updated.isBookedBy('You'), true);
    });

    test('createGroupBookingLink adds message and announcement to chat', () {
      final booking = GroupBookingLinkInfo(
        id: 'gbl-test-2',
        title: 'Tokyo Cyber Loft',
        hotelOrStayName: 'Shibuya Capsule Pods',
        destination: 'Tokyo, Japan',
        dates: 'Nov 10 – Nov 14, 2026',
        pricePerPerson: 180.0,
        currency: 'USD',
        totalSpots: 3,
        bookedMembers: const [],
        allMembers: const ['You', 'Ren Tanaka', 'Chloe Dubois'],
        bookingRef: '#GRP-TOK-7721',
        shareableUrl: 'https://aperture.travel/grp/tok-7721',
        createdBy: 'You',
        createdAt: DateTime.now(),
      );

      final initialAnnouncementsCount = repo.chats.first.announcements.length;
      final initialMessagesCount = repo.chats.first.messages.length;

      repo.createGroupBookingLink('chat-bali', booking);

      final chat = repo.chats.firstWhere((c) => c.id == 'chat-bali');
      expect(chat.announcements.length, initialAnnouncementsCount + 1);
      expect(chat.messages.length, initialMessagesCount + 1);

      // Verify announcement has groupBooking attachment
      final newAnn = chat.announcements.first;
      expect(newAnn.groupBooking, isNotNull);
      expect(newAnn.groupBooking!.hotelOrStayName, 'Shibuya Capsule Pods');
      expect(newAnn.groupBooking!.bookingRef, '#GRP-TOK-7721');

      // Verify in-chat message has groupBooking attachment
      final newMsg = chat.messages.last;
      expect(newMsg.groupBooking, isNotNull);
      expect(newMsg.groupBooking!.pricePerPerson, 180.0);
    });

    test('bookIndividualSpot updates booked count and sends confirmation message', () {
      final chat = repo.chats.firstWhere((c) => c.id == 'chat-bali');
      final targetBooking = chat.announcements.firstWhere((a) => a.groupBooking != null).groupBooking!;

      expect(targetBooking.isBookedBy('You'), false);
      final initialBookedCount = targetBooking.bookedMembers.length;

      // Book individual spot
      repo.bookIndividualSpot('chat-bali', targetBooking.id, 'You');

      final updatedChat = repo.chats.firstWhere((c) => c.id == 'chat-bali');
      final updatedAnn = updatedChat.announcements.firstWhere((a) => a.groupBooking != null);
      expect(updatedAnn.groupBooking!.isBookedBy('You'), true);
      expect(updatedAnn.groupBooking!.bookedMembers.length, initialBookedCount + 1);

      // Verify automated confirmation message was posted
      final lastMsg = updatedChat.messages.last;
      expect(lastMsg.text, contains('You just booked their individual spot'));

      // Also verify recording individual travel booking in TravelBookingsManager
      final personalBooking = TravelBooking(
        id: 'bk-test-individual-1',
        destinationTitle: 'Bali, Indonesia (Group Trip)',
        hotelName: targetBooking.hotelOrStayName,
        roomType: 'Individual Spot',
        dates: targetBooking.dates,
        bookingRef: '${targetBooking.bookingRef}-YOU',
        totalPrice: '\$210',
        status: 'CONFIRMED',
        guestName: 'Alex Mercer',
        guestPassport: 'P89421054',
        guestNationality: 'United States',
        guestEmail: 'alex.mercer@aperture.ai',
        guestPhone: '+1 (555) 382-9014',
        createdAt: DateTime.now(),
        isGroupTrip: true,
        groupMembers: targetBooking.allMembers,
        perPersonPrice: '\$210 / person',
      );

      TravelBookingsManager.instance.addBooking(personalBooking);
      expect(
        TravelBookingsManager.instance.bookings.any((b) => b.bookingRef == '${targetBooking.bookingRef}-YOU'),
        true,
      );
    });
  });
}
