import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/travel_booking.dart';
import '../models/travel_destination.dart';
import '../models/group_chat.dart';
import '../pages/group_chat_detail_page.dart';
import '../theme/app_theme.dart';

enum _BookingStage {
  dateSelection,
  documents,
  submitting,
  successful,
}

class HotelBookingFlowSheet extends StatefulWidget {
  final HotelItem hotel;
  final TravelDestination destination;
  final int stayNights;
  final VoidCallback? onOpenBookings;

  const HotelBookingFlowSheet({
    super.key,
    required this.hotel,
    required this.destination,
    this.stayNights = 3,
    this.onOpenBookings,
  });

  static Future<void> show(
    BuildContext context, {
    required HotelItem hotel,
    required TravelDestination destination,
    int stayNights = 3,
    VoidCallback? onOpenBookings,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HotelBookingFlowSheet(
        hotel: hotel,
        destination: destination,
        stayNights: stayNights,
        onOpenBookings: onOpenBookings,
      ),
    );
  }

  @override
  State<HotelBookingFlowSheet> createState() => _HotelBookingFlowSheetState();
}

class _HotelBookingFlowSheetState extends State<HotelBookingFlowSheet> {
  _BookingStage _stage = _BookingStage.dateSelection;
  bool _isAutofilled = false;

  // Travel Date Selection State (Year, Month, Day)
  int _selectedYear = 2026;
  int _selectedMonth = 10; // 1 to 12
  int _selectedDay = 15;

  // Grouped Trip / Multi-person State
  int _guestCount = 1; // Default to Solo (1); quick presets Duo (2), Squad (4), Group (6) available
  bool get _isGroupTrip => _guestCount > 1;

  final List<Map<String, TextEditingController>> _companionControllers = [];

  static const List<Map<String, String>> _squadProfiles = [
    {'name': 'Maya Lin', 'passport': 'P74201948', 'nationality': 'Canada'},
    {'name': 'Jordan Hayes', 'passport': 'P61904823', 'nationality': 'United Kingdom'},
    {'name': 'Chloe Bennett', 'passport': 'P55018420', 'nationality': 'Australia'},
    {'name': 'Liam O\'Connor', 'passport': 'P48291034', 'nationality': 'Ireland'},
    {'name': 'Elena Rostova', 'passport': 'P99102451', 'nationality': 'Germany'},
  ];

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static const List<int> _availableYears = [2026, 2027, 2028];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passportController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _requestsController = TextEditingController();

  late String _generatedBookingRef;
  late String _calculatedTotal;
  String _submissionStatusText = 'Encrypting traveler credentials...';
  Timer? _statusTimer;

  int get _maxDaysInCurrentMonth {
    return DateTime(_selectedYear, _selectedMonth + 1, 0).day;
  }

  String _getDayOfWeek(int year, int month, int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dt = DateTime(year, month, day);
    return days[dt.weekday - 1];
  }

  String get _formattedSelectedDates {
    final checkIn = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    final checkOut = checkIn.add(Duration(days: widget.stayNights));
    return '${_monthNames[checkIn.month - 1]} ${checkIn.day} – ${_monthNames[checkOut.month - 1]} ${checkOut.day}, ${checkOut.year} (${widget.stayNights} nights)';
  }

  String get _calculatedPerPersonSplit {
    final total = widget.hotel.pricePerNight * widget.stayNights;
    final split = total / _guestCount;
    return '${widget.hotel.currency}${split.toStringAsFixed(0)} / person';
  }

  void _syncCompanionControllers() {
    final needed = math.max(0, _guestCount - 1);
    while (_companionControllers.length < needed) {
      _companionControllers.add({
        'name': TextEditingController(),
        'passport': TextEditingController(),
        'nationality': TextEditingController(),
      });
    }
    while (_companionControllers.length > needed) {
      final removed = _companionControllers.removeLast();
      removed['name']?.dispose();
      removed['passport']?.dispose();
      removed['nationality']?.dispose();
    }
  }

