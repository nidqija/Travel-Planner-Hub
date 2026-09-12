import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cn26app/models/social_community.dart';
import 'package:cn26app/models/travel_booking.dart';
import 'package:cn26app/pages/community_detail_page.dart';
import 'package:cn26app/pages/social_home_page.dart';

void main() {
  group('SocialCommunityRepository Tests', () {
    final repo = SocialCommunityRepository.instance;

    test('Initial communities are populated with verified guilds', () {
      expect(repo.communities.length, greaterThanOrEqualTo(4));
      final tokyo = repo.communities.firstWhere((c) => c.id == 'comm-tokyo');
      expect(tokyo.name, contains('Tokyo Midnight'));
      expect(tokyo.groupBookings.isNotEmpty, isTrue);
      expect(tokyo.tripPlans.isNotEmpty, isTrue);
    });

    test('toggleJoinCommunity updates membership status', () {
      final comm = repo.communities.firstWhere((c) => c.id == 'comm-bali');
      final initialJoined = comm.isJoined;
      final initialCount = comm.memberCount;

      repo.toggleJoinCommunity(comm.id);

      final updated = repo.communities.firstWhere((c) => c.id == 'comm-bali');
      expect(updated.isJoined, !initialJoined);
      expect(updated.memberCount, initialJoined ? initialCount - 1 : initialCount + 1);

      // Revert
      repo.toggleJoinCommunity(comm.id);
    });

    test('bookSpotInGroupBooking reserves a spot and syncs into TravelBookingsManager', () {
      final bookingsManager = TravelBookingsManager.instance;
      final initialBookingCount = bookingsManager.bookings.length;

      final tokyo = repo.communities.firstWhere((c) => c.id == 'comm-tokyo');
      final gb = tokyo.groupBookings.firstWhere((b) => b.id == 'gb-tokyo-2');

      expect(gb.hasUserBooked, isFalse);
      final initialRemaining = gb.spotsRemaining;

      final success = repo.bookSpotInGroupBooking(
        communityId: tokyo.id,
        bookingId: gb.id,
        userName: 'Elena Test',
        userEmail: 'elena@aperture.ai',
        userPhone: '+1 555-0199',
      );

      expect(success, isTrue);
      final updatedGb = repo.communities
          .firstWhere((c) => c.id == 'comm-tokyo')
          .groupBookings
          .firstWhere((b) => b.id == 'gb-tokyo-2');

      expect(updatedGb.hasUserBooked, isTrue);
      expect(updatedGb.spotsRemaining, equals(initialRemaining - 1));
      expect(bookingsManager.bookings.length, equals(initialBookingCount + 1));
      expect(bookingsManager.bookings.first.hotelName, equals(gb.stayName));
      expect(bookingsManager.bookings.first.isGroupTrip, isTrue);
    });

    test('voteOnPoll toggles and recalculates vote tally', () {
      final tokyo = repo.communities.firstWhere((c) => c.id == 'comm-tokyo');
      final trip = tokyo.tripPlans.first;
      final poll = trip.polls.first;
      final opt = poll.options.firstWhere((o) => !o.isUserVoted);
      final initialVotes = opt.voteCount;

      repo.voteOnPoll(
        communityId: tokyo.id,
        tripPlanId: trip.id,
        pollId: poll.id,
        optionId: opt.id,
      );

      final updatedOpt = repo.communities
          .firstWhere((c) => c.id == 'comm-tokyo')
          .tripPlans
          .first
          .polls
          .first
          .options
          .firstWhere((o) => o.id == opt.id);

      expect(updatedOpt.voteCount, equals(initialVotes + 1));
      expect(updatedOpt.isUserVoted, isTrue);
    });

    test('addTripActivity adds a new activity stop', () {
      final tokyo = repo.communities.firstWhere((c) => c.id == 'comm-tokyo');
      final trip = tokyo.tripPlans.first;
      final day1 = trip.days.first;
      final initialActivities = day1.activities.length;

      repo.addTripActivity(
        communityId: tokyo.id,
        tripPlanId: trip.id,
        dayNumber: 1,
        time: '11:00 PM',
        title: 'Rooftop Cocktail Night',
        location: 'Roppongi Hills',
        estimatedCost: 30.0,
      );

      final updatedDay1 = repo.communities
          .firstWhere((c) => c.id == 'comm-tokyo')
          .tripPlans
          .first
          .days
          .first;

      expect(updatedDay1.activities.length, equals(initialActivities + 1));
      expect(updatedDay1.activities.last.title, equals('Rooftop Cocktail Night'));
    });

    test('createGroupBooking adds new pool to community', () {
      final comm = repo.communities.first;
      final initialCount = comm.groupBookings.length;

      repo.createGroupBooking(
        communityId: comm.id,
        title: 'Test Penthouse Takeover',
        stayName: 'Test Grand Hotel',
        destination: 'Kyoto',
        dates: 'Dec 1 – Dec 5',
        totalPrice: 2000.0,
        totalSpots: 4,
        depositRequired: 100.0,
        amenities: ['Pool', 'Sauna'],
      );

      final updatedComm = repo.communities.firstWhere((c) => c.id == comm.id);
      expect(updatedComm.groupBookings.length, equals(initialCount + 1));
      expect(updatedComm.groupBookings.first.pricePerPerson, equals(500.0));
    });
  });

  group('Social Community UI Widget Tests', () {
    testWidgets('SocialHomePage renders top segmented navigation and switches sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SocialHomePage(),
        ),
      );

      // Verify segmented pills exist
      expect(find.text('Squads'), findsWidgets);
      expect(find.text('Community Hub'), findsOneWidget);
      expect(find.text('Group Bookings'), findsOneWidget);
      expect(find.text('Trip Co-Planner'), findsOneWidget);

      // Switch to Community Hub
      await tester.tap(find.text('Community Hub'));
      await tester.pumpAndSettle();

      expect(find.text('Travel Communities'), findsOneWidget);
      expect(find.textContaining('Tokyo Midnight'), findsOneWidget);
      expect(find.text('Enter Community'), findsWidgets);

      // Switch to Group Bookings Hub
      await tester.tap(find.text('Group Bookings'));
      await tester.pumpAndSettle();

      expect(find.text('Grouped Bookings'), findsOneWidget);
      expect(find.textContaining('spots claimed'), findsWidgets);

      // Switch to Trip Co-Planner
      await tester.tap(find.text('Trip Co-Planner'));
      await tester.pumpAndSettle();

      expect(find.text('Trip Co-Planner'), findsWidgets);
      expect(find.text('ITINERARY STOPS'), findsWidgets);
    });

    testWidgets('CommunityDetailPage renders all subtabs correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CommunityDetailPage(communityId: 'comm-tokyo'),
        ),
      );

      expect(find.text('Tokyo Midnight & Street Culture'), findsOneWidget);
      expect(find.text('Plan Trip'), findsOneWidget);

      // Verify Tab labels
      expect(find.textContaining('TRIPS'), findsOneWidget);
      expect(find.textContaining('BOOKINGS'), findsOneWidget);
      expect(find.text('POLLS'), findsOneWidget);
      expect(find.textContaining('LOUNGE'), findsOneWidget);

      // Tap on BOOKINGS tab
      await tester.tap(find.textContaining('BOOKINGS'));
      await tester.pumpAndSettle();

      expect(find.text('Takeover a Villa or Chalet'), findsOneWidget);
    });
  });
}
