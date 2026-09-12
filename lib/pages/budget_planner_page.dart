import 'package:flutter/material.dart';
import '../models/travel_destination.dart';
import '../models/video_item.dart';
import '../theme/app_theme.dart';

class VideoBudgetEstimate {
  final VideoItem video;
  HotelItem selectedHotel;
  bool isIncluded;
  int nights;

  VideoBudgetEstimate({
    required this.video,
    required this.selectedHotel,
    this.isIncluded = true,
    this.nights = 3,
  });

  int get estimatedStayCost => selectedHotel.pricePerNight * nights;
}

class BudgetPlannerPage extends StatefulWidget {
  final List<VideoItem>? allVideos;

  const BudgetPlannerPage({
    super.key,
    this.allVideos,
  });

  @override
  State<BudgetPlannerPage> createState() => _BudgetPlannerPageState();
}

class _BudgetPlannerPageState extends State<BudgetPlannerPage> {
  int _totalBudget = 6000;
  bool _isBudgetSliderExpanded = false;

  late List<VideoBudgetEstimate> _videoEstimates;

  @override
  void initState() {
    super.initState();
    _initVideoEstimates();
  }

  void _initVideoEstimates() {
    final videos = widget.allVideos ?? VideoItem.getSampleFeed();

    _videoEstimates = videos.map((video) {
      // Pick the bot recommended hotel (either dealBadge AI TOP PICK or the first hotel)
      final botPick = video.destination.hotels.firstWhere(
        (h) => h.dealBadge == 'AI TOP PICK',
        orElse: () => video.destination.hotels.first,
      );

      // Default reasonable nights per destination
      int defaultNights = 3;
      if (video.destination.id.contains('tokyo') || video.destination.id.contains('kyoto')) {
        defaultNights = 3;
      } else if (video.destination.id.contains('banff') || video.destination.id.contains('santorini')) {
        defaultNights = 2;
      }

      return VideoBudgetEstimate(
        video: video,
        selectedHotel: botPick,
        isIncluded: true,
        nights: defaultNights,
      );
    }).toList();
  }

  int get _totalEstimatedCost => _videoEstimates
      .where((e) => e.isIncluded)
      .fold(0, (sum, item) => sum + item.estimatedStayCost);

  int get _activeVideoCount => _videoEstimates.where((e) => e.isIncluded).length;

  int get _totalNightsCount => _videoEstimates
      .where((e) => e.isIncluded)
      .fold(0, (sum, item) => sum + item.nights);

  int get _remainingBudget => _totalBudget - _totalEstimatedCost;