  List<String> get _allGroupMemberNames {
    final lead = _nameController.text.isNotEmpty ? '${_nameController.text} (Lead)' : 'Alex Mercer (Lead)';
    final list = <String>[lead];
    for (int i = 0; i < _companionControllers.length; i++) {
      final name = _companionControllers[i]['name']?.text.trim();
      if (name != null && name.isNotEmpty) {
        list.add(name);
      } else {
        list.add(_squadProfiles[i % _squadProfiles.length]['name']!);
      }
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    final randomDigits = (1000 + math.Random().nextInt(9000)).toString();
    final cityPrefix = widget.destination.cityCountry.length >= 3
        ? widget.destination.cityCountry.substring(0, 3).toUpperCase()
        : 'RES';
    _generatedBookingRef = '#AP-$cityPrefix-$randomDigits';
    final total = widget.hotel.pricePerNight * widget.stayNights;
    _calculatedTotal = '${widget.hotel.currency}${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    _syncCompanionControllers();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _nameController.dispose();
    _passportController.dispose();
    _nationalityController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _requestsController.dispose();
    for (final companion in _companionControllers) {
      companion['name']?.dispose();
      companion['passport']?.dispose();
      companion['nationality']?.dispose();
    }
    super.dispose();
  }

  void _handleAutofill() {
    setState(() {
      _isAutofilled = true;
      _nameController.text = 'Alex Mercer';
      _passportController.text = 'P89421054';
      _nationalityController.text = 'United States';
      _dobController.text = '1994-08-14';
      _emailController.text = 'alex.mercer@aperture.ai';
      _phoneController.text = '+1 (555) 382-9014';
      _requestsController.text = 'High floor, adjoining suites if available';

      // Autofill companions for group trip
      for (int i = 0; i < _companionControllers.length; i++) {
        final profile = _squadProfiles[i % _squadProfiles.length];
        _companionControllers[i]['name']?.text = profile['name']!;
        _companionControllers[i]['passport']?.text = profile['passport']!;
        _companionControllers[i]['nationality']?.text = profile['nationality']!;
      }
    });
  }

  void _handleProceed() {
    setState(() {
      _stage = _BookingStage.submitting;
      _submissionStatusText = _isGroupTrip
          ? 'Submitting group itinerary & traveler passports...'
          : 'Submitted documents to OpenClaw Booking Engine...';
    });

    // Simulated multi-stage cyber reservation process
    _statusTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _submissionStatusText = _isGroupTrip
              ? 'Locking group suites & syncing split cost rate...'
              : 'Locking room allotment & AI concierge rate...';
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;

      // Create new booking and save to TravelBookingsManager
      final newBooking = TravelBooking(
        id: 'bk-${DateTime.now().millisecondsSinceEpoch}',
        destinationTitle: '${widget.destination.cityCountry} ${widget.destination.flagEmoji}',
        hotelName: widget.hotel.name,
        roomType: widget.hotel.roomType,
        dates: _formattedSelectedDates,
        bookingRef: _generatedBookingRef,
        totalPrice: _calculatedTotal,
        status: 'CONFIRMED',
        statusColor: AppTheme.cyberEmerald,
        guestName: _nameController.text.isNotEmpty ? _nameController.text : 'Alex Mercer',
        guestPassport: _passportController.text.isNotEmpty ? _passportController.text : 'P89421054',
        guestNationality: _nationalityController.text.isNotEmpty ? _nationalityController.text : 'United States',
        guestEmail: _emailController.text.isNotEmpty ? _emailController.text : 'alex.mercer@aperture.ai',
        guestPhone: _phoneController.text.isNotEmpty ? _phoneController.text : '+1 (555) 382-9014',
        specialRequests: _requestsController.text,
        createdAt: DateTime.now(),
        hotelImageUrl: widget.hotel.imageUrl,
        guestCount: _guestCount,
        isGroupTrip: _isGroupTrip,
        groupMembers: _allGroupMemberNames,
        perPersonPrice: _calculatedPerPersonSplit,
      );

      TravelBookingsManager.instance.addBooking(newBooking);

      setState(() {
        _stage = _BookingStage.successful;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: AppTheme.midnightObsidian,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppTheme.vapourIon.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.vapourIon.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: -2,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Grab Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.frameBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header Row
            _buildHeader(),
            const SizedBox(height: 14),

            // Main Stage Switcher
            if (_stage == _BookingStage.dateSelection) ...[
              _buildDateSelectionStage(),
            ] else if (_stage == _BookingStage.documents) ...[
              _buildDocumentsStage(),
            ] else if (_stage == _BookingStage.submitting) ...[
              _buildSubmittingStage(),
            ] else ...[
              _buildSuccessfulStage(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title = 'RESERVATION GATEWAY';
    String subtitle = 'Fill up required documents & guest telemetry';

    if (_stage == _BookingStage.dateSelection) {
      title = _isGroupTrip ? 'GROUP TRIP RESERVATION' : 'SELECT TRAVEL DATES';
      subtitle = 'When do you wanna come? Choose year, month, day & group';
    } else if (_stage == _BookingStage.documents) {
      title = _isGroupTrip ? 'GROUP TRAVEL SQUAD' : 'REQUIRED DOCUMENTS';
      subtitle = 'Guest telemetry & passport credentials';
    } else if (_stage == _BookingStage.successful) {
      title = 'BOOKING CONFIRMED';
      subtitle = 'Itinerary confirmed via OpenClaw Concierge';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.cinemaSlate,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _stage == _BookingStage.dateSelection
                      ? (_isGroupTrip ? Icons.groups_rounded : Icons.calendar_month_rounded)
                      : Icons.hotel_class_rounded,
                  color: AppTheme.vapourIon,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.ghostIce,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.cinemaSlate,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.frameBorder),
            ),
            child: const Icon(Icons.close_rounded, color: AppTheme.mutedPhosphor, size: 16),
          ),
        ),
      ],
    );
  }

