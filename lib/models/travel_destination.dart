class HotelItem {
  final String id;
  final String name;
  final String roomType;
  final double rating;
  final int reviewCount;
  final String distance;
  final double distanceKm;
  final int pricePerNight;
  final String currency;
  final String imageUrl;
  final List<String> amenities;
  final String aiHighlight;
  final String? contextualMatch;
  final String? dealBadge;
  bool isFavorite;

  HotelItem({
    required this.id,
    required this.name,
    required this.roomType,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.distanceKm,
    required this.pricePerNight,
    this.currency = '\$',
    required this.imageUrl,
    required this.amenities,
    required this.aiHighlight,
    this.contextualMatch,
    this.dealBadge,
    this.isFavorite = false,
  });
}

class TravelDestination {
  final String id;
  final String locationName;
  final String cityCountry;
  final String flagEmoji;
  final String summary;
  final String transitInfo;
  final String travelTime;
  final String estimatedArrivalTime;
  final String optimalVisitingMonths;
  final List<int> optimalMonthNumbers; // 1 to 12
  final String currentSeasonStatus;
  final String weatherExpectation;
  final String contextualRecommendation;
  final String vibeMatchReason;
  final List<String> vibeTags;
  final List<HotelItem> hotels;

  const TravelDestination({
    required this.id,
    required this.locationName,
    required this.cityCountry,
    required this.flagEmoji,
    required this.summary,
    required this.transitInfo,
    required this.travelTime,
    required this.estimatedArrivalTime,
    required this.optimalVisitingMonths,
    required this.optimalMonthNumbers,
    required this.currentSeasonStatus,
    required this.weatherExpectation,
    required this.contextualRecommendation,
    required this.vibeMatchReason,
    required this.vibeTags,
    required this.hotels,
  });
}
