import 'package:flutter/material.dart';
import '../models/video_item.dart';
import '../theme/app_theme.dart';

class ViewfinderFrame extends StatelessWidget {
  final VideoItem video;
  final Widget child;

  const ViewfinderFrame({
    super.key,
    required this.video,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.midnightObsidian,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.frameBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Inner Video Surface
              child,

              // Top Frame HUD Bar
              Positioned(
                top: 12,
                left: 14,
                right: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Frame Label & Rec Status
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.midnightObsidian.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.frameBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _BlinkingRecDot(),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                video.indexLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: AppTheme.ghostIce,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 10,
                              color: AppTheme.mutedPhosphor.withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '60FPS',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: AppTheme.mutedPhosphor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Clean Viewfinder Sensor Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.midnightObsidian.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.frameBorder,
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.hdr_on_rounded,
                            color: AppTheme.solarAmber,
                            size: 13,
                          ),
                          SizedBox(width: 5),
                          Text(
                            '4K HDR • AF-C',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: AppTheme.ghostIce,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Viewfinder Corner Reticles
              const Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CornerReticlePainter(),
                  ),
                ),
              ),

              // Viewfinder Telemetry Bar (sub-HUD cluster)
              Positioned(
                left: 14,
                top: 42,
                child: IgnorePointer(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'RAW 9:16',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.mutedPhosphor.withValues(alpha: 0.8),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ISO 400 • 1/120',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.mutedPhosphor.withValues(alpha: 0.6),
                          fontSize: 9,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlinkingRecDot extends StatefulWidget {
  @override
  State<_BlinkingRecDot> createState() => _BlinkingRecDotState();
}

class _BlinkingRecDotState extends State<_BlinkingRecDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: AppTheme.crimsonPulse,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.crimsonPulse,
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws tactile camera viewfinder crosshair reticles on the 4 frame corners
class _CornerReticlePainter extends CustomPainter {
  const _CornerReticlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.mutedPhosphor.withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const margin = 14.0;
    const len = 14.0;

    // Top-Left
    canvas.drawLine(const Offset(margin, margin), const Offset(margin + len, margin), paint);
    canvas.drawLine(const Offset(margin, margin), const Offset(margin, margin + len), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin - len, margin), paint);
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin, margin + len), paint);

    // Bottom-Left
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin + len, size.height - margin), paint);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin, size.height - margin - len), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin - len, size.height - margin), paint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin, size.height - margin - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
