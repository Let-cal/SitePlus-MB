// lib/models/site_create_request.dart
class SiteCreateRequest {
  final String name;
  final Building? building;
  final int? brandId;
  final int? floor;
  final int siteCategoryId;
  final String description;
  final int areaId;
  final String address;
  final double size;

  SiteCreateRequest({
    required this.name,
    this.building,
    this.brandId,
    this.floor,
    required this.siteCategoryId,
    required this.description,
    required this.areaId,
    required this.address,
    required this.size,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'siteCategoryId': siteCategoryId,
      'description': description,
      'areaId': areaId,
      'address': address,
      'size': size,
    };

    // Chỉ thêm building và floor nếu site category là mặt bằng trong tòa nhà
    if (building != null) {
      data['building'] = building!.toJson();
    }

    if (floor != null) {
      data['floor'] = floor;
    }

    // brandId luôn là null theo yêu cầu
    data['brandId'] = null;

    return data;
  }

  // Tạo SiteCreateRequest từ form data
  factory SiteCreateRequest.fromReportData(
    Map<String, dynamic> reportData,
  ) {
    final siteInfo = reportData['siteInfo'];
    final int siteCategoryId = reportData['siteCategoryId'] ?? 0;
    final bool isInBuilding = reportData['reportType'] == 'Building';

    // Tính toán areaId từ city và district
    // Giả sử areaId được tính từ city và district
    final String? city = siteInfo['city'];
    final String? district = siteInfo['district'];
    final int areaId = _calculateAreaId(city, district);

    Building? building;
    int? floor;

    if (isInBuilding && siteCategoryId != 1) {
      building = Building(
        name: siteInfo['buildingName'] ?? '',
        areaId: areaId,
        status: 'Available',
      );

      // Parse floor number nếu có
      if (siteInfo['floorNumber'] != null &&
          siteInfo['floorNumber'].toString().isNotEmpty) {
        floor = int.tryParse(siteInfo['floorNumber'].toString()) ?? 0;
      }
    }

    return SiteCreateRequest(
      name: siteInfo['siteName'] ?? '',
      building: building,
      brandId: null,
      floor: floor,
      siteCategoryId: siteCategoryId,
      description: reportData['additionalNotes'] ?? '',
      areaId: areaId,
      address: siteInfo['address'] ?? '',
      size: 0, // Giả sử size là 0 hoặc cần được tính toán từ nguồn khác
    );
  }

  // Hàm helper để tính toán areaId từ city và district
  static int _calculateAreaId(String? city, String? district) {
    // Trong thực tế, bạn có thể cần một logic phức tạp hơn
    // hoặc một API call riêng để lấy areaId
    if (city == null || district == null) return 0;

    // Giả sử một thuật toán đơn giản để demo
    final Map<String, int> cityCodes = {
      'Hà Nội': 1,
      'TP.HCM': 2,
      'Đà Nẵng': 3,
      'Cần Thơ': 4,
      'Hải Phòng': 5,
    };

    return cityCodes[city] ?? 0;
  }
}

class Building {
  final String name;
  final int areaId;
  final String status;

  Building({required this.name, required this.areaId, required this.status});

  Map<String, dynamic> toJson() {
    return {'name': name, 'areaId': areaId, 'status': status};
  }
}
