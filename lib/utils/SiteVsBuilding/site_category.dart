class SiteCategory {
  final int id;
  final String name;
  final String englishName;
  final DateTime createdAt;
  final DateTime updatedAt;

  SiteCategory({
    required this.id,
    required this.name,
    required this.englishName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SiteCategory.fromJson(Map<String, dynamic> json) {
    // Map Vietnamese names to English
    final vietnameseName = json['name'] as String;
    String englishName;
    switch (vietnameseName) {
      case 'Mặt bằng nội khu':
        englishName = 'Internal Site';
        break;
      case 'Mặt bằng độc lập':
        englishName = 'Independent Site';
        break;
      default:
        englishName = vietnameseName; // Fallback to original if no translation
    }

    return SiteCategory(
      id: json['id'],
      name: vietnameseName,
      englishName: englishName,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  toJson() {}
}
