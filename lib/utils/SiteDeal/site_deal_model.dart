// lib/utils/SiteDeal/site_deal_model.dart
class SiteDeal {
  final int id;
  final int siteId;
  final double proposedPrice;
  final String leaseTerm;
  final double deposit;
  final String additionalTerms;
  final int status;
  final String depositMonth;
  final String statusName;
  final DateTime createdAt;

  SiteDeal({
    required this.id,
    required this.siteId,
    required this.proposedPrice,
    required this.leaseTerm,
    required this.deposit,
    required this.additionalTerms,
    required this.status,
    required this.depositMonth,
    required this.statusName,
    required this.createdAt,
  });

  factory SiteDeal.fromJson(Map<String, dynamic> json) {
    return SiteDeal(
      id: json['id'] ?? 0,
      siteId: json['siteId'] ?? 0,
      proposedPrice: (json['proposedPrice'] as num?)?.toDouble() ?? 0.0,
      leaseTerm: json['leaseTerm'] ?? '',
      deposit: (json['deposit'] as num?)?.toDouble() ?? 0.0,
      additionalTerms: json['additionalTerms'] ?? '',
      status: json['status'] ?? 0,
      depositMonth: json['depositMonth'] ?? '',
      statusName: json['statusName'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siteId': siteId,
      'proposedPrice': proposedPrice,
      'leaseTerm': leaseTerm,
      'deposit': deposit,
      'additionalTerms': additionalTerms,
      'status': status,
      'depositMonth': depositMonth,
      'statusName': statusName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}