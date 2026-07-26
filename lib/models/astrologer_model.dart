class Astrologer {
  final String id;
  final String name;
  final String title;
  final String experience;
  final double rating;
  final int reviewsCount;
  final List<String> languages;
  final String imageUrl;
  final bool isOnline;
  final double pricePerMin;

  Astrologer({
    required this.id,
    required this.name,
    required this.title,
    required this.experience,
    required this.rating,
    required this.reviewsCount,
    required this.languages,
    required this.imageUrl,
    this.isOnline = true,
    required this.pricePerMin,
  });
}
