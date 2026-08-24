class MagazineArticleModel {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String content;
  final String imageUrl;
  final String? videoUrl;
  final String author;
  final DateTime publishedAt;
  final int likesCount;
  final int commentsCount;
  final bool isBookmarked;

  MagazineArticleModel({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    required this.imageUrl,
    this.videoUrl,
    required this.author,
    required this.publishedAt,
    required this.likesCount,
    required this.commentsCount,
    this.isBookmarked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'summary': summary,
      'content': content,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'author': author,
      'publishedAt': publishedAt.toIso8601String(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isBookmarked': isBookmarked,
    };
  }

  factory MagazineArticleModel.fromMap(Map<String, dynamic> map) {
    return MagazineArticleModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? 'Vedic Insights',
      summary: map['summary'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      videoUrl: map['videoUrl'],
      author: map['author'] ?? 'AstroDashaCare Editorial',
      publishedAt: map['publishedAt'] != null ? DateTime.parse(map['publishedAt']) : DateTime.now(),
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      isBookmarked: map['isBookmarked'] ?? false,
    );
  }
}
