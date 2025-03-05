class Site {
  final int id;
  final int? buildingId;
  final Building? building;
  final int siteCategoryId;
  final SiteCategory siteCategory;
  final String address;
  final double size;
  final int status;
  final String statusName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int areaId;
  final List<dynamic> matchingSites;

  const Site({
    required this.id,
    this.buildingId,
    this.building,
    required this.siteCategoryId,
    required this.siteCategory,
    required this.address,
    required this.size,
    required this.status,
    required this.statusName,
    required this.createdAt,
    required this.updatedAt,
    required this.areaId,
    required this.matchingSites,
  });
}

class Building {
  final int id;
  final String name;
  final int areaId;
  final Area area;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Building({
    required this.id,
    required this.name,
    required this.areaId,
    required this.area,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}

class Area {
  final int id;
  final String name;
  final int districtId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Area({
    required this.id,
    required this.name,
    required this.districtId,
    required this.createdAt,
    required this.updatedAt,
  });
}

class SiteCategory {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SiteCategory({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
}