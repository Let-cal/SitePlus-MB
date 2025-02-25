// Mô hình Task
class Task {
  final String id;
  final String name;
  final String description;
  final String status; // Active, In Progress, Done
  final String priority;
  final String? areaId;
  final String? requestId; // Liên kết đến BrandRequest
  final String? siteId; // Liên kết đến Site khi task hoàn thành
  final String assignedTo;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Dữ liệu liên kết (sẽ được điền khi cần thiết)
  final BrandRequest? request;
  final Site? site;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.priority,
    this.areaId,
    this.requestId,
    this.siteId,
    required this.assignedTo,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.request,
    this.site,
  });
}

// Mô hình BrandRequest
class BrandRequest {
  final String id;
  final String brandId;
  final String description;
  final String status;
  final DateTime createdAt;

  // Dữ liệu liên kết
  final Brand? brand;

  BrandRequest({
    required this.id,
    required this.brandId,
    required this.description,
    required this.status,
    required this.createdAt,
    this.brand,
  });
}

// Mô hình Brand
class Brand {
  final String id;
  final String name;
  final String logo;

  Brand({required this.id, required this.name, required this.logo});
}

// Mô hình Site
class Site {
  final String id;
  final String name;
  final String? buildingId;
  final String district;
  final String city;
  final String address;

  // Dữ liệu liên kết
  final Building? building;

  Site({
    required this.id,
    required this.name,
    this.buildingId,
    required this.district,
    required this.city,
    required this.address,
    this.building,
  });
}

// Mô hình Building
class Building {
  final String id;
  final String name;
  final String address;

  Building({required this.id, required this.name, required this.address});
}
