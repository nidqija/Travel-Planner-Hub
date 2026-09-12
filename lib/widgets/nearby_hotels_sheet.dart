import 'package:flutter/material.dart';
import '../models/travel_destination.dart';
import '../theme/app_theme.dart';
import 'hotel_booking_flow_sheet.dart';

class NearbyHotelsSheet extends StatefulWidget {
  final TravelDestination destination;
  final VoidCallback? onOpenBookings;

  const NearbyHotelsSheet({
    super.key,
    required this.destination,
    this.onOpenBookings,
  });

  static void show(
    BuildContext context, {
    required TravelDestination destination,
    VoidCallback? onOpenBookings,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => NearbyHotelsSheet(
        destination: destination,
        onOpenBookings: onOpenBookings,
      ),
    );
  }

  @override
  State<NearbyHotelsSheet> createState() => _NearbyHotelsSheetState();
}

class _NearbyHotelsSheetState extends State<NearbyHotelsSheet> {
  String _selectedFilter = 'All Stays';
  late List<HotelItem> _displayHotels;
  int _stayNights = 3;

  final List<String> _filters = [
    'All Stays',
    '⭐ Top Rated',
    '⚡ Best Value',
    '✨ Luxury',
    '📍 Closest',
  ];

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _displayHotels = List.from(widget.destination.hotels);
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      final original = List<HotelItem>.from(widget.destination.hotels);

