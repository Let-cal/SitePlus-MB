// lib/models/customer_segment.dart
class CustomerSegment {
  final int id;
  final String name;
  final int industryId;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerSegment({
    required this.id,
    required this.name,
    required this.industryId,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerSegment.fromJson(Map<String, dynamic> json) {
    return CustomerSegment(
      id: json['id'],
      name: json['name'],
      industryId: json['industryId'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