  /// 1. First Step: When do you wanna come? Show Year, Month, Day, and Group Size
  Widget _buildDateSelectionStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hotel & Itinerary Summary Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.frameBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.slateCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.vapourIon.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Text(widget.destination.flagEmoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.hotel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.ghostIce,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${widget.hotel.roomType} • ${widget.destination.cityCountry}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.stayNights} Nights • $_guestCount ${_guestCount == 1 ? 'Guest' : 'Travelers'}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.vapourIon,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          'Total: $_calculatedTotal',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.solarAmber,
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // OpenClaw AI Prompt: "when do you wanna come ?"
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.solarAmber.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.solarAmber.withValues(alpha: 0.6),
              width: 1.1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppTheme.midnightObsidian,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.solarAmber),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppTheme.solarAmber,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OPENCLAW AI CONCIERGE',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.solarAmber,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'when do you wanna come ?',
                          style: TextStyle(
                            color: AppTheme.ghostIce,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Select your arrival year, month, and day for ${widget.destination.cityCountry}. Multi-person grouped trips are supported!',
                style: const TextStyle(
                  color: AppTheme.mutedPhosphor,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 1. YEAR SELECTOR
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: AppTheme.vapourIon, size: 14),
                SizedBox(width: 6),
                Text(
                  'YEAR',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.vapourIon,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            Text(
              'Selected: $_selectedYear',
              style: const TextStyle(
                fontFamily: 'monospace',
                color: AppTheme.ghostIce,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: _availableYears.map((year) {
            final isSelected = year == _selectedYear;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedYear = year;
                    if (_selectedDay > _maxDaysInCurrentMonth) {
                      _selectedDay = _maxDaysInCurrentMonth;
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.vapourIon : AppTheme.cinemaSlate,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppTheme.vapourIon : AppTheme.frameBorder,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$year',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: isSelected ? AppTheme.midnightObsidian : AppTheme.ghostIce,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 14),

        // 2. MONTH SELECTOR
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.date_range_rounded, color: AppTheme.solarAmber, size: 14),
                SizedBox(width: 6),
                Text(
                  'MONTH',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.solarAmber,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            Text(
              '${_monthNames[_selectedMonth - 1]} ($_selectedMonth)',
              style: const TextStyle(
                fontFamily: 'monospace',
                color: AppTheme.ghostIce,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(12, (index) {
              final monthNum = index + 1;
              final isSelected = monthNum == _selectedMonth;
              final isPrime = widget.destination.optimalMonthNumbers.contains(monthNum);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMonth = monthNum;
                    if (_selectedDay > _maxDaysInCurrentMonth) {
                      _selectedDay = _maxDaysInCurrentMonth;
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.solarAmber : AppTheme.cinemaSlate,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.solarAmber
                          : isPrime
                              ? AppTheme.cyberEmerald.withValues(alpha: 0.5)
                              : AppTheme.frameBorder,
                      width: isPrime && !isSelected ? 1.2 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _monthNames[index],
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: isSelected ? AppTheme.midnightObsidian : AppTheme.ghostIce,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (isPrime) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? AppTheme.midnightObsidian : AppTheme.cyberEmerald,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 14),

        // 3. DAY SELECTOR
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.today_rounded, color: AppTheme.cyberEmerald, size: 14),
                SizedBox(width: 6),
                Text(
                  'DAY',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.cyberEmerald,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            Text(
              'Day $_selectedDay (${_getDayOfWeek(_selectedYear, _selectedMonth, _selectedDay)})',
              style: const TextStyle(
                fontFamily: 'monospace',
                color: AppTheme.ghostIce,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_maxDaysInCurrentMonth, (index) {
              final dayNum = index + 1;
              final isSelected = dayNum == _selectedDay;
              final dayOfWeek = _getDayOfWeek(_selectedYear, _selectedMonth, dayNum);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = dayNum;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.cyberEmerald : AppTheme.cinemaSlate,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppTheme.cyberEmerald : AppTheme.frameBorder,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dayOfWeek,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: isSelected ? AppTheme.midnightObsidian : AppTheme.mutedPhosphor,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: isSelected ? AppTheme.midnightObsidian : AppTheme.ghostIce,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 16),

        // 4. GROUP SIZE & MULTI-PERSON TRIP SELECTOR
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.groups_rounded, color: AppTheme.solarAmber, size: 16),
                  const SizedBox(width: 6),
                  const Flexible(
                    child: Text(
                      'TRAVELERS & GROUP TRIP',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.solarAmber,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  if (_isGroupTrip) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppTheme.solarAmber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'GROUP TRIP',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.solarAmber,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$_guestCount ${_guestCount == 1 ? 'Guest' : 'Travelers'}',
              style: const TextStyle(
                fontFamily: 'monospace',
                color: AppTheme.ghostIce,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Stepper & Quick Presets Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isGroupTrip ? AppTheme.solarAmber.withValues(alpha: 0.5) : AppTheme.frameBorder,
            ),
          ),
          child: Row(
            children: [
              // Stepper controls
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.midnightObsidian,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.frameBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_rounded, size: 16),
                      color: _guestCount > 1 ? AppTheme.ghostIce : AppTheme.mutedPhosphor.withValues(alpha: 0.4),
                      onPressed: _guestCount > 1
                          ? () {
                              setState(() {
                                _guestCount--;
                                _syncCompanionControllers();
                              });
                            }
                          : null,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$_guestCount',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.ghostIce,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, size: 16),
                      color: _guestCount < 12 ? AppTheme.ghostIce : AppTheme.mutedPhosphor.withValues(alpha: 0.4),
                      onPressed: _guestCount < 12
                          ? () {
                              setState(() {
                                _guestCount++;
                                _syncCompanionControllers();
                              });
                            }
                          : null,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Quick Presets
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  children: [
                    _buildPresetChip(label: 'Solo (1)', count: 1),
                    _buildPresetChip(label: 'Duo (2)', count: 2),
                    _buildPresetChip(label: 'Squad (4)', count: 4),
                    _buildPresetChip(label: 'Group (6)', count: 6),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Live Split Pricing for Group Trips
        if (_isGroupTrip) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.solarAmber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.solarAmber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: AppTheme.solarAmber, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '⚡ OpenClaw AI Split Cost: $_calculatedPerPersonSplit ($_calculatedTotal total for $_guestCount travelers)',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.solarAmber,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Chosen Date & Group Trip Preview Strip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.midnightObsidian,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.vapourIon.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(
                _isGroupTrip ? Icons.group_rounded : Icons.flight_land_rounded,
                color: AppTheme.vapourIon,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-in: ${_monthNames[_selectedMonth - 1]} $_selectedDay, $_selectedYear',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.ghostIce,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_isGroupTrip ? '👥 Group Trip • ' : ''}$_formattedSelectedDates • $_guestCount Guests',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.mutedPhosphor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _calculatedTotal,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.solarAmber,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  if (_isGroupTrip)
                    Text(
                      _calculatedPerPersonSplit,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.mutedPhosphor,
                        fontSize: 9.5,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Next CTA: Continue to Form with Autofill
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.vapourIon,
              foregroundColor: AppTheme.midnightObsidian,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 3,
            ),
            onPressed: () {
              setState(() {
                _stage = _BookingStage.documents;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    _guestCount == 1
                        ? 'Confirm Dates & Continue to Documents'
                        : 'Confirm Dates & Continue to Documents ($_guestCount Travelers)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Option to create group booking link where everyone books individually
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.solarAmber,
              side: BorderSide(color: AppTheme.solarAmber.withValues(alpha: 0.7)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            icon: const Icon(Icons.add_link_rounded, size: 16),
            label: Text(
              _isGroupTrip
                  ? '🔗 Create Group Link (Book Individually)'
                  : '🔗 Create Group Booking Link for Squad',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
              ),
            ),
            onPressed: _showCreateGroupBookingLinkModal,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip({required String label, required int count}) {
    final isSelected = _guestCount == count;
    return GestureDetector(
      onTap: () {
        setState(() {
          _guestCount = count;
          _syncCompanionControllers();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.solarAmber : AppTheme.midnightObsidian,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppTheme.solarAmber : AppTheme.frameBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'monospace',
            color: isSelected ? AppTheme.midnightObsidian : AppTheme.ghostIce,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 2. Second Step: The form with autofill prompt & multi-person document fields
  Widget _buildDocumentsStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date & Group Trip Pill Banner with Change Option
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.frameBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      _isGroupTrip ? Icons.groups_rounded : Icons.date_range_rounded,
                      color: AppTheme.vapourIon,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${_isGroupTrip ? '👥 Group Trip ($_guestCount Guests) • ' : ''}$_formattedSelectedDates',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.ghostIce,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _stage = _BookingStage.dateSelection;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.vapourIon.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.vapourIon,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // OpenClaw AI Prompt: "would you like to autofill the items?"
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isAutofilled
                ? AppTheme.cyberEmerald.withValues(alpha: 0.08)
                : AppTheme.solarAmber.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isAutofilled
                  ? AppTheme.cyberEmerald.withValues(alpha: 0.6)
                  : AppTheme.solarAmber.withValues(alpha: 0.6),
              width: 1.1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppTheme.midnightObsidian,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isAutofilled ? AppTheme.cyberEmerald : AppTheme.solarAmber,
                      ),
                    ),
                    child: Icon(
                      _isAutofilled ? Icons.verified_user_rounded : Icons.auto_awesome,
                      color: _isAutofilled ? AppTheme.cyberEmerald : AppTheme.solarAmber,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isAutofilled ? 'VERIFIED OPENCLAW PROFILE' : 'OPENCLAW AI CONCIERGE',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: _isAutofilled ? AppTheme.cyberEmerald : AppTheme.solarAmber,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _isAutofilled
                              ? 'Items autofilled from your OpenClaw Profile! Please verify your information before proceeding.'
                              : 'would you like to autofill the items?',
                          style: const TextStyle(
                            color: AppTheme.ghostIce,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!_isAutofilled) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.solarAmber,
                          foregroundColor: AppTheme.midnightObsidian,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: _handleAutofill,
                        icon: const Icon(Icons.bolt_rounded, size: 16),
                        label: Text(
                          _isGroupTrip ? 'Yes, Autofill Travel Squad' : 'Yes, Autofill',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.frameBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in required traveler credentials below.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Text(
                        'Manual Entry',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.mutedPhosphor,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section Title: Primary / Lead Traveler
        Row(
          children: [
            const Icon(Icons.person_pin_rounded, color: AppTheme.vapourIon, size: 15),
            const SizedBox(width: 6),
            Text(
              _isGroupTrip ? 'LEAD TRAVELER (PRIMARY GUEST)' : 'REQUIRED TRAVEL DOCUMENTS',
              style: const TextStyle(
                fontFamily: 'monospace',
                color: AppTheme.vapourIon,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            const Spacer(),
            if (_isAutofilled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.cyberEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'READY TO VERIFY',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.cyberEmerald,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        // Primary Document Form Fields
        _buildInputField(
          label: 'FULL LEGAL NAME (PASSPORT)',
          controller: _nameController,
          hint: 'e.g. Alex Mercer',
          icon: Icons.person_rounded,
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildInputField(
                label: 'PASSPORT / ID NUMBER',
                controller: _passportController,
                hint: 'e.g. P89421054',
                icon: Icons.badge_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInputField(
                label: 'NATIONALITY',
                controller: _nationalityController,
                hint: 'e.g. United States',
                icon: Icons.public_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildInputField(
                label: 'DATE OF BIRTH',
                controller: _dobController,
                hint: '1994-08-14',
                icon: Icons.cake_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInputField(
                label: 'PHONE NUMBER',
                controller: _phoneController,
                hint: '+1 (555) 382-9014',
                icon: Icons.phone_android_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        _buildInputField(
          label: 'CONTACT EMAIL (E-TICKET / VOUCHER)',
          controller: _emailController,
          hint: 'alex.mercer@aperture.ai',
          icon: Icons.alternate_email_rounded,
        ),

        // Multi-Person Group Companions Section
        if (_isGroupTrip) ...[
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.groups_rounded, color: AppTheme.solarAmber, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'TRAVEL SQUAD COMPANIONS (${_companionControllers.length})',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.solarAmber,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _guestCount++;
                    _syncCompanionControllers();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppTheme.solarAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.solarAmber.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: AppTheme.solarAmber, size: 12),
                      SizedBox(width: 3),
                      Text(
                        'Add Traveler',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.solarAmber,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Companion Cards
          ...List.generate(_companionControllers.length, (index) {
            final companion = _companionControllers[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.slateCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.frameBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Traveler ${index + 2} Details',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.ghostIce,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _isAutofilled ? 'Autofilled' : 'Guest',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: _isAutofilled ? AppTheme.cyberEmerald : AppTheme.mutedPhosphor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInputField(
                    label: 'FULL NAME',
                    controller: companion['name']!,
                    hint: 'e.g. Maya Lin',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          label: 'PASSPORT / ID',
                          controller: companion['passport']!,
                          hint: 'e.g. P74201948',
                          icon: Icons.badge_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInputField(
                          label: 'NATIONALITY',
                          controller: companion['nationality']!,
                          hint: 'e.g. Canada',
                          icon: Icons.public_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: 8),

        _buildInputField(
          label: 'SPECIAL REQUESTS / PREFERENCES',
          controller: _requestsController,
          hint: 'Adjoining rooms, high floor, late check-in',
          icon: Icons.room_service_rounded,
        ),

        const SizedBox(height: 18),

        // Verification & Proceed CTA
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isAutofilled ? AppTheme.cyberEmerald : AppTheme.vapourIon,
              foregroundColor: AppTheme.midnightObsidian,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 3,
            ),
            onPressed: _handleProceed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isAutofilled ? Icons.check_circle_outline_rounded : Icons.arrow_forward_rounded,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _isAutofilled
                      ? (_isGroupTrip ? 'Verify Squad & Proceed' : 'Verify & Proceed')
                      : 'Proceed',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 3. Third Step: Submitted + Animated Loading Spinner
  Widget _buildSubmittingStage() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.solarAmber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.solarAmber.withValues(alpha: 0.5)),
              ),
              child: Text(
                _isGroupTrip ? 'GROUP RESERVATION SUBMITTED' : 'SUBMITTED',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: AppTheme.solarAmber,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Cyberpunk Loading Spinner
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.vapourIon.withValues(alpha: 0.25),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 54,
                  height: 54,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.vapourIon),
                  ),
                ),
                Icon(
                  _isGroupTrip ? Icons.groups_rounded : Icons.vpn_key_rounded,
                  color: AppTheme.solarAmber,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Submitted',
              style: TextStyle(
                color: AppTheme.ghostIce,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              _submissionStatusText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: AppTheme.mutedPhosphor,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.slateCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.frameBorder),
              ),
              child: Text(
                'Booking Ref: $_generatedBookingRef',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: AppTheme.vapourIon,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 4. Fourth Step: Booking Successful Confirmation & Output
  Widget _buildSuccessfulStage() {
    final members = _allGroupMemberNames;

    return Column(
      children: [
        const SizedBox(height: 10),

        // Glowing Success Badge
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.cyberEmerald, Color(0xFF00897B)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cyberEmerald.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: AppTheme.midnightObsidian, size: 36),
        ),
        const SizedBox(height: 16),

        const Text(
          'Booking Successful!',
          style: TextStyle(
            color: AppTheme.ghostIce,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),

        Text(
          _isGroupTrip
              ? 'Group trip for $_guestCount travelers confirmed & synced to Bookings!'
              : 'Your stay has been confirmed and output to your Bookings section',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.ghostIce.withValues(alpha: 0.8), fontSize: 12),
        ),

        const SizedBox(height: 16),

        // Confirmed Ticket Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.slateCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.cyberEmerald.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.destination.cityCountry} ${widget.destination.flagEmoji}',
                    style: const TextStyle(
                      color: AppTheme.solarAmber,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isGroupTrip) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.solarAmber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'GROUP TRIP ($_guestCount)',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: AppTheme.solarAmber,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.cyberEmerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'CONFIRMED',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.cyberEmerald,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.hotel.name,
                style: const TextStyle(
                  color: AppTheme.ghostIce,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                widget.hotel.roomType,
                style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11.5),
              ),
              const Divider(color: AppTheme.frameBorder, height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildTicketData('LEAD GUEST', _nameController.text.isNotEmpty ? _nameController.text : 'Alex Mercer')),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTicketData('PASSPORT', _passportController.text.isNotEmpty ? _passportController.text : 'P89421054')),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTicketData('BOOKING REF', _generatedBookingRef)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildTicketData('DATES', _formattedSelectedDates)),
                  const SizedBox(width: 8),
                  _buildTicketData('TOTAL PAID', _calculatedTotal),
                ],
              ),

              // Group members roster
              if (_isGroupTrip) ...[
                const SizedBox(height: 10),
                const Divider(color: AppTheme.frameBorder, height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SQUAD ROSTER (${members.length}):',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.solarAmber,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Split: $_calculatedPerPersonSplit',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.cyberEmerald,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: members.map((member) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.midnightObsidian,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.frameBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person, color: AppTheme.vapourIon, size: 10),
                          const SizedBox(width: 3),
                          Text(
                            member,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: AppTheme.ghostIce,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Action Buttons: View in Bookings & Done
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.vapourIon,
                  foregroundColor: AppTheme.midnightObsidian,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onOpenBookings?.call();
                },
                icon: const Icon(Icons.confirmation_number_rounded, size: 16),
                label: const Text(
                  'View in Bookings',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.frameBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: AppTheme.ghostIce,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.solarAmber,
              side: BorderSide(color: AppTheme.solarAmber.withValues(alpha: 0.6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            icon: const Icon(Icons.share_rounded, size: 16),
            label: const Text(
              '🔗 Share Group Booking Link to Squad',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
              ),
            ),
            onPressed: _showCreateGroupBookingLinkModal,
          ),
        ),
      ],
    );
  }

  void _showCreateGroupBookingLinkModal() {
    final chats = GroupChatRepository.instance.chats;
    if (chats.isEmpty) return;

    String selectedChatId = chats.first.id;
    int spots = _guestCount > 1 ? _guestCount : 4;
    final totalStayPrice = widget.hotel.pricePerNight * widget.stayNights;
    double perPerson = totalStayPrice / spots;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              decoration: const BoxDecoration(
                color: AppTheme.cinemaSlate,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppTheme.solarAmber, width: 1.5)),
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
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.solarAmber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add_link_rounded, color: AppTheme.solarAmber, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Group Booking Link',
                              style: TextStyle(
                                color: AppTheme.ghostIce,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Members use link to book & pay individually',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: AppTheme.mutedPhosphor,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Destination & Property Summary
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.midnightObsidian,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.frameBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.hotel_class_rounded, color: AppTheme.vapourIon, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.hotel.name,
                                style: const TextStyle(
                                  color: AppTheme.ghostIce,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${widget.destination.cityCountry} • $_formattedSelectedDates',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: AppTheme.mutedPhosphor,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Spots & Split Cost Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SQUAD SPOTS',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: AppTheme.mutedPhosphor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.midnightObsidian,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.frameBorder),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_rounded, size: 16),
                                    color: spots > 2 ? AppTheme.ghostIce : AppTheme.mutedPhosphor.withValues(alpha: 0.4),
                                    onPressed: spots > 2
                                        ? () {
                                            setModalState(() {
                                              spots--;
                                              perPerson = totalStayPrice / spots;
                                            });
                                          }
                                        : null,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  ),
                                  Text(
                                    '$spots spots',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      color: AppTheme.ghostIce,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_rounded, size: 16),
                                    color: spots < 16 ? AppTheme.ghostIce : AppTheme.mutedPhosphor.withValues(alpha: 0.4),
                                    onPressed: spots < 16
                                        ? () {
                                            setModalState(() {
                                              spots++;
                                              perPerson = totalStayPrice / spots;
                                            });
                                          }
                                        : null,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'INDIVIDUAL SHARE',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: AppTheme.mutedPhosphor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.midnightObsidian,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.solarAmber.withValues(alpha: 0.5)),
                              ),
                              child: Center(
                                child: Text(
                                  '${widget.hotel.currency}${perPerson.toStringAsFixed(0)} / pax',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    color: AppTheme.solarAmber,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Select Travel Squad
                  const Text(
                    'SHARE TO SQUAD CHAT',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.mutedPhosphor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.midnightObsidian,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.frameBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedChatId,
                        isExpanded: true,
                        dropdownColor: AppTheme.cinemaSlate,
                        style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                        items: chats.map((c) {
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Row(
                              children: [
                                Text(c.destinationTag, style: const TextStyle(fontSize: 12)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    c.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedChatId = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.solarAmber,
                        foregroundColor: AppTheme.midnightObsidian,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text(
                        'POST GROUP BOOKING LINK TO SQUAD',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      onPressed: () {
                        final chosenChat = chats.firstWhere((c) => c.id == selectedChatId);
                        final prefix = widget.destination.cityCountry.length >= 3
                            ? widget.destination.cityCountry.substring(0, 3).toUpperCase()
                            : 'GRP';
                        final randomRef = '#GRP-$prefix-${1000 + math.Random().nextInt(9000)}';
                        final bookingInfo = GroupBookingLinkInfo(
                          id: 'gbl-${DateTime.now().millisecondsSinceEpoch}',
                          title: '${widget.hotel.name} Group Booking',
                          hotelOrStayName: widget.hotel.name,
                          destination: widget.destination.cityCountry,
                          dates: _formattedSelectedDates,
                          pricePerPerson: perPerson,
                          currency: widget.hotel.currency,
                          totalSpots: spots,
                          bookedMembers: const [],
                          allMembers: chosenChat.memberNames,
                          bookingRef: randomRef,
                          shareableUrl: 'https://aperture.travel/grp/${randomRef.replaceAll('#', '').toLowerCase()}',
                          createdBy: 'You',
                          createdAt: DateTime.now(),
                        );

                        GroupChatRepository.instance.createGroupBookingLink(selectedChatId, bookingInfo);
                        Navigator.pop(context); // close modal

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.cinemaSlate,
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppTheme.cyberEmerald, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Group link created & posted to ${chosenChat.title}!',
                                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            action: SnackBarAction(
                              label: 'OPEN CHAT',
                              textColor: AppTheme.solarAmber,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GroupChatDetailPage(chatId: selectedChatId),
                                  ),
                                );
                              },
                            ),
                          ),
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
  }

  Widget _buildTicketData(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: AppTheme.mutedPhosphor,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: AppTheme.ghostIce,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: AppTheme.mutedPhosphor,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(
            color: AppTheme.ghostIce,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.vapourIon, size: 15),
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.mutedPhosphor.withValues(alpha: 0.6),
              fontSize: 11.5,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            filled: true,
            fillColor: AppTheme.cinemaSlate,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.frameBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.frameBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.vapourIon),
            ),
          ),
        ),
      ],
    );
  }
}
