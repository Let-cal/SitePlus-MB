class SiteCreateRequest {
  final String name;
  final int taskId;
  final int siteCategoryId;
  final int areaId;
  final String address;
  final double size;
  final int floor;
  final String description;
  final int buildingId;

  SiteCreateRequest({
    required this.name,
    required this.taskId,
    required this.siteCategoryId,
    required this.areaId,
    required this.address,
    required this.size,
    required this.floor,
    required this.description,
    required this.buildingId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'taskId': taskId,
      'siteCategoryId': siteCategoryId,
      'areaId': areaId,
      'address': address,
      'size': size,
      'floor': floor,
      'description': description,
      'buildingId': buildingId,
      'brandId': null, // Theo yêu cầu, brandId luôn là null
    };
  }

  // Tạo SiteCreateRequest từ reportData
  factory SiteCreateRequest.fromReportData(Map<String, dynamic> reportData) {
    final siteInfo = reportData['siteInfo'];
    final int siteCategoryId = reportData['siteCategoryId'] ?? 0;
    final bool isInBuilding = reportData['reportType'] == 'Building';
    final int areaId = siteInfo['areaId'] ?? 0;
    // Chuyển taskId từ chuỗi sang số nguyên
    final int taskId = int.tryParse(siteInfo['taskId'].toString()) ?? 0;
    int buildingId = 0;
    if (isInBuilding && siteInfo['buildingId'] != null) {
      // Chuyển đổi buildingId thành int để đảm bảo
      buildingId = int.tryParse(siteInfo['buildingId'].toString()) ?? 0;
    }
    int floor = 0;
    // Chuyển giá trị size sang double
    final double size =
        siteInfo['size'] != null && siteInfo['size'].toString().isNotEmpty
            ? double.tryParse(siteInfo['size'].toString()) ?? 0
            : 0;

    if (isInBuilding &&
        siteInfo['floorNumber'] != null &&
        siteInfo['floorNumber'].toString().isNotEmpty) {
      floor = int.tryParse(siteInfo['floorNumber'].toString()) ?? 0;
    }

    return SiteCreateRequest(
      name: siteInfo['siteName'] ?? '',
      taskId: taskId,
      siteCategoryId: siteCategoryId,
      areaId: areaId,
      address: siteInfo['address'] ?? '',
      size: size,
      floor: floor,
      description: reportData['additionalNotes'] ?? '',
      buildingId: buildingId,
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
