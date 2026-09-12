import 'travel_destination.dart';

class AlgorithmVector {
  final double visualComplexity;
  final double audioAffinity;
  final double noveltyScore;
  final double graphProximity;

  const AlgorithmVector({
    required this.visualComplexity,
    required this.audioAffinity,
    required this.noveltyScore,
    required this.graphProximity,
  });
}

enum VideoMotionType {
  kineticWave,
  quantumLattice,
  particleVortex,
  harmonicPulse,
  chromaticGrid,
}

class VideoItem {
  final String id;
  final String indexLabel; // e.g. "VIDEO 01", "VIDEO 02"
  final String title;
  final String creatorHandle;
  final String creatorName;
  final String description;
  final List<String> tags;
  final String audioTitle;
  final String audioArtist;
  final double algorithmMatchScore; // e.g. 0.984 for 98.4%
  final String algorithmReason;
  final AlgorithmVector vector;
  final VideoMotionType motionType;
  final Duration duration;
  final TravelDestination destination;

  final String? videoAssetPath;

  int likes;
  int comments;
  int saves;
  int shares;
  bool isLiked;
  bool isSaved;

  VideoItem({
    required this.id,
    required this.indexLabel,
    required this.title,
    required this.creatorHandle,
    required this.creatorName,
    required this.description,
    required this.tags,
    required this.audioTitle,
    required this.audioArtist,
    required this.algorithmMatchScore,
    required this.algorithmReason,
    required this.vector,
    required this.motionType,
    required this.duration,
    required this.destination,
    required this.likes,
    required this.comments,
    required this.saves,
    required this.shares,
    this.videoAssetPath,
    this.isLiked = false,
    this.isSaved = false,
  });

