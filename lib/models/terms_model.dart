class TermItemModel {
  final String id;
  final String title;
  final String description;
  final int orderIndex;

  TermItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.orderIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'orderIndex': orderIndex,
    };
  }

  factory TermItemModel.fromMap(Map<String, dynamic> map) {
    return TermItemModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      orderIndex: map['orderIndex'] ?? 0,
    );
  }
}