  double get _utilizationRatio =>
      _totalBudget > 0 ? (_totalEstimatedCost / _totalBudget) : 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.midnightObsidian,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopBar(),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                children: [
                  // Hero Budget Dashboard Card
                  _buildBudgetDashboardCard(),

                  const SizedBox(height: 12),

                  // OpenClaw AI Video Recommendation Summary Banner
                  _buildOpenClawAdvisorBanner(),

                  const SizedBox(height: 16),

                  // Destination Bot Concierge Note: Estimates are managed under each respective bot
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.slateCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.frameBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.midnightObsidian,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.vapourIon),
                          ),
                          child: const Icon(Icons.touch_app_rounded, color: AppTheme.vapourIon, size: 16),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PER-BOT DESTINATION ESTIMATES',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: AppTheme.solarAmber,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Individual stay estimates and nightly calculations are located directly under each destination bot when exploring places in your feed.',
                                style: TextStyle(
                                  color: AppTheme.ghostIce,
                                  fontSize: 11.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
      decoration: const BoxDecoration(
        color: AppTheme.midnightObsidian,
        border: Border(bottom: BorderSide(color: AppTheme.frameBorder, width: 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back to Feed
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.cinemaSlate,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.frameBorder),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.ghostIce, size: 12),
                  SizedBox(width: 6),
                  Text(
                    'FEED',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.ghostIce,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Title & Live Sync Indicator
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cyberEmerald,
                  ),
                ),
                const SizedBox(width: 6),
                const Flexible(
                  child: Text(
                    'TRAVEL BUDGET SYNC',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.ghostIce,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Budget Limit Slider Toggle
          GestureDetector(
            onTap: () {
              setState(() {
                _isBudgetSliderExpanded = !_isBudgetSliderExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _isBudgetSliderExpanded ? AppTheme.vapourIon : AppTheme.cinemaSlate,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.frameBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: _isBudgetSliderExpanded ? AppTheme.midnightObsidian : AppTheme.solarAmber,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'LIMIT',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: _isBudgetSliderExpanded ? AppTheme.midnightObsidian : AppTheme.ghostIce,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetDashboardCard() {
    final isOverBudget = _remainingBudget < 0;
    final statusColor = isOverBudget
        ? AppTheme.crimsonPulse
        : (_utilizationRatio > 0.85 ? AppTheme.solarAmber : AppTheme.cyberEmerald);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: 0.6), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Total Budget & Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL TRAVEL BUDGET',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.mutedPhosphor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$$_totalBudget',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.ghostIce,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOverBudget ? Icons.warning_rounded : Icons.check_circle_rounded,
                      color: statusColor,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isOverBudget
                          ? 'OVER BY \$${-_remainingBudget}'
                          : '${(_utilizationRatio * 100).toInt()}% ESTIMATED',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: statusColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Expandable Budget Limit Selector Slider
          if (_isBudgetSliderExpanded) ...[
            const SizedBox(height: 12),
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
                      const Text(
                        'Set Total Budget Target:',
                        style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '\$$_totalBudget',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.vapourIon,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.vapourIon,
                      inactiveTrackColor: AppTheme.midnightObsidian,
                      thumbColor: AppTheme.solarAmber,
                      overlayColor: AppTheme.solarAmber.withValues(alpha: 0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _totalBudget.toDouble().clamp(3000, 12000),
                      min: 3000,
                      max: 12000,
                      divisions: 18,
                      onChanged: (val) {
                        setState(() {
                          _totalBudget = val.toInt();
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [4000, 6000, 8000, 10000].map((preset) {
                      final isSelected = _totalBudget == preset;
                      return GestureDetector(
                        onTap: () => setState(() => _totalBudget = preset),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.vapourIon : AppTheme.midnightObsidian,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.frameBorder),
                          ),
                          child: Text(
                            '\$$preset',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: isSelected ? AppTheme.midnightObsidian : AppTheme.ghostIce,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Multi-Segment Visual Progress Bar (Color per Video)
          _buildMultiVideoProgressBar(),

          const SizedBox(height: 14),

          // Metric Tiles Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'TOTAL ESTIMATE',
                  amount: '\$$_totalEstimatedCost',
                  color: AppTheme.solarAmber,
                  subtitle: '$_activeVideoCount video stays',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: 'TOTAL NIGHTS',
                  amount: '$_totalNightsCount',
                  color: AppTheme.vapourIon,
                  subtitle: 'Across active stays',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: isOverBudget ? 'DEFICIT' : 'REMAINING',
                  amount: isOverBudget ? '-\$${-_remainingBudget}' : '+\$$_remainingBudget',
                  color: isOverBudget ? AppTheme.crimsonPulse : AppTheme.cyberEmerald,
                  subtitle: isOverBudget ? 'Exceeded' : '${((_remainingBudget / _totalBudget) * 100).toInt()}% buffer',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiVideoProgressBar() {
    final colors = [
      AppTheme.vapourIon,
      AppTheme.solarAmber,
      const Color(0xFF9B51E0),
      const Color(0xFF00C9FF),
      const Color(0xFFFF6B6B),
    ];

    final isOverBudget = _totalEstimatedCost > _totalBudget;
    final remainingFraction = (1.0 - _utilizationRatio).clamp(0.0, 1.0);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 10,
            color: AppTheme.midnightObsidian,
            child: Row(
              children: [
                ..._videoEstimates.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final estimate = entry.value;
                  if (!estimate.isIncluded) return const SizedBox.shrink();

                  final fraction = (_totalBudget > 0)
                      ? (estimate.estimatedStayCost / _totalBudget).clamp(0.0, 1.0)
                      : 0.0;
                  final color = isOverBudget ? AppTheme.crimsonPulse : colors[idx % colors.length];

                  return Expanded(
                    flex: (fraction * 1000).toInt().clamp(1, 1000),
                    child: Container(color: color),
                  );
                }),
                if (remainingFraction > 0 && !isOverBudget)
                  Expanded(
                    flex: (remainingFraction * 1000).toInt().clamp(1, 1000),
                    child: Container(color: AppTheme.cyberEmerald),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.vapourIon, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('Active Stays', style: TextStyle(fontFamily: 'monospace', color: AppTheme.mutedPhosphor, fontSize: 9.5, fontWeight: FontWeight.w600)),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOverBudget ? AppTheme.crimsonPulse : AppTheme.cyberEmerald,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  isOverBudget ? 'Budget Exceeded' : 'Safe Remaining Buffer',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: isOverBudget ? AppTheme.crimsonPulse : AppTheme.cyberEmerald,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String amount,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.slateCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'monospace',
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: AppTheme.ghostIce,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenClawAdvisorBanner() {
    final isOverBudget = _remainingBudget < 0;

    String advice;
    if (isOverBudget) {
      advice = '⚠️ Overrun Alert: Bot-recommended stays across active videos exceed your \$$_totalBudget budget by \$${-_remainingBudget}. Consider toggling off luxury stays or reducing stay nights below to keep your travel plan in the safe green zone.';
    } else if (_utilizationRatio > 0.85) {
      advice = '⚡ Optimal Fit: You are utilizing ${(_utilizationRatio * 100).toInt()}% of budget with \$$_remainingBudget buffer. All $_activeVideoCount selected stays pair closely with their video aesthetics.';
    } else if (_activeVideoCount == 0) {
      advice = '💡 Tip: Select one or more video recommendations below to calculate how your feed destinations fit into your \$$_totalBudget budget.';
    } else {
      advice = '🟢 High Liquidity: Your $_activeVideoCount video recommendations total \$$_totalEstimatedCost for $_totalNightsCount nights. You have a generous \$$_remainingBudget reserve for flights, dining, and activities.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.slateCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.vapourIon.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.midnightObsidian,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.vapourIon),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: AppTheme.solarAmber, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OPENCLAW AI RECOMMENDATION SYNTHESIS',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.solarAmber,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  advice,
                  style: const TextStyle(
                    color: AppTheme.ghostIce,
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