      switch (filter) {
        case '⭐ Top Rated':
          original.sort((a, b) => b.rating.compareTo(a.rating));
          _displayHotels = original;
          break;
        case '⚡ Best Value':
          original.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
          _displayHotels = original;
          break;
        case '✨ Luxury':
          original.sort((a, b) => b.pricePerNight.compareTo(a.pricePerNight));
          _displayHotels = original;
          break;
        case '📍 Closest':
          original.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
          _displayHotels = original;
          break;
        case 'All Stays':
        default:
          _displayHotels = original;
          break;
      }
    });
  }

  void _handleBookHotel(HotelItem hotel) {
    HotelBookingFlowSheet.show(
      context,
      hotel: hotel,
      destination: widget.destination,
      stayNights: _stayNights,
      onOpenBookings: () {
        Navigator.pop(context);
        widget.onOpenBookings?.call();
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final destination = widget.destination;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: AppTheme.vapourIon,
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              // Top Drag Handle & Close Bar
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.mutedPhosphor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Sheet Header with Destination Name and Filter Chips
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Destination Name & Close Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.midnightObsidian,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.frameBorder),
                          ),
                          child: Text(
                            destination.flagEmoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                destination.locationName,
                                style: const TextStyle(
                                  color: AppTheme.ghostIce,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                destination.cityCountry,
                                style: const TextStyle(
                                  color: AppTheme.solarAmber,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppTheme.mutedPhosphor),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Filter Chips Bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters.map((filter) {
                          final isSelected = filter == _selectedFilter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(filter),
                              selected: isSelected,
                              onSelected: (_) => _applyFilter(filter),
                              backgroundColor: AppTheme.midnightObsidian,
                              selectedColor: AppTheme.vapourIon,
                              checkmarkColor: AppTheme.midnightObsidian,
                              labelStyle: TextStyle(
                                color: isSelected ? AppTheme.midnightObsidian : AppTheme.ghostIce,
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSelected ? AppTheme.vapourIon : AppTheme.frameBorder,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppTheme.frameBorder, height: 1),

              // Scrollable Area: Travel Intelligence Dossier + Hotel Cards
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  // Item 0: AI Travel Intelligence card (Bot talking about this destination)
                  // Item 1: Respective Video Estimate section for this place
                  // Remaining: Hotel cards list
                  itemCount: _displayHotels.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildTravelIntelligenceCard(destination);
                    }
                    if (index == 1) {
                      return _buildDestinationVideoEstimateSection(destination);
                    }
                    final hotel = _displayHotels[index - 2];
                    return _buildHotelCard(hotel);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Respective Video Estimate Section for this Destination Bot
  Widget _buildDestinationVideoEstimateSection(TravelDestination destination) {
    final botHotel = destination.hotels.firstWhere(
      (h) => h.dealBadge == 'AI TOP PICK',
      orElse: () => destination.hotels.first,
    );
    final totalStayCost = botHotel.pricePerNight * _stayNights;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.solarAmber.withValues(alpha: 0.7),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.solarAmber.withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header: Bot Recommendation & Video Estimate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    const Icon(Icons.smart_toy_rounded, color: AppTheme.solarAmber, size: 15),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'VIDEO ESTIMATE • ${destination.locationName.toUpperCase()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.solarAmber,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (botHotel.dealBadge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.vapourIon.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.vapourIon.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    botHotel.dealBadge!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.vapourIon,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Bot recommendation stay card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.midnightObsidian,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.frameBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        botHotel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.ghostIce,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppTheme.solarAmber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${botHotel.rating}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.ghostIce,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  botHotel.roomType,
                  style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Text(
                  botHotel.contextualMatch ?? destination.contextualRecommendation,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.ghostIce.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Calculation Controls: Rate, Stepper, Total
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.slateCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nightly Rate
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rate:', style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 10)),
                    Text(
                      '\$${botHotel.pricePerNight} / nt',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.ghostIce,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                // Nights Stepper
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_stayNights > 1) {
                          setState(() => _stayNights -= 1);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppTheme.cinemaSlate,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.remove, color: AppTheme.ghostIce, size: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$_stayNights nts',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.ghostIce,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_stayNights < 14) {
                          setState(() => _stayNights += 1);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppTheme.cinemaSlate,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.add, color: AppTheme.ghostIce, size: 12),
                      ),
                    ),
                  ],
                ),

                // Calculation Result
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$_stayNights × \$${botHotel.pricePerNight}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.mutedPhosphor,
                        fontSize: 9.5,
                      ),
                    ),
                    Text(
                      '\$$totalStayCost',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.solarAmber,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                // Book Button
                GestureDetector(
                  onTap: () => _handleBookHotel(botHotel),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.vapourIon.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.vapourIon.withValues(alpha: 0.6)),
                    ),
                    child: const Text(
                      'Book',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.vapourIon,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
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

  /// AI Travel Intelligence Card featuring:
  /// 1. Contextual recommendations based on video content
  /// 2. Estimated travel/flight time and arrival times
  /// 3. Optimal visiting months and seasonal climate tracker
  Widget _buildTravelIntelligenceCard(TravelDestination destination) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.midnightObsidian,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.vapourIon.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.vapourIon.withValues(alpha: 0.12),
            blurRadius: 14,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: AI Agent Badge & Vibe Affinity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E2838),
                      ),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: AppTheme.solarAmber,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'OPENCLAW AI CONCIERGE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.vapourIon,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.cyberEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.cyberEmerald.withValues(alpha: 0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: AppTheme.cyberEmerald, size: 10),
                    SizedBox(width: 3),
                    Text(
                      'AI VERIFIED',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.cyberEmerald,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 1. Contextual Recommendation Highlight Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.slateCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.frameBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.solarAmber, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'CONTEXTUAL RECOMMENDATION',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.solarAmber.withValues(alpha: 0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  destination.contextualRecommendation,
                  style: const TextStyle(
                    color: AppTheme.ghostIce,
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '⚡ Match Vector: ${destination.vibeMatchReason}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.mutedPhosphor,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 2. Estimated Travel & Arrival Times Section
          Row(
            children: [
              Expanded(
                child: _buildTelemetryBlock(
                  icon: Icons.flight_takeoff_rounded,
                  iconColor: AppTheme.vapourIon,
                  label: 'TOTAL TRAVEL TIME',
                  primaryValue: destination.travelTime,
                  secondaryValue: destination.transitInfo,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTelemetryBlock(
                  icon: Icons.schedule_rounded,
                  iconColor: AppTheme.solarAmber,
                  label: 'ESTIMATED ARRIVAL',
                  primaryValue: destination.estimatedArrivalTime,
                  secondaryValue: 'Departing: Today via Hub',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3. Optimal Visiting Months & Climate Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.slateCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.frameBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_month_rounded, color: AppTheme.vapourIon, size: 14),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'OPTIMAL VISITING MONTHS',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: AppTheme.vapourIon,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.cyberEmerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          destination.currentSeasonStatus,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.cyberEmerald,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  destination.optimalVisitingMonths,
                  style: const TextStyle(
                    color: AppTheme.ghostIce,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Row(
                  children: [
                    const Icon(Icons.wb_sunny_outlined, color: AppTheme.solarAmber, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      destination.weatherExpectation,
                      style: const TextStyle(
                        color: AppTheme.mutedPhosphor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Interactive 12-Month Seasonality Timeline
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(12, (index) {
                      final monthNum = index + 1;
                      final isOptimal = destination.optimalMonthNumbers.contains(monthNum);
                      final isCurrentMonth = monthNum == 9; // September

                      return Container(
                        margin: const EdgeInsets.only(right: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOptimal
                              ? AppTheme.solarAmber.withValues(alpha: 0.2)
                              : AppTheme.midnightObsidian,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isOptimal
                                ? AppTheme.solarAmber
                                : isCurrentMonth
                                    ? AppTheme.vapourIon
                                    : AppTheme.frameBorder,
                            width: isOptimal || isCurrentMonth ? 1.2 : 0.8,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _monthNames[index],
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: isOptimal
                                    ? AppTheme.solarAmber
                                    : isCurrentMonth
                                        ? AppTheme.vapourIon
                                        : AppTheme.mutedPhosphor,
                                fontSize: 9.5,
                                fontWeight: isOptimal || isCurrentMonth
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isOptimal
                                    ? AppTheme.solarAmber
                                    : isCurrentMonth
                                        ? AppTheme.vapourIon
                                        : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryBlock({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String primaryValue,
    required String secondaryValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.slateCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.frameBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: iconColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            primaryValue,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.ghostIce,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            secondaryValue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.mutedPhosphor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(HotelItem hotel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppTheme.slateCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.frameBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel Photo Banner with Overlays
          Stack(
            children: [
              Image.network(
                hotel.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF222B38), Color(0xFF13171F)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.apartment_rounded,
                        color: AppTheme.vapourIon,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),

              // Gradient Overlay for readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
              ),

              // Deal Badge (e.g. AI TOP PICK)
              if (hotel.dealBadge != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hotel.dealBadge!.contains('TOP PICK')
                          ? AppTheme.solarAmber
                          : AppTheme.vapourIon,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hotel.dealBadge!.contains('TOP PICK')
                              ? Icons.auto_awesome
                              : Icons.verified_rounded,
                          color: AppTheme.midnightObsidian,
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hotel.dealBadge!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.midnightObsidian,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Distance Badge
              Positioned(
                bottom: 10,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.midnightObsidian.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.frameBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.place_rounded,
                        color: AppTheme.solarAmber,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hotel.distance,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.ghostIce,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Favorite Bookmark Button
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      hotel.isFavorite = !hotel.isFavorite;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.midnightObsidian.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.frameBorder),
                    ),
                    child: Icon(
                      hotel.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: hotel.isFavorite ? AppTheme.crimsonPulse : AppTheme.ghostIce,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Card Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel Name and Rating Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        hotel.name,
                        style: const TextStyle(
                          color: AppTheme.ghostIce,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.solarAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.solarAmber.withValues(alpha: 0.6),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: AppTheme.solarAmber, size: 13),
                          const SizedBox(width: 3),
                          Text(
                            hotel.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: AppTheme.solarAmber,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                // Room Type & Review Count
                Text(
                  '${hotel.roomType} • ${hotel.reviewCount} reviews',
                  style: const TextStyle(
                    color: AppTheme.mutedPhosphor,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 10),

                // Amenities Chips Row
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: hotel.amenities.map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.midnightObsidian,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.frameBorder),
                      ),
                      child: Text(
                        amenity,
                        style: const TextStyle(
                          color: AppTheme.ghostIce,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),

                // AI Highlight Callout
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.vapourIon.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.vapourIon.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.auto_awesome,
                          color: AppTheme.vapourIon,
                          size: 13,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          hotel.aiHighlight,
                          style: TextStyle(
                            color: AppTheme.ghostIce.withValues(alpha: 0.9),
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contextual Video Match snippet if available
                if (hotel.contextualMatch != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.solarAmber.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.solarAmber.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Icon(
                            Icons.video_library_rounded,
                            color: AppTheme.solarAmber,
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Video Match: ${hotel.contextualMatch}',
                            style: TextStyle(
                              color: AppTheme.ghostIce.withValues(alpha: 0.9),
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Price and "Book Now" CTA Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Starting from',
                          style: TextStyle(
                            color: AppTheme.mutedPhosphor,
                            fontSize: 10,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${hotel.currency}${hotel.pricePerNight}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: AppTheme.solarAmber,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              ' / night',
                              style: TextStyle(
                                color: AppTheme.mutedPhosphor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // "Book Now" Action Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.vapourIon,
                        foregroundColor: AppTheme.midnightObsidian,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () => _handleBookHotel(hotel),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 13),
                          SizedBox(width: 6),
                          Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
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
}
