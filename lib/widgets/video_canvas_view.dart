import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_item.dart';
import '../theme/app_theme.dart';

class VideoCanvasView extends StatefulWidget {
  final VideoItem video;
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final VoidCallback onDoubleTapLike;

  const VideoCanvasView({
    super.key,
    required this.video,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onDoubleTapLike,
  });

  @override
  State<VideoCanvasView> createState() => _VideoCanvasViewState();
}

class _VideoCanvasViewState extends State<VideoCanvasView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  VideoPlayerController? _videoPlayerController;
  bool _isVideoInitialized = false;

  final List<_FloatingHeart> _hearts = [];
  double _currentProgress = 0.0;
  bool _isDraggingScrubber = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_onProceduralTick);

    if (widget.isPlaying) {
      _animController.repeat();
    }

    _initVideoPlayer();
  }

  void _initVideoPlayer() {
    if (widget.video.videoAssetPath != null) {
      try {
        _videoPlayerController = VideoPlayerController.asset(widget.video.videoAssetPath!)
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _isVideoInitialized = true;
              });
              _videoPlayerController?.setLooping(true);
              if (widget.isPlaying) {
                _videoPlayerController?.play();
              }
            }
          }).catchError((_) {
            // Gracefully fallback to procedural motion canvas if asset decoding fails
            if (mounted) {
              setState(() {
                _isVideoInitialized = false;
              });
            }
          });
        _videoPlayerController?.addListener(_onVideoTick);
      } catch (_) {
        _isVideoInitialized = false;
      }
    }
  }

  void _onVideoTick() {
    if (!mounted || _isDraggingScrubber || _videoPlayerController == null) return;
    final value = _videoPlayerController!.value;
    if (value.isInitialized && value.duration.inMilliseconds > 0) {
      setState(() {
        _currentProgress = value.position.inMilliseconds / value.duration.inMilliseconds;
        _hearts.removeWhere((heart) => heart.isExpired);
        for (final heart in _hearts) {
          heart.update();
        }
      });
    }
  }

  void _onProceduralTick() {
    if (!mounted || _isDraggingScrubber || _videoPlayerController != null) return;
    setState(() {
      final totalSeconds = widget.video.duration.inSeconds.toDouble();
      final elapsed = (_animController.value * totalSeconds);
      _currentProgress = (elapsed % totalSeconds) / totalSeconds;

      _hearts.removeWhere((heart) => heart.isExpired);
      for (final heart in _hearts) {
        heart.update();
      }
    });
  }

  @override
  void didUpdateWidget(covariant VideoCanvasView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _animController.repeat();
        _videoPlayerController?.play();
      } else {
        _animController.stop();
        _videoPlayerController?.pause();
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_onVideoTick);
    _videoPlayerController?.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleDoubleTap(TapDownDetails details) {
    widget.onDoubleTapLike();
    setState(() {
      _hearts.add(
        _FloatingHeart(
          position: details.localPosition,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  String _formatTime(double progress) {
    final Duration totalDuration = (_videoPlayerController != null && _isVideoInitialized)
        ? _videoPlayerController!.value.duration
        : widget.video.duration;

    final totalSec = totalDuration.inSeconds;
    final currentSec = (progress * totalSec).floor();
    final mins = (currentSec ~/ 60).toString().padLeft(2, '0');
    final secs = (currentSec % 60).toString().padLeft(2, '0');
    final totalMins = (totalSec ~/ 60).toString().padLeft(2, '0');
    final totalSecs = (totalSec % 60).toString().padLeft(2, '0');
    return '$mins:$secs / $totalMins:$totalSecs';
  }

  @override
  Widget build(BuildContext context) {
    final hasAssetVideo = widget.video.videoAssetPath != null;

    return GestureDetector(
      onTap: widget.onTogglePlay,
      onDoubleTapDown: _handleDoubleTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Video or Procedural Kinetic Canvas
          if (hasAssetVideo && _isVideoInitialized && _videoPlayerController != null)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _videoPlayerController!.value.size.width,
                  height: _videoPlayerController!.value.size.height,
                  child: VideoPlayer(_videoPlayerController!),
                ),
              ),
            )
          else if (hasAssetVideo && !_isVideoInitialized)
            Container(
              color: AppTheme.midnightObsidian,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.vapourIon),
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'LOADING VIDEO FRAME...',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.mutedPhosphor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            CustomPaint(
              painter: _VideoMotionPainter(
                motionType: widget.video.motionType,
                progress: _animController.value,
                isPlaying: widget.isPlaying,
              ),
            ),

          // Cinematic subtle Vignette overlay
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.1,
                colors: [
                  Colors.transparent,
                  Color(0x33000000),
                  Color(0x990D1117),
                ],
                stops: [0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Floating double-tap hearts
          ..._hearts.map(
            (heart) => Positioned(
              left: heart.position.dx - 32,
              top: heart.position.dy - 32 - (heart.progress * 80),
              child: Opacity(
                opacity: (1.0 - heart.progress).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.8 + (math.sin(heart.progress * math.pi) * 0.6),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: AppTheme.crimsonPulse,
                    size: 64,
                    shadows: [
                      Shadow(
                        color: Color(0x99FF4757),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Play/Pause State Indicator when paused
          if (!widget.isPlaying)
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.midnightObsidian.withValues(alpha: 0.75),
                  border: Border.all(
                    color: AppTheme.vapourIon.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.vapourIon.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppTheme.ghostIce,
                  size: 40,
                ),
              ),
            ),

          // Bottom Scrubber Bar & Playback Progress
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: Text(
                    _formatTime(_currentProgress),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.mutedPhosphor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Minimal Scrubber
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
                    activeTrackColor: AppTheme.solarAmber,
                    inactiveTrackColor: AppTheme.mutedPhosphor.withValues(alpha: 0.2),
                    thumbColor: AppTheme.ghostIce,
                    overlayColor: AppTheme.solarAmber.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _currentProgress.clamp(0.0, 1.0),
                    onChangeStart: (_) => _isDraggingScrubber = true,
                    onChanged: (val) {
                      setState(() {
                        _currentProgress = val;
                      });
                    },
                    onChangeEnd: (val) {
                      _isDraggingScrubber = false;
                      _animController.value = val;
                      if (_videoPlayerController != null && _isVideoInitialized) {
                        final targetMs = (val * _videoPlayerController!.value.duration.inMilliseconds).round();
                        _videoPlayerController!.seekTo(Duration(milliseconds: targetMs));
                      }
                    },
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

class _FloatingHeart {
  final Offset position;
  final DateTime createdAt;
  double progress = 0.0;

  _FloatingHeart({required this.position, required this.createdAt});

  void update() {
    final ms = DateTime.now().difference(createdAt).inMilliseconds;
    progress = (ms / 750).clamp(0.0, 1.0);
  }

  bool get isExpired => progress >= 1.0;
}

/// Rich 60fps procedural motion graphics painter
class _VideoMotionPainter extends CustomPainter {
  final VideoMotionType motionType;
  final double progress;
  final bool isPlaying;

  _VideoMotionPainter({
    required this.motionType,
    required this.progress,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final bgPaint = Paint()..color = const Color(0xFF0A0E14);
    canvas.drawRect(rect, bgPaint);

    switch (motionType) {
      case VideoMotionType.kineticWave:
        _paintKineticWave(canvas, size);
        break;
      case VideoMotionType.quantumLattice:
        _paintQuantumLattice(canvas, size);
        break;
      case VideoMotionType.particleVortex:
        _paintParticleVortex(canvas, size);
        break;
      case VideoMotionType.harmonicPulse:
        _paintHarmonicPulse(canvas, size);
        break;
      case VideoMotionType.chromaticGrid:
        _paintChromaticGrid(canvas, size);
        break;
    }
  }

  void _paintKineticWave(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.46);
    const waveCount = 5;

    for (int i = 0; i < waveCount; i++) {
      final path = Path();
      final phase = (progress * 2 * math.pi) + (i * 0.8);
      final amplitude = 35.0 + (i * 12.0);
      final freq = 0.008 + (i * 0.002);
      final yOffset = center.dy + ((i - 2) * 45.0);

      path.moveTo(0, yOffset);
      for (double x = 0; x <= size.width; x += 4) {
        final y = yOffset + math.sin(x * freq + phase) * amplitude * math.cos(progress * math.pi + (x * 0.003));
        path.lineTo(x, y);
      }

      final color = i % 2 == 0
          ? Color.lerp(AppTheme.vapourIon, AppTheme.solarAmber, i / waveCount)!
          : Color.lerp(const Color(0xFF00E699), AppTheme.vapourIon, i / waveCount)!;

      final paint = Paint()
        ..color = color.withValues(alpha: 0.55 - (i * 0.08))
        ..strokeWidth = 3.0 + i
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, paint);
    }

    final corePaint = Paint()
      ..color = AppTheme.vapourIon.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, 90 + (math.sin(progress * 4 * math.pi) * 15), corePaint);
  }

  void _paintQuantumLattice(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.46);
    final angle = progress * 2 * math.pi;

    for (int ring = 1; ring <= 4; ring++) {
      final radius = ring * 48.0;
      final points = <Offset>[];
      const sides = 6;
      final rot = angle * (ring % 2 == 0 ? 1 : -1) * (0.5 + ring * 0.2);

      for (int i = 0; i < sides; i++) {
        final a = rot + (i * (2 * math.pi / sides));
        points.add(Offset(
          center.dx + radius * math.cos(a),
          center.dy + (radius * 0.65) * math.sin(a),
        ));
      }

      final path = Path()..addPolygon(points, true);
      final linePaint = Paint()
        ..color = (ring == 2 ? AppTheme.solarAmber : AppTheme.vapourIon).withValues(alpha: 0.7 - (ring * 0.1))
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, linePaint);

      final nodePaint = Paint()..color = AppTheme.ghostIce;
      for (final pt in points) {
        canvas.drawCircle(pt, 3.5, nodePaint);
      }
    }
  }

  void _paintParticleVortex(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.46);
    const count = 75;

    for (int i = 0; i < count; i++) {
      final seed = i * 137.5;
      final speed = 0.4 + ((i % 5) * 0.25);
      final t = (progress * speed + (i / count)) % 1.0;
      final dist = (1.0 - t) * (size.width * 0.52);
      final rad = seed + (t * 8 * math.pi);

      final pos = Offset(
        center.dx + dist * math.cos(rad),
        center.dy + dist * 0.7 * math.sin(rad),
      );

      final alpha = (t * 0.9).clamp(0.0, 1.0);
      final pColor = (i % 3 == 0)
          ? AppTheme.solarAmber
          : (i % 3 == 1 ? AppTheme.vapourIon : const Color(0xFF00E699));

      final pPaint = Paint()
        ..color = pColor.withValues(alpha: alpha)
        ..strokeWidth = 2.0 + (t * 3.0);
      canvas.drawCircle(pos, 2.0 + (t * 2.5), pPaint);
    }

    canvas.drawCircle(
      center,
      8.0,
      Paint()..color = AppTheme.ghostIce,
    );
  }

  void _paintHarmonicPulse(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.46);

    for (int i = 0; i < 6; i++) {
      final t = (progress + (i / 6)) % 1.0;
      final radius = t * (size.width * 0.55);
      final opacity = (1.0 - t).clamp(0.0, 1.0) * 0.75;

      final p = Paint()
        ..color = (i % 2 == 0 ? AppTheme.vapourIon : AppTheme.solarAmber).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * (1.0 - t) + 1.0;

      canvas.drawCircle(center, radius, p);
    }

    const bars = 24;
    final barWidth = size.width / (bars * 1.8);
    for (int i = 0; i < bars; i++) {
      final x = (size.width * 0.15) + (i * barWidth * 1.5);
      final factor = math.sin((i * 0.4) + (progress * 6 * math.pi)).abs();
      final barHeight = 20.0 + (factor * 60.0);
      final y1 = center.dy - (barHeight / 2);
      final y2 = center.dy + (barHeight / 2);

      final barPaint = Paint()
        ..color = AppTheme.ghostIce.withValues(alpha: 0.6 + factor * 0.4)
        ..strokeWidth = barWidth * 0.7
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(x, y1), Offset(x, y2), barPaint);
    }
  }

  void _paintChromaticGrid(Canvas canvas, Size size) {
    final horizonY = size.height * 0.46;
    final vanishingPoint = Offset(size.width / 2, horizonY);

    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.solarAmber.withValues(alpha: 0.9),
          AppTheme.crimsonPulse.withValues(alpha: 0.6),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: vanishingPoint, radius: 80));
    canvas.drawCircle(vanishingPoint, 80, sunPaint);

    final linePaint = Paint()
      ..color = AppTheme.vapourIon.withValues(alpha: 0.4)
      ..strokeWidth = 1.5;

    for (double x = -size.width * 0.5; x <= size.width * 1.5; x += 40) {
      canvas.drawLine(vanishingPoint, Offset(x, size.height), linePaint);
    }

    const lines = 10;
    for (int i = 0; i < lines; i++) {
      final t = (progress + (i / lines)) % 1.0;
      final y = horizonY + (math.pow(t, 2.5) * (size.height - horizonY));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VideoMotionPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isPlaying != isPlaying;
  }
}
