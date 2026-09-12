import 'package:flutter/material.dart';
import '../models/group_chat.dart';
import '../theme/app_theme.dart';

class IdeationPage extends StatefulWidget {
  final VoidCallback? onSwitchToFyp;

  const IdeationPage({
    super.key,
    this.onSwitchToFyp,
  });

  @override
  State<IdeationPage> createState() => _IdeationPageState();
}

class _IdeationPageState extends State<IdeationPage> {
  // Live Algorithm Weights
  double _visualWeight = 0.88;
  double _audioWeight = 0.82;
  double _noveltyWeight = 0.76;
  double _cultureWeight = 0.90;
  double _paceWeight = 0.65;

  String _selectedPersona = 'Cyberpunk Urbanist';
  bool _weightsApplied = false;

  final List<Map<String, dynamic>> _personas = [
    {
      'name': 'Cyberpunk Urbanist',
      'icon': Icons.electric_bolt_rounded,
      'visual': 0.94,
      'audio': 0.88,
      'novelty': 0.80,
      'culture': 0.70,
      'pace': 0.90,
    },
    {
      'name': 'Zen Alpine Nomad',
      'icon': Icons.landscape_rounded,
      'visual': 0.75,
      'audio': 0.70,
      'novelty': 0.92,
      'culture': 0.85,
      'pace': 0.40,
    },
    {
      'name': 'Culinary Trailblazer',
      'icon': Icons.restaurant_rounded,
      'visual': 0.80,
      'audio': 0.65,
      'novelty': 0.88,
      'culture': 0.95,
      'pace': 0.70,
    },
    {
      'name': 'Tropical Eco-Nomad',
      'icon': Icons.beach_access_rounded,
      'visual': 0.85,
      'audio': 0.90,
      'novelty': 0.78,
      'culture': 0.80,
      'pace': 0.50,
    },
  ];

  late List<Map<String, dynamic>> _ideationCards;

  @override
  void initState() {
    super.initState();
    _initIdeationCards();
  }

  void _initIdeationCards() {
    _ideationCards = [
      {
        'id': 'idea-1',
        'title': 'Cyberpunk Tokyo Neon Photo-Sprint',
        'destination': 'Shibuya & Akihabara, Japan',
        'tag': 'TOKYO 📸',
        'badgeColor': AppTheme.vapourIon,
        'matchScore': 0.986,
        'reason': 'Generated from high visual density + kinetic synthesizer audio telemetry',
        'highlights': ['Omoide Yokocho night walk', 'Shibuya Sky observatory', 'teamLab Planets light immersion'],
        'budget': '\$1,250 / pax',
        'duration': '5 Days',
        'vibe': 'Electric Neon & Street Photography',
      },
      {
        'id': 'idea-2',
        'title': 'Bali Cliffside Bamboo Eco-Villa & Co-Work',
        'destination': 'Uluwatu & Ubud, Bali',
        'tag': 'BALI 🌴',
        'badgeColor': AppTheme.cyberEmerald,
        'matchScore': 0.954,
        'reason': 'Aligned with acoustic chill drift & organic kinetic architecture vectors',
        'highlights': ['Bingin cliffside cafe', 'Ubud sacred monkey canopy', 'Tegalalang sunrise co-work'],
        'budget': '\$820 / pax',
        'duration': '7 Days',
        'vibe': 'Tropical Sanctuary & Slow Living',
      },
      {
        'id': 'idea-3',
        'title': 'Swiss Alpine High-Glacier Crossing',
        'destination': 'Zermatt & Grindelwald, Switzerland',
        'tag': 'ALPS 🏔️',
        'badgeColor': AppTheme.solarAmber,
        'matchScore': 0.938,
        'reason': 'Matched with high serendipity and landscape novelty coefficients',
        'highlights': ['Matterhorn sunrise ridge', 'Glacier 3000 suspension walk', 'First Cliff high line'],
        'budget': '\$1,650 / pax',
        'duration': '6 Days',
        'vibe': 'Extreme Heights & Crisp Glaciers',
      },
      {
        'id': 'idea-4',
        'title': 'Seoul Secret Night Market & Vinyl Bars',
        'destination': 'Seongsu-dong & Euljiro, Seoul',
        'tag': 'SEOUL 🥢',
        'badgeColor': const Color(0xFFFF4757),
        'matchScore': 0.962,
        'reason': 'High cultural immersion + culinary graph cluster affinity',
        'highlights': ['Mangwon street snacks', 'Euljiro retro vinyl lounge', 'Han River ramen picnic'],
        'budget': '\$950 / pax',
        'duration': '4 Days',
        'vibe': 'Subterranean Foodies & Retro Grooves',
      },
    ];
  }

