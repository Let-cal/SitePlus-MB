class SiteCreateRequest {
  final int? taskId;
  final int siteCategoryId;
  final int areaId;
  final String address;
  final double size;
  final int floor;
  final int totalFloor;
  final String description;
  final int status;
  final int? buildingId;

  SiteCreateRequest({
    this.taskId,
    required this.siteCategoryId,
    required this.areaId,
    required this.address,
    required this.size,
    required this.floor,
    required this.totalFloor,
    required this.description,
    required this.status,
    this.buildingId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'siteCategoryId': siteCategoryId,
      'areaId': areaId,
      'address': address,
      'size': size,
      'floor': floor,
      'totalFloor': totalFloor,
      'description': description,
      'buildingId': buildingId,
      'status': status,
      'brandId': null, // Theo yêu cầu, brandId luôn là null
    };
    // Chỉ thêm taskId nếu nó không null
    if (taskId != null) {
      json['taskId'] = taskId;
    }
    return json;
  }

  // Tạo SiteCreateRequest từ reportData
  factory SiteCreateRequest.fromReportData(
    Map<String, dynamic> reportData, {
    int? customStatus,
  }) {
    final siteInfo = reportData['siteInfo'];
    final int siteCategoryId = reportData['siteCategoryId'] ?? 0;
    final bool isInBuilding =
        reportData['reportType'] == 'Building' ||
        reportData['reportType'] == 'Internal Site';
    final int areaId = siteInfo['areaId'] ?? 0;
    // Chỉ lấy taskId nếu nó tồn tại trong siteInfo
    final int? taskId =
        siteInfo.containsKey('taskId')
            ? int.tryParse(siteInfo['taskId'].toString())
            : null;

    int? buildingId;
    if (isInBuilding && siteInfo['buildingId'] != null) {
      buildingId = int.tryParse(siteInfo['buildingId'].toString()) ?? 0;
    }
    int floor = 0;
    int totalFloor = 0;
    final double size =
        siteInfo['size'] != null && siteInfo['size'].toString().isNotEmpty
            ? double.tryParse(siteInfo['size'].toString()) ?? 0
            : 0;

    if (siteInfo['floor'] != null && siteInfo['floor'].toString().isNotEmpty) {
      floor = int.tryParse(siteInfo['floor'].toString()) ?? 0;
    }
    if (isInBuilding &&
        siteInfo['totalFloor'] != null &&
        siteInfo['totalFloor'].toString().isNotEmpty) {
      totalFloor = int.tryParse(siteInfo['totalFloor'].toString()) ?? 0;
    }
    final int status =
        siteInfo['status'] != null && siteInfo['status'].toString().isNotEmpty
            ? int.tryParse(siteInfo['status'].toString()) ?? (customStatus ?? 2)
            : (customStatus ?? 2);
    return SiteCreateRequest(
      taskId: taskId,
      siteCategoryId: siteCategoryId,
      areaId: areaId,
      address: siteInfo['address'] ?? '',
      size: size,
      floor: floor,
      totalFloor: totalFloor,
      description: reportData['additionalNotes'] ?? '',
      buildingId: buildingId,
      status: status,
    );
  }
}

class BuildingCreateRequest {
  final int id;
  final String name;
  final int areaId;
  final String areaName;
  final int status;
  final String statusName;

  BuildingCreateRequest({
    required this.id,
    required this.name,
    required this.areaId,
    required this.areaName,
    required this.status,
    required this.statusName,
  });
  factory BuildingCreateRequest.fromJson(Map<String, dynamic> json) {
    return BuildingCreateRequest(
      id: json['id'],
      name: json['name'],
      areaId: json['areaId'],
      areaName: json['areaName'],
      status: json['status'],
      statusName: json['statusName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'areaId': areaId,
      'areaName': areaName,
      'status': status,
      'statusName': statusName,
    };
  }
}