  static List<VideoItem> getSampleFeed() {
    return [
      VideoItem(
        id: 'vid-1',
        indexLabel: 'VIDEO 01',
        title: 'Hyper-Dimensional Fluid Motion',
        creatorHandle: '@aperture.motion',
        creatorName: 'Aperture Lab',
        description: 'Raymarching procedural fluid fields in real-time. Exploring turbulence frequencies and volumetric viscosity.',
        tags: ['#GenerativeArt', '#MotionDesign', '#CreativeCode', '#FluidDynamics'],
        audioTitle: 'Resonant Frequencies — Tape Drift',
        audioArtist: 'Aperture Soundworks',
        algorithmMatchScore: 0.984,
        algorithmReason: 'High affinity with Kinetic Waves & generative computing',
        vector: const AlgorithmVector(
          visualComplexity: 0.92,
          audioAffinity: 0.88,
          noveltyScore: 0.79,
          graphProximity: 0.95,
        ),
        motionType: VideoMotionType.kineticWave,
        videoAssetPath: 'assets/video_sample/13123780_1080_1920_60fps.mp4',
        duration: const Duration(seconds: 28),
        likes: 24820,
        comments: 1420,
        saves: 8310,
        shares: 3120,
        destination: TravelDestination(
          id: 'dest-kyoto',
          locationName: 'Arashiyama Bamboo Grove & River',
          cityCountry: 'Kyoto, Japan',
          flagEmoji: '🇯🇵',
          summary: 'Mystical bamboo tunnels, emerald river reflections, and ancient temple gardens.',
          transitInfo: '25 min from Kyoto Station via JR San-in Line',
          travelTime: '6h 30m flight + 25m express rail',
          estimatedArrivalTime: 'Tomorrow, 15:45 JST',
          optimalVisitingMonths: 'Oct – Nov (Momiji) & Mar – May (Sakura)',
          optimalMonthNumbers: [3, 4, 5, 10, 11],
          currentSeasonStatus: 'Prime Autumn Foliage Window',
          weatherExpectation: '19°C • Crisp Breeze & Golden Sunlight',
          contextualRecommendation: 'Inspired by this video\'s Kinetic Fluid motion: OpenClaw recommends a sunrise wooden boat ride along the Hozu River gorge, where morning mist and water turbulence mirror the fluid physics on screen.',
          vibeMatchReason: '98.4% aesthetic affinity with kinetic water & Zen fluid dynamics',
          vibeTags: ['Bamboo Forest', 'Zen Gardens', 'Riverboat', 'Historic Temples'],
          hotels: [
            HotelItem(
              id: 'htl-suiran',
              name: 'Suiran, A Luxury Collection Hotel',
              roomType: 'Shirosumire Riverview Suite',
              rating: 4.9,
              reviewCount: 1420,
              distance: '0.3 km away',
              distanceKm: 0.3,
              pricePerNight: 480,
              imageUrl: 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=600&q=80',
              amenities: ['Private Onsen', 'Riverfront View', 'Kaiseki Breakfast', 'Tea Salon'],
              aiHighlight: 'AI Top Pick: Unrivaled serenity right along the Hozu River with private garden hot springs.',
              contextualMatch: 'Front-row river views where morning mist mirrors the video\'s fluid motion simulation.',
              dealBadge: 'AI TOP PICK',
            ),
            HotelItem(
              id: 'htl-hoshinoya',
              name: 'Hoshinoya Kyoto Riverside Sanctuary',
              roomType: 'Pavilion Waterfront Deluxe',
              rating: 4.8,
              reviewCount: 890,
              distance: '0.8 km away',
              distanceKm: 0.8,
              pricePerNight: 620,
              imageUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=600&q=80',
              amenities: ['Private Boat Transfer', 'Forest Terrace', 'Zen Meditation', 'Fine Dining'],
              aiHighlight: 'Secluded 17th-century riverside ryokan reached by a magical wooden boat journey.',
              contextualMatch: 'Only accessible via wooden boat along the emerald waters seen in your feed.',
              dealBadge: 'ICONIC LUXURY',
            ),
            HotelItem(
              id: 'htl-thousand',
              name: 'The Thousand Kyoto Urban Oasis',
              roomType: 'Premier Minimalist King',
              rating: 4.7,
              reviewCount: 2180,
              distance: '1.4 km away',
              distanceKm: 1.4,
              pricePerNight: 210,
              imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=600&q=80',
              amenities: ['Bullet Train Access', 'Zen Modern Architecture', 'Cocktail Lounge', 'High-speed WiFi'],
              aiHighlight: 'Architectural marvel combining traditional Kyoto craftsmanship with modern comfort.',
              contextualMatch: 'Minimalist wood lattice design reflecting procedural generative structure.',
              dealBadge: 'BEST VALUE',
            ),
            HotelItem(
              id: 'htl-nagi',
              name: 'Nagi Kyoto Shijo Boutique',
              roomType: 'Deluxe Tatami Studio',
              rating: 4.6,
              reviewCount: 940,
              distance: '2.2 km away',
              distanceKm: 2.2,
              pricePerNight: 145,
              imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600&q=80',
              amenities: ['Bicycle Rental', 'Complimentary Sake', 'Handcrafted Tea', 'Central Location'],
              aiHighlight: 'Warm boutique hospitality within easy cycling distance of historic shrines.',
              contextualMatch: 'Great budget basecamp with free bikes to cycle along the riverbanks.',
              dealBadge: 'BUDGET FAVORITE',
            ),
          ],
        ),
      ),
      VideoItem(
        id: 'vid-2',
        indexLabel: 'VIDEO 02',
        title: 'Quantum Lattice Resonance',
        creatorHandle: '@matrix.vector',
        creatorName: 'Vector Collective',
        description: 'Multi-axis geometric wireframes shifting across 4D projective planes. Audio responsive tessellation.',
        tags: ['#Geometry', '#Tessellation', '#4DProjection', '#ModularSound'],
        audioTitle: 'Sub-bass Monolith (Modular Mix)',
        audioArtist: 'Vector Audio',
        algorithmMatchScore: 0.952,
        algorithmReason: 'Matched via audio-reactive geometry search patterns',
        vector: const AlgorithmVector(
          visualComplexity: 0.85,
          audioAffinity: 0.94,
          noveltyScore: 0.91,
          graphProximity: 0.82,
        ),
        motionType: VideoMotionType.quantumLattice,
        videoAssetPath: 'assets/video_sample/16518345_1080_1920_24fps.mp4',
        duration: const Duration(seconds: 34),
        likes: 18940,
        comments: 894,
        saves: 6140,
        shares: 2410,
        destination: TravelDestination(
          id: 'dest-iceland',
          locationName: 'Blue Lagoon & Reykjanes Lava Fields',
          cityCountry: 'Grindavík, Iceland',
          flagEmoji: '🇮🇸',
          summary: 'Geothermal azure waters, dramatic black lava expanses, and Aurora Borealis skies.',
          transitInfo: '20 min from Keflavík International Airport (KEF)',
          travelTime: '13h 40m (1 stop) + 20m shuttle from KEF',
          estimatedArrivalTime: 'Tomorrow, 19:20 GMT',
          optimalVisitingMonths: 'Sep – Mar (Northern Lights) & Jun – Aug (Midnight Sun)',
          optimalMonthNumbers: [9, 10, 11, 12, 1, 2, 3],
          currentSeasonStatus: 'Active Aurora Forecast (KP Index 4.8)',
          weatherExpectation: '2°C • Crisp Arctic Sky & Geothermal Steam',
          contextualRecommendation: 'Inspired by this video\'s Quantum Lattice: OpenClaw recommends late-night soaking in Silica mineral pools as multi-spectral Northern Lights auroras form geometric ribbons across the dark volcanic horizon.',
          vibeMatchReason: '95.2% harmonic match with glowing geometric lattices & aurora physics',
          vibeTags: ['Geothermal Spa', 'Lava Fields', 'Northern Lights', 'Volcanic Wonders'],
          hotels: [
            HotelItem(
              id: 'htl-retreat',
              name: 'The Retreat Hotel at Blue Lagoon',
              roomType: 'Lagoon Junior Suite',
              rating: 4.9,
              reviewCount: 780,
              distance: '0.1 km away',
              distanceKm: 0.1,
              pricePerNight: 890,
              imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&q=80',
              amenities: ['Private Lagoon Access', 'Subterranean Spa', 'Gourmet Moss Dining', 'Fireplace'],
              aiHighlight: 'AI Top Pick: Exclusive sanctuary with private geothermal waters carved directly into volcanic rock.',
              contextualMatch: 'Subterranean lava suites providing front-row viewing of the celestial lights.',
              dealBadge: 'AI TOP PICK',
            ),
            HotelItem(
              id: 'htl-silica',
              name: 'Silica Hotel Geothermal Haven',
              roomType: 'Lava View Double Room',
              rating: 4.8,
              reviewCount: 1120,
              distance: '0.4 km away',
              distanceKm: 0.4,
              pricePerNight: 420,
              imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=600&q=80',
              amenities: ['Dedicated Guests Lagoon', 'Aurora Wake-up Call', 'Lava Veranda', 'Free Breakfast'],
              aiHighlight: 'Surrounded by silent volcanic moss with private geothermal bathing exclusively for guests.',
              contextualMatch: 'Complimentary automated Aurora alarm alerts you when light arrays match the video pattern.',
              dealBadge: 'AURORA PRIME',
            ),
            HotelItem(
              id: 'htl-courtyard-ice',
              name: 'Courtyard Reykjavik Marina',
              roomType: 'Nordic Oceanfront King',
              rating: 4.6,
              reviewCount: 1650,
              distance: '2.8 km away',
              distanceKm: 2.8,
              pricePerNight: 195,
              imageUrl: 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=600&q=80',
              amenities: ['Harbor Ocean View', 'Nordic Gastropub', 'Airport Shuttle', 'Fitness Center'],
              aiHighlight: 'Vibrant waterfront setting near downtown Reykjavik harbor with easy day-trip departures.',
              contextualMatch: 'Coastal urban haven with geometric Nordic architectural detailing.',
              dealBadge: 'BEST VALUE',
            ),
            HotelItem(
              id: 'htl-northern-light',
              name: 'Northern Light Inn & Sky Lounge',
              roomType: 'Panoramic Sky View Room',
              rating: 4.5,
              reviewCount: 870,
              distance: '1.2 km away',
              distanceKm: 1.2,
              pricePerNight: 160,
              imageUrl: 'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=600&q=80',
              amenities: ['Glass Observatory Bar', 'Cozy Hearth Lounge', 'Free Waffles & Coffee', 'Free Shuttle'],
              aiHighlight: 'Glass dome observation lounge designed specifically for gazing at the Northern Lights.',
              contextualMatch: 'Glass-paneled roof lounge aligned to stellar navigation coordinates.',
              dealBadge: 'COZY RETREAT',
            ),
          ],
        ),
      ),
    ];
  }
}
