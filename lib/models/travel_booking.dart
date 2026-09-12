import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TravelBooking {
  final String id;
  final String destinationTitle;
  final String hotelName;
  final String roomType;
  final String dates;
  final String bookingRef;
  final String totalPrice;
  final String status;
  final Color statusColor;
  final String guestName;
  final String guestPassport;
  final String guestNationality;
  final String guestEmail;
  final String guestPhone;
  final String? specialRequests;
  final DateTime createdAt;
  final String? hotelImageUrl;
  final int guestCount;
  final bool isGroupTrip;
  final List<String> groupMembers;
  final String? perPersonPrice;

  const TravelBooking({
    required this.id,
    required this.destinationTitle,
    required this.hotelName,
    required this.roomType,
    required this.dates,
    required this.bookingRef,
    required this.totalPrice,
    this.status = 'CONFIRMED',
    this.statusColor = AppTheme.cyberEmerald,
    required this.guestName,
    required this.guestPassport,
    required this.guestNationality,
    required this.guestEmail,
    required this.guestPhone,
    this.specialRequests,
    required this.createdAt,
    this.hotelImageUrl,
    this.guestCount = 2,
    this.isGroupTrip = false,
    this.groupMembers = const [],
    this.perPersonPrice,
  });
}

class TravelBookingsManager extends ChangeNotifier {
  static final TravelBookingsManager instance = TravelBookingsManager._internal();

  TravelBookingsManager._internal() {
    _initStarterBookings();
  }

  final List<TravelBooking> _bookings = [];

  List<TravelBooking> get bookings => List.unmodifiable(_bookings);

  void _initStarterBookings() {
    _bookings.clear();
    _bookings.addAll([
      TravelBooking(
        id: 'bk-starter-1',
        destinationTitle: 'Kyoto, Japan 🇯🇵',
        hotelName: 'Suiran, A Luxury Collection Hotel',
        roomType: 'Shirosumire Riverview Suite',
        dates: 'Oct 12 – Oct 15, 2026 (3 nights)',
        bookingRef: '#AP-KYT-9042',
        totalPrice: '\$1,440',
        status: 'CONFIRMED',
        statusColor: AppTheme.cyberEmerald,
        guestName: 'Alex Mercer',
        guestPassport: 'P89421054',
        guestNationality: 'United States',
        guestEmail: 'alex.mercer@aperture.ai',
        guestPhone: '+1 (555) 382-9014',
        specialRequests: 'High floor, river view, late check-in',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      TravelBooking(
        id: 'bk-starter-2',
        destinationTitle: 'Grindavík, Iceland 🇮🇸',
        hotelName: 'The Retreat Hotel at Blue Lagoon',
        roomType: 'Lagoon Junior Suite',
        dates: 'Nov 24 – Nov 27, 2026 (3 nights)',
        bookingRef: '#AP-ICE-3810',
        totalPrice: '\$2,670',
        status: 'CONFIRMED',
        statusColor: AppTheme.cyberEmerald,
        guestName: 'Alex Mercer',
        guestPassport: 'P89421054',
        guestNationality: 'United States',
        guestEmail: 'alex.mercer@aperture.ai',
        guestPhone: '+1 (555) 382-9014',
        specialRequests: 'Geothermal bath priority access',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        guestCount: 4,
        isGroupTrip: true,
        groupMembers: ['Alex Mercer (Lead)', 'Maya Lin', 'Jordan Hayes', 'Chloe Bennett'],
        perPersonPrice: '\$667.50 / person',
      ),
    ]);
  }

  void addBooking(TravelBooking booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }

  void resetToStarter() {
    _bookings.clear();
    _initStarterBookings();
    notifyListeners();
  }
}
