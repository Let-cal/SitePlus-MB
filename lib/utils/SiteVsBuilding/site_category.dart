class SiteCategory {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  SiteCategory({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SiteCategory.fromJson(Map<String, dynamic> json) {
    return SiteCategory(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  toJson() {}
}
