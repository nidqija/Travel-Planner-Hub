import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cn26app/models/video_item.dart';
import 'package:cn26app/models/travel_booking.dart';
import 'package:cn26app/widgets/openclaw_agent_widget.dart';
import 'package:cn26app/widgets/nearby_hotels_sheet.dart';
import 'package:cn26app/pages/fyp_feed_page.dart';

void main() {
  final sampleVideos = VideoItem.getSampleFeed();
  final sampleDestination = sampleVideos.first.destination;

  group('OpenClawAgentWidget Tests', () {
    testWidgets('renders OpenClaw bot, greeting prompt, and travel telemetry after 1 second delay', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 250,
              child: OpenClawAgentWidget(
                destination: sampleDestination,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      // At 200ms (before 1s), OpenClaw is not yet displayed
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('OPENCLAW AI'), findsNothing);

      // Advance clock past 1-second delay (t = 1100ms)
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pump(const Duration(milliseconds: 200));

      // Verify OpenClaw branding and greeting prompt are now displayed
      expect(find.text('OPENCLAW AI'), findsOneWidget);
      expect(find.text('Hello! Ready to travel to this place?'), findsOneWidget);
      expect(find.text(sampleDestination.cityCountry), findsOneWidget);

      // Verify travel telemetry preview in speech bubble
      expect(
        find.textContaining(sampleDestination.travelTime.split('+').first.trim()),
        findsOneWidget,
      );

      // Tap on speech bubble
      await tester.tap(find.text('Hello! Ready to travel to this place?'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tapped, isTrue);
    });

    testWidgets('auto-closes small speech model after 2 seconds and clicking bot icon triggers hotel modal', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 250,
              child: OpenClawAgentWidget(
                destination: sampleDestination,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      // Advance clock past 1s delay to show OpenClaw
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Hello! Ready to travel to this place?'), findsOneWidget);

      // Advance clock past 2s auto-close duration (t = 1100ms + 2100ms = 3200ms)
      await tester.pump(const Duration(milliseconds: 2100));
      // Pump transition frame for AnimatedSwitcher
      await tester.pump(const Duration(milliseconds: 350));

      // Small model (speech bubble) has closed
      expect(find.text('Hello! Ready to travel to this place?'), findsNothing);

      // Tap the bot mascot icon directly
      await tester.tap(find.byKey(const ValueKey('openclaw-bot-mascot-tap')));
      await tester.pump(const Duration(milliseconds: 100));

      // Tapping bot icon displays hotel modal (invokes onTap)
      expect(tapped, isTrue);
    });
  });

  group('NearbyHotelsSheet Tests', () {
    testWidgets('renders contextual recommendations, travel/arrival telemetry, and optimal visiting months', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    NearbyHotelsSheet.show(context, destination: sampleDestination);
                  },
                  child: const Text('Open Stays'),
                );
              },
            ),
          ),
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Open Stays'));
      await tester.pumpAndSettle();

      // Verify destination info and AI Concierge banner
      expect(find.text(sampleDestination.locationName), findsOneWidget);
      expect(find.text('OPENCLAW AI CONCIERGE'), findsWidgets);

      // Verify Contextual Recommendation section
      expect(find.text('CONTEXTUAL RECOMMENDATION'), findsOneWidget);
      expect(find.text(sampleDestination.contextualRecommendation), findsOneWidget);

      // Verify Travel Time and Estimated Arrival telemetry
      expect(find.text('TOTAL TRAVEL TIME'), findsOneWidget);
      expect(find.text(sampleDestination.travelTime), findsOneWidget);
      expect(find.text('ESTIMATED ARRIVAL'), findsOneWidget);
      expect(find.text(sampleDestination.estimatedArrivalTime), findsOneWidget);

      // Verify Optimal Visiting Months and Climate
      expect(find.text('OPTIMAL VISITING MONTHS'), findsOneWidget);
      expect(find.text(sampleDestination.optimalVisitingMonths), findsOneWidget);
      expect(find.text(sampleDestination.currentSeasonStatus), findsOneWidget);
      expect(find.text(sampleDestination.weatherExpectation), findsOneWidget);

      // Verify filter chips
      expect(find.text('All Stays'), findsOneWidget);
      expect(find.text('⭐ Top Rated'), findsOneWidget);
      expect(find.text('⚡ Best Value'), findsOneWidget);

      // Verify destination video estimate section and hotel cards rendered
      expect(find.textContaining('VIDEO ESTIMATE'), findsOneWidget);
      expect(find.text(sampleDestination.hotels.first.name), findsWidgets);
      expect(find.text('Book Now'), findsWidgets);

      // Scroll to and tap "Book Now"
      final bookNowFinder = find.text('Book Now').first;
      await tester.scrollUntilVisible(bookNowFinder, 300, scrollable: find.byType(Scrollable).last);
      await tester.pumpAndSettle();
      await tester.tap(bookNowFinder);
      await tester.pumpAndSettle();

      // Verify HotelBookingFlowSheet opens with date selection stage first
      expect(find.text('when do you wanna come ?'), findsOneWidget);
      expect(find.text('YEAR'), findsOneWidget);
      expect(find.text('MONTH'), findsOneWidget);
      expect(find.text('DAY'), findsOneWidget);
      expect(find.text('Confirm Dates & Continue to Documents'), findsOneWidget);

      // Tap Confirm Dates & Continue to Documents to move to the info filling form
      await tester.tap(find.text('Confirm Dates & Continue to Documents'));
      await tester.pumpAndSettle();

      // Verify required documents & autofill prompt are now displayed
      expect(find.text('REQUIRED TRAVEL DOCUMENTS'), findsOneWidget);
      expect(find.text('would you like to autofill the items?'), findsOneWidget);
      expect(find.text('Yes, Autofill'), findsOneWidget);

      // Tap "Yes, Autofill"
      await tester.tap(find.text('Yes, Autofill'));
      await tester.pumpAndSettle();

      // Verify documents are autofilled and verification message is displayed
      expect(find.textContaining('verify your information before proceeding'), findsOneWidget);
      expect(find.text('Alex Mercer'), findsOneWidget);
      expect(find.text('P89421054'), findsOneWidget);
      expect(find.text('Verify & Proceed'), findsOneWidget);

      // Tap Proceed
      await tester.tap(find.text('Verify & Proceed'));
      await tester.pump();

      // Verify "Submitted" state and loading spinner are active
      expect(find.text('Submitted'), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Advance clock past the submission delay to complete booking
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      // Verify "Booking Successful!" screen is displayed
      expect(find.text('Booking Successful!'), findsOneWidget);
      expect(find.text('View in Bookings'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Close the booking sheet
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Booking Successful!'), findsNothing);
    });
  });

  group('Top Navbar Tests', () {
    testWidgets('renders For You, Bookings, and Budget navbar tabs and opens Bookings sheet', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: FypFeedPage(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Verify the new categories: For You, Bookings, and Budget
      expect(find.text('For You'), findsOneWidget);
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Budget'), findsOneWidget);

      // Verify old categories no longer exist in the navbar
      expect(find.text('Deep Cuts'), findsNothing);
      expect(find.text('Kinetic'), findsNothing);

      // Tap Bookings tab
      await tester.tap(find.text('Bookings'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify My Travel Bookings sheet opened
      expect(find.text('MY TRAVEL BOOKINGS'), findsOneWidget);
      expect(find.textContaining('Suiran'), findsOneWidget);
    });

    testWidgets('OpenClawAgentWidget is fitted inside ViewfinderFrame', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: FypFeedPage(),
        ),
      );
      // Advance clock past 1 second so OpenClaw appears in ViewfinderFrame
      await tester.pump(const Duration(milliseconds: 1200));

      // Verify OpenClawAgentWidget is rendered inside ViewfinderFrame
      expect(find.byType(OpenClawAgentWidget), findsWidgets);
      expect(find.text('OPENCLAW AI'), findsWidgets);
      expect(find.text('Hello! Ready to travel to this place?'), findsWidgets);
    });

    testWidgets('tapping Budget tab opens BudgetPlannerPage and syncs potential hotel expenses', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: FypFeedPage(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Tap Budget tab
      await tester.tap(find.text('Budget'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Budget Planner Page is displayed with video bot recommendation estimates
      expect(find.text('TRAVEL BUDGET SYNC'), findsOneWidget);
      expect(find.text('TOTAL TRAVEL BUDGET'), findsOneWidget);
      expect(find.text('\$6000'), findsOneWidget);
      expect(find.text('TOTAL ESTIMATE'), findsOneWidget);
      expect(find.text('TOTAL NIGHTS'), findsOneWidget);
      expect(find.text('OPENCLAW AI RECOMMENDATION SYNTHESIS'), findsOneWidget);

      // Verify video estimates component is removed from BudgetPlannerPage, and per-bot note is displayed
      expect(find.text('PER-BOT DESTINATION ESTIMATES'), findsOneWidget);
      expect(find.text('FEED'), findsOneWidget);

      // Tap FEED to return to FYP
      await tester.tap(find.text('FEED'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('APERTURE'), findsOneWidget);
    });

    testWidgets('tapping Saved tab opens SavedCollectionsPage and displays playlists', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: FypFeedPage(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Verify Saved tab in top navbar
      expect(find.text('Saved'), findsOneWidget);

      // Tap Saved tab
      await tester.tap(find.text('Saved'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Saved Collections page elements
      expect(find.text('SAVED COLLECTIONS'), findsOneWidget);
      expect(find.text('SAVED PLACES'), findsOneWidget);
      expect(find.text('PLAYLISTS'), findsOneWidget);
      expect(find.text('All Places'), findsOneWidget);
      expect(find.text('Want to Visit'), findsWidgets);
      expect(find.text('Summer Escapes'), findsWidgets);
      expect(find.text('Nature & Zen'), findsWidgets);

      // Tap FEED to return
      await tester.tap(find.text('FEED'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('APERTURE'), findsOneWidget);
    });

    testWidgets('tapping SAVE on video opens SaveToCollectionSheet', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: FypFeedPage(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Tap SAVE pill on feed
      expect(find.text('SAVE'), findsWidgets);
      await tester.tap(find.text('SAVE').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Save To Collection sheet opened
      expect(find.text('SAVE PLACE TO PLAYLIST'), findsOneWidget);
      expect(find.text('SELECT PLAYLISTS / COLLECTIONS'), findsOneWidget);
      expect(find.text('New Playlist'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Tap Done to close
      await tester.tap(find.text('Done'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('SAVE PLACE TO PLAYLIST'), findsNothing);
    });

    testWidgets('FYP renders without any RenderFlex overflow on narrow mobile screens (360x640)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: FypFeedPage(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Advance clock for OpenClaw to appear
      await tester.pump(const Duration(milliseconds: 1200));

      // Ensure no flutter exceptions were thrown
      expect(tester.takeException(), isNull);
      expect(find.text('APERTURE'), findsOneWidget);
      expect(find.text('For You'), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('SAVE'), findsWidgets);
      expect(find.text('FOLLOW'), findsWidgets);
    });

    testWidgets('newly booked hotel appears in My Travel Bookings section', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Add a test booking
      TravelBookingsManager.instance.addBooking(
        TravelBooking(
          id: 'test-booking-1',
          destinationTitle: 'Reykjavik, Iceland 🇮🇸',
          hotelName: 'The Retreat Hotel at Blue Lagoon',
          roomType: 'Lagoon Junior Suite',
          dates: 'Next 3 Nights • 2 Guests',
          bookingRef: '#AP-ICE-7721',
          totalPrice: '\$2,670',
          status: 'CONFIRMED',
          guestName: 'Alex Mercer',
          guestPassport: 'P89421054',
          guestNationality: 'United States',
          guestEmail: 'alex.mercer@aperture.ai',
          guestPhone: '+1 (555) 382-9014',
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: FypFeedPage(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Open Bookings sheet
      await tester.tap(find.text('Bookings'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify My Travel Bookings sheet displays the newly booked hotel
      expect(find.text('MY TRAVEL BOOKINGS'), findsOneWidget);
      expect(find.text('The Retreat Hotel at Blue Lagoon'), findsWidgets);
      expect(find.textContaining('#AP-ICE-7721'), findsOneWidget);
      expect(find.text('Guest: Alex Mercer'), findsOneWidget);
    });

    testWidgets('supports multi-person grouped trip booking with live split calculation, companion squad autofill, and group badge in bookings', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    NearbyHotelsSheet.show(context, destination: sampleDestination);
                  },
                  child: const Text('Open Stays'),
                );
              },
            ),
          ),
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Open Stays'));
      await tester.pumpAndSettle();

      // Tap "Book Now"
      final bookNowFinder = find.text('Book Now').first;
      await tester.scrollUntilVisible(bookNowFinder, 300, scrollable: find.byType(Scrollable).last);
      await tester.pumpAndSettle();
      await tester.tap(bookNowFinder);
      await tester.pumpAndSettle();

      // Verify date & group size selection step
      expect(find.text('when do you wanna come ?'), findsOneWidget);
      expect(find.text('TRAVELERS & GROUP TRIP'), findsOneWidget);

      // Tap Squad (4) preset chip
      await tester.tap(find.text('Squad (4)'));
      await tester.pumpAndSettle();

      // Verify group trip badge & live split pricing
      expect(find.text('GROUP TRIP'), findsWidgets);
      expect(find.textContaining('OpenClaw AI Split Cost:'), findsOneWidget);

      // Tap Continue to Documents
      await tester.tap(find.text('Confirm Dates & Continue to Documents (4 Travelers)'));
      await tester.pumpAndSettle();

      // Verify group trip documents screen shows primary guest and companion squad
      expect(find.text('LEAD TRAVELER (PRIMARY GUEST)'), findsOneWidget);
      expect(find.textContaining('TRAVEL SQUAD COMPANIONS (3)'), findsOneWidget);
      expect(find.text('Traveler 2 Details'), findsOneWidget);
      expect(find.text('Traveler 3 Details'), findsOneWidget);
      expect(find.text('Traveler 4 Details'), findsOneWidget);

      // Tap "Yes, Autofill"
      await tester.tap(find.text('Yes, Autofill'));
      await tester.pumpAndSettle();

      // Verify lead and squad companions are autofilled
      expect(find.text('Alex Mercer'), findsOneWidget);
      expect(find.text('Maya Lin'), findsOneWidget);
      expect(find.text('Jordan Hayes'), findsOneWidget);
      expect(find.text('Chloe Bennett'), findsOneWidget);

      // Tap Proceed
      await tester.tap(find.text('Verify & Proceed'));
      await tester.pump();

      // Advance clock past submission delay
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      // Verify Booking Successful screen displays group trip roster & split cost
      expect(find.text('Booking Successful!'), findsOneWidget);
      expect(find.textContaining('SQUAD ROSTER (4):'), findsOneWidget);
      expect(find.text('Alex Mercer (Lead)'), findsOneWidget);
      expect(find.text('Maya Lin'), findsWidgets);

      // Close sheet
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    });
  });
}

