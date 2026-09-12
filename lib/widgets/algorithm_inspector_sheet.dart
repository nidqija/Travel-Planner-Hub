import 'package:flutter/material.dart';
import '../models/video_item.dart';
import '../theme/app_theme.dart';

class AlgorithmInspectorSheet extends StatefulWidget {
  final VideoItem video;
  final Function(double visualWeight, double audioWeight, double noveltyWeight) onTuneAlgorithm;

  const AlgorithmInspectorSheet({
    super.key,
    required this.video,
    required this.onTuneAlgorithm,
  });

  static void show(
    BuildContext context, {
    required VideoItem video,
    required Function(double visualWeight, double audioWeight, double noveltyWeight) onTuneAlgorithm,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AlgorithmInspectorSheet(
        video: video,
        onTuneAlgorithm: onTuneAlgorithm,
      ),
    );
  }

  @override
  State<AlgorithmInspectorSheet> createState() => _AlgorithmInspectorSheetState();
}

class _AlgorithmInspectorSheetState extends State<AlgorithmInspectorSheet> {
  late double _visualWeight;
  late double _audioWeight;
  late double _noveltyWeight;
  bool _applied = false;

  @override
  void initState() {
    super.initState();
    _visualWeight = widget.video.vector.visualComplexity;
    _audioWeight = widget.video.vector.audioAffinity;
    _noveltyWeight = widget.video.vector.noveltyScore;
  }

  @override
  Widget build(BuildContext context) {
    final matchPercent = (widget.video.algorithmMatchScore * 100).toStringAsFixed(1);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.vapourIon, width: 1.5),
          left: BorderSide(color: AppTheme.frameBorder, width: 1),
          right: BorderSide(color: AppTheme.frameBorder, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.mutedPhosphor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: AppTheme.solarAmber,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'ALGORITHM TELEMETRY',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: AppTheme.vapourIon,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Why this is on your FYP',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.midnightObsidian,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.solarAmber.withValues(alpha: 0.6)),
                ),
                child: Column(
                  children: [
                    Text(
                      '$matchPercent%',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.solarAmber,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'MATCH SCORE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.mutedPhosphor,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Recommendation Reason Callout Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.midnightObsidian,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.frameBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.scatter_plot_rounded,
                  color: AppTheme.vapourIon,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.video.algorithmReason,
                    style: const TextStyle(
                      color: AppTheme.ghostIce,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Affinity Vector Breakdown
          const Text(
            'AFFINITY VECTOR ANALYSIS',
            style: TextStyle(
              fontFamily: 'monospace',
              color: AppTheme.mutedPhosphor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),

          _buildVectorGauge('Visual Complexity', widget.video.vector.visualComplexity, AppTheme.vapourIon),
          const SizedBox(height: 8),
          _buildVectorGauge('Acoustic Frequency Match', widget.video.vector.audioAffinity, AppTheme.solarAmber),
          const SizedBox(height: 8),
          _buildVectorGauge('Novelty & Exploration', widget.video.vector.noveltyScore, AppTheme.cyberEmerald),
          const SizedBox(height: 8),
          _buildVectorGauge('Creator Graph Proximity', widget.video.vector.graphProximity, const Color(0xFFB066FF)),

          const SizedBox(height: 22),

          // Real-Time Feed Tuning Controls
          const Text(
            'TUNE YOUR FYP ALGORITHM',
            style: TextStyle(
              fontFamily: 'monospace',
              color: AppTheme.mutedPhosphor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),

          _buildSlider(
            label: 'Visual Density Bias',
            value: _visualWeight,
            color: AppTheme.vapourIon,
            onChanged: (val) => setState(() => _visualWeight = val),
          ),
          _buildSlider(
            label: 'Acoustic Coherence',
            value: _audioWeight,
            color: AppTheme.solarAmber,
            onChanged: (val) => setState(() => _audioWeight = val),
          ),
          _buildSlider(
            label: 'Serendipity Factor',
            value: _noveltyWeight,
            color: AppTheme.cyberEmerald,
            onChanged: (val) => setState(() => _noveltyWeight = val),
          ),

          const SizedBox(height: 18),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _applied ? AppTheme.cyberEmerald : AppTheme.vapourIon,
                foregroundColor: AppTheme.midnightObsidian,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(_applied ? Icons.check_circle_rounded : Icons.tune_rounded),
              label: Text(
                _applied ? 'ALGORITHM WEIGHTS UPDATED' : 'APPLY WEIGHTS TO FYP',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              onPressed: () {
                final navigator = Navigator.of(context);
                widget.onTuneAlgorithm(_visualWeight, _audioWeight, _noveltyWeight);
                setState(() => _applied = true);
                Future.delayed(const Duration(milliseconds: 700), () {
                  if (mounted) navigator.pop();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVectorGauge(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 170,
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.ghostIce,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: AppTheme.midnightObsidian,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            '${(value * 100).toInt()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: AppTheme.mutedPhosphor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.mutedPhosphor,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              activeTrackColor: color,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '${(value * 100).toInt()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: AppTheme.ghostIce,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
