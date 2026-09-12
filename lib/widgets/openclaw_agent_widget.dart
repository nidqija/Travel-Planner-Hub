import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/travel_destination.dart';
import '../theme/app_theme.dart';

class OpenClawAgentWidget extends StatefulWidget {
  final TravelDestination destination;
  final VoidCallback onTap;
  final bool isNewVideo;
  final Duration appearanceDelay;
  final Duration autoCloseDuration;

  const OpenClawAgentWidget({
    super.key,
    required this.destination,
    required this.onTap,
    this.isNewVideo = true,
    this.appearanceDelay = const Duration(seconds: 1),
    this.autoCloseDuration = const Duration(seconds: 2),
  });

  @override
  State<OpenClawAgentWidget> createState() => _OpenClawAgentWidgetState();
}

class _OpenClawAgentWidgetState extends State<OpenClawAgentWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _entranceController;
  late AnimationController _radarController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  Timer? _displayTimer;
  Timer? _autoCloseTimer;

  bool _isBotVisible = false;
  bool _isSpeechBubbleVisible = false;
  bool _isDismissedForCurrentVideo = false;

  @override
  void initState() {
    super.initState();

    // Floating idle bobbing animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Dynamic scanning radar glow animation
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Entrance spring animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<double>(begin: -6.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );

    if (widget.isNewVideo) {
      _startCycle();
    }
  }

  void _startCycle() {
    _cancelTimers();

    if (widget.appearanceDelay == Duration.zero) {
      if (mounted) {
        setState(() {
          _isBotVisible = true;
          _isSpeechBubbleVisible = true;
          _isDismissedForCurrentVideo = false;
        });
        _entranceController.forward(from: 0.0);
        _scheduleAutoClose();
      }
      return;
    }

    setState(() {
      _isBotVisible = false;
      _isSpeechBubbleVisible = false;
      _isDismissedForCurrentVideo = false;
    });

    // Display OpenClaw after 1 second of video playback
    _displayTimer = Timer(widget.appearanceDelay, () {
      if (!mounted) return;
      setState(() {
        _isBotVisible = true;
        _isSpeechBubbleVisible = true;
      });
      _entranceController.forward(from: 0.0);
      _scheduleAutoClose();
    });
  }

  void _scheduleAutoClose() {
    _autoCloseTimer?.cancel();
    if (widget.autoCloseDuration > Duration.zero) {
      // After 2 seconds of showing the speech bubble, automatically close the small model
      _autoCloseTimer = Timer(widget.autoCloseDuration, () {
        if (!mounted) return;
        setState(() {
          _isSpeechBubbleVisible = false;
        });
      });
    }
  }

  void _cancelTimers() {
    _displayTimer?.cancel();
    _displayTimer = null;
    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;
  }

  @override
  void didUpdateWidget(covariant OpenClawAgentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isNewVideo && (!oldWidget.isNewVideo || oldWidget.destination.id != widget.destination.id)) {
      // Re-trigger 1-second delay and 2-second auto-close when a new video plays!
      _startCycle();
    } else if (!widget.isNewVideo && oldWidget.isNewVideo) {
      _cancelTimers();
      setState(() {
        _isBotVisible = false;
        _isSpeechBubbleVisible = false;
      });
    }
  }

  @override
  void dispose() {
    _cancelTimers();
    _floatController.dispose();
    _radarController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBotVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _entranceController]),
      builder: (context, child) {
        final floatOffset = math.sin(_floatController.value * math.pi) * 3.0;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(_slideAnimation.value, floatOffset),
            child: Transform.scale(
              scale: _scaleAnimation.value.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // OpenClaw Bot Mascot - clicking it displays the modal with the list of hotels
                  GestureDetector(
                    key: const ValueKey('openclaw-bot-mascot-tap'),
                    onTap: widget.onTap,
                    child: _buildBotMascot(),
                  ),

                  // Small Model (Speech Bubble) - retracts smoothly after 2 seconds
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          alignment: Alignment.centerLeft,
                          child: child,
                        ),
                      );
                    },
                    child: (_isSpeechBubbleVisible && !_isDismissedForCurrentVideo)
                        ? Padding(
                            key: const ValueKey('openclaw-speech-bubble'),
                            padding: const EdgeInsets.only(left: 8),
                            child: GestureDetector(
                              onTap: widget.onTap,
                              child: _buildSpeechBubble(),
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('empty-bubble')),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBotMascot() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Pulsing radar glow behind avatar
        AnimatedBuilder(
          animation: _radarController,
          builder: (context, child) {
            final pulseScale = 1.0 + (_radarController.value * 0.22);
            final pulseAlpha = (1.0 - _radarController.value).clamp(0.0, 0.7);

            return Container(
              width: 48 * pulseScale,
              height: 48 * pulseScale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.vapourIon.withValues(alpha: pulseAlpha),
                  width: 1.5,
                ),
              ),
            );
          },
        ),

        // Bot Chassis Container
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF283446),
                Color(0xFF131822),
                Color(0xFF090D13),
              ],
            ),
            border: Border.all(
              color: AppTheme.vapourIon,
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.vapourIon.withValues(alpha: 0.35),
                blurRadius: 10,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Custom OpenClaw Cyber Avatar & Eye Painter
              CustomPaint(
                size: const Size(40, 40),
                painter: _OpenClawFacePainter(
                  glowIntensity: _floatController.value,
                ),
              ),

              // Small online green status beacon
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cyberEmerald,
                    border: Border.all(
                      color: AppTheme.midnightObsidian,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.cyberEmerald.withValues(alpha: 0.8),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // OpenClaw Robotic Side Antennas / Pincers
        Positioned(
          left: -3,
          top: 9,
          child: _buildClawEar(isLeft: true),
        ),
        Positioned(
          right: -3,
          top: 9,
          child: _buildClawEar(isLeft: false),
        ),
      ],
    );
  }

  Widget _buildClawEar({required bool isLeft}) {
    return Container(
      width: 5,
      height: 11,
      decoration: BoxDecoration(
        color: AppTheme.solarAmber,
        borderRadius: BorderRadius.circular(2.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.solarAmber.withValues(alpha: 0.6),
            blurRadius: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 198),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cinemaSlate.withValues(alpha: 0.95),
            AppTheme.midnightObsidian.withValues(alpha: 0.96),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
        ),
        border: Border.all(
          color: AppTheme.vapourIon.withValues(alpha: 0.7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppTheme.vapourIon.withValues(alpha: 0.15),
            blurRadius: 14,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar: AI Badge & Dismiss Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.vapourIon.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppTheme.vapourIon.withValues(alpha: 0.5),
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.smart_toy_rounded,
                          color: AppTheme.solarAmber,
                          size: 10,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'OPENCLAW AI',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.ghostIce,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  _autoCloseTimer?.cancel();
                  setState(() {
                    _isSpeechBubbleVisible = false;
                    _isDismissedForCurrentVideo = true;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 13,
                    color: AppTheme.mutedPhosphor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // Main Greeting Requirement: "hello! ready to travel to this place?"
          const Text(
            'Hello! Ready to travel to this place?',
            style: TextStyle(
              color: AppTheme.ghostIce,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 4),

          // Destination location preview
          Row(
            children: [
              Text(
                widget.destination.flagEmoji,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  widget.destination.cityCountry,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.solarAmber,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // Contextual Travel Telemetry & Optimal Season Teaser
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.midnightObsidian.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: AppTheme.vapourIon.withValues(alpha: 0.3),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.flight_takeoff_rounded,
                  color: AppTheme.vapourIon,
                  size: 11,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${widget.destination.travelTime.split('+').first.trim()} • Best: ${widget.destination.optimalVisitingMonths.split('(').first.trim()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.mutedPhosphor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Interactive CTA Prompt
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.vapourIon.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppTheme.vapourIon.withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.hotel_rounded,
                  color: AppTheme.ghostIce,
                  size: 12,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'Explore ${widget.destination.hotels.length} Nearby Stays',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.ghostIce,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.solarAmber,
                  size: 9,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Face Painter for OpenClaw:
/// Creates metallic faceplate, glowing cyan horizontal eye visor,
/// and robotic iris that pulsates with ambient life.
class _OpenClawFacePainter extends CustomPainter {
  final double glowIntensity;

  _OpenClawFacePainter({required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Visor background band
    final visorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: size.width * 0.72, height: 16),
      const Radius.circular(8),
    );

    final visorPaint = Paint()
      ..color = const Color(0xFF070B10)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(visorRect, visorPaint);

    final visorBorderPaint = Paint()
      ..color = AppTheme.vapourIon.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(visorRect, visorBorderPaint);

    // Left and right cyber eye dots (OpenClaw dual scanner)
    final eyeOffset = 6.0;
    final eyeRadius = 3.2;

    // Glowing aura
    final glowPaint = Paint()
      ..color = AppTheme.vapourIon.withValues(alpha: 0.3 + (glowIntensity * 0.3))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(Offset(center.dx - eyeOffset, center.dy), eyeRadius + 2, glowPaint);
    canvas.drawCircle(Offset(center.dx + eyeOffset, center.dy), eyeRadius + 2, glowPaint);

    // Core eyes
    final eyePaint = Paint()
      ..color = AppTheme.vapourIon
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx - eyeOffset, center.dy), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(center.dx + eyeOffset, center.dy), eyeRadius, eyePaint);

    // Iris pupils (high-energy white center)
    final pupilPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - eyeOffset, center.dy), eyeRadius * 0.5, pupilPaint);
    canvas.drawCircle(Offset(center.dx + eyeOffset, center.dy), eyeRadius * 0.5, pupilPaint);

    // Subtle forehead sensor line
    final sensorPaint = Paint()
      ..color = AppTheme.solarAmber.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - 4, center.dy - 12),
      Offset(center.dx + 4, center.dy - 12),
      sensorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OpenClawFacePainter oldDelegate) {
    return oldDelegate.glowIntensity != glowIntensity;
  }
}