  void _applyPersona(Map<String, dynamic> persona) {
    setState(() {
      _selectedPersona = persona['name'];
      _visualWeight = persona['visual'];
      _audioWeight = persona['audio'];
      _noveltyWeight = persona['novelty'];
      _cultureWeight = persona['culture'];
      _paceWeight = persona['pace'];
      _weightsApplied = false;
    });
  }

  void _shareIdeaToSquad(Map<String, dynamic> idea) {
    final repo = GroupChatRepository.instance;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppTheme.solarAmber, width: 1.5)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.mutedPhosphor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.send_rounded, color: AppTheme.solarAmber, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Drop Idea into Squad Chat',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Share "${idea['title']}" to your travel squad:',
                style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
              ),
              const SizedBox(height: 14),
              ...repo.chats.map((chat) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: chat.memberAvatarColors.first,
                    child: Text(
                      chat.title[0],
                      style: const TextStyle(
                        color: AppTheme.midnightObsidian,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  title: Text(
                    chat.title,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    chat.destinationTag,
                    style: const TextStyle(fontFamily: 'monospace', color: AppTheme.solarAmber, fontSize: 10),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.solarAmber,
                      foregroundColor: AppTheme.midnightObsidian,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: const Size(60, 32),
                    ),
                    onPressed: () {
                      repo.sendMessage(
                        chat.id,
                        '💡 Dropped a new AI trip ideation: "${idea['title']}" (${idea['duration']} • ${idea['budget']})! Check the itinerary spots!',
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.cinemaSlate,
                          content: Text('Idea sent to ${chat.title}!'),
                        ),
                      );
                    },
                    child: const Text('Send', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  double get _overallMatch {
    return ((_visualWeight + _audioWeight + _noveltyWeight + _cultureWeight + _paceWeight) / 5) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.midnightObsidian,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            _buildHeader(),

            // Scrollable Content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),
                children: [
                  // AI Algorithm Engine Box
                  _buildAlgorithmEngineCard(),
                  const SizedBox(height: 20),

                  // Preset Personas Bar
                  _buildPersonasSelector(),
                  const SizedBox(height: 24),

                  // Section Title: AI Travel Sparks & Ideation Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppTheme.solarAmber, size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            'AI TRIP IDEATION SPARKS',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: AppTheme.ghostIce,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _ideationCards.shuffle();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppTheme.cinemaSlate,
                              content: Text('Regenerated fresh trip sparks from current algorithm weights!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.slateCard,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.frameBorder),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh_rounded, color: AppTheme.vapourIon, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Reshuffle',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: AppTheme.vapourIon,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Ideation Cards
                  ..._ideationCards.map((card) => _buildIdeationCard(card)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.solarAmber, AppTheme.cyberEmerald],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: AppTheme.midnightObsidian,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI IDEATION & ALGORITHM',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.ghostIce,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Feed Neural Weights • Trip Sparks',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.mutedPhosphor,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.cinemaSlate,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.solarAmber.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hub_rounded, color: AppTheme.solarAmber, size: 11),
                const SizedBox(width: 4),
                Text(
                  '${_overallMatch.toStringAsFixed(1)}%',
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
    );
  }

  Widget _buildAlgorithmEngineCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.vapourIon.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.vapourIon.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.tune_rounded, color: AppTheme.vapourIon, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'ALGORITHM VECTOR TUNING',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.vapourIon,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppTheme.midnightObsidian,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ACTIVE FOR FYP',
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
          const SizedBox(height: 6),
          const Text(
            'Adjust the weights below to steer your For You video reel and unlock tailored travel ideations.',
            style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11.5, height: 1.3),
          ),
          const SizedBox(height: 16),

          // Sliders
          _buildSliderRow('Visual Complexity', _visualWeight, AppTheme.vapourIon, (v) {
            setState(() {
              _visualWeight = v;
              _weightsApplied = false;
            });
          }),
          _buildSliderRow('Acoustic Resonance', _audioWeight, AppTheme.solarAmber, (v) {
            setState(() {
              _audioWeight = v;
              _weightsApplied = false;
            });
          }),
          _buildSliderRow('Novelty & Serendipity', _noveltyWeight, AppTheme.cyberEmerald, (v) {
            setState(() {
              _noveltyWeight = v;
              _weightsApplied = false;
            });
          }),
          _buildSliderRow('Cultural Immersion', _cultureWeight, const Color(0xFFB066FF), (v) {
            setState(() {
              _cultureWeight = v;
              _weightsApplied = false;
            });
          }),
          _buildSliderRow('Kinetic Pacing', _paceWeight, const Color(0xFFFF4757), (v) {
            setState(() {
              _paceWeight = v;
              _weightsApplied = false;
            });
          }),

          const SizedBox(height: 14),

          // Action Button: Apply to FYP
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _weightsApplied ? AppTheme.cyberEmerald : AppTheme.vapourIon,
                foregroundColor: AppTheme.midnightObsidian,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: Icon(_weightsApplied ? Icons.check_circle_rounded : Icons.sync_rounded, size: 18),
              label: Text(
                _weightsApplied ? 'WEIGHTS APPLIED TO FOR YOU FEED' : 'SYNC WEIGHTS WITH FYP FEED',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              onPressed: () {
                setState(() => _weightsApplied = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.cinemaSlate,
                    duration: const Duration(seconds: 2),
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppTheme.cyberEmerald, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Tuned FYP Algorithm: ${_overallMatch.toStringAsFixed(1)}% match profile',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, double value, Color color, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.ghostIce,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                activeTrackColor: color,
                inactiveTrackColor: AppTheme.midnightObsidian,
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
                color: AppTheme.mutedPhosphor,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonasSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PRESET ALGORITHM PERSONAS',
          style: TextStyle(
            fontFamily: 'monospace',
            color: AppTheme.mutedPhosphor,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _personas.map((p) {
              final isSelected = p['name'] == _selectedPersona;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _applyPersona(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.vapourIon.withValues(alpha: 0.15) : AppTheme.cinemaSlate,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.vapourIon : AppTheme.frameBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          p['icon'] as IconData,
                          size: 14,
                          color: isSelected ? AppTheme.vapourIon : AppTheme.mutedPhosphor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          p['name'] as String,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: isSelected ? AppTheme.ghostIce : AppTheme.mutedPhosphor,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildIdeationCard(Map<String, dynamic> card) {
    final matchScore = ((card['matchScore'] as double) * 100).toStringAsFixed(1);
    final badgeColor = card['badgeColor'] as Color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cinemaSlate,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.frameBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Tag + Match Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.midnightObsidian,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    card['tag'],
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.solarAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.solarAmber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, color: AppTheme.solarAmber, size: 11),
                      const SizedBox(width: 4),
                      Text(
                        '$matchScore% AI MATCH',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.solarAmber,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              card['title'],
              style: const TextStyle(
                color: AppTheme.ghostIce,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),

            // Destination & Duration (Using Wrap to prevent any overflow)
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 2,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppTheme.mutedPhosphor, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      card['destination'],
                      style: const TextStyle(fontFamily: 'monospace', color: AppTheme.mutedPhosphor, fontSize: 11),
                    ),
                  ],
                ),
                Text('• ${card['duration']}', style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11)),
                Text('• ${card['budget']}', style: const TextStyle(color: AppTheme.solarAmber, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),

            // AI Reason Callout
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.midnightObsidian,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.frameBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bubble_chart_rounded, color: AppTheme.vapourIon, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      card['reason'],
                      style: const TextStyle(
                        color: AppTheme.ghostIce,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Highlights
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: (card['highlights'] as List<String>).map((h) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.slateCard,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '• $h',
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 10.5),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Actions: Share to Squad Chat & View on FYP
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.solarAmber,
                      foregroundColor: AppTheme.midnightObsidian,
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 13),
                    label: const Text(
                      'SQUAD CHAT',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                        fontSize: 9.5,
                      ),
                    ),
                    onPressed: () => _shareIdeaToSquad(card),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.vapourIon,
                      side: const BorderSide(color: AppTheme.vapourIon),
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.play_circle_fill_rounded, size: 13),
                    label: const Text(
                      'REELS',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        fontSize: 9.5,
                      ),
                    ),
                    onPressed: widget.onSwitchToFyp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
