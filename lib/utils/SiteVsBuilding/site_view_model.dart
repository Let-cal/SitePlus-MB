class Site {
  final int id;
  final int brandId;
  final int floor;
  final int siteCategoryId;
  final int areaId;
  final String address;
  final double size;
  final int status;
  final String statusName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Task? task;
  final BuildingViewModel? building;
  final List<Image>? images;
  final List<Site>? matchingSites;

  Site({
    required this.id,
    required this.brandId,
    required this.floor,
    required this.siteCategoryId,
    required this.areaId,
    required this.address,
    required this.size,
    required this.status,
    required this.statusName,
    required this.createdAt,
    required this.updatedAt,
    this.task,
    this.building,
    this.images,
    this.matchingSites,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'] ?? 0,
      brandId: json['brandId'] ?? 0,
      floor: json['floor'] ?? 0,
      siteCategoryId: json['siteCategoryId'] ?? 0,
      areaId: json['areaId'] ?? 0,
      address: json['address'] ?? '',
      size: json['size'] ?? 0.0,
      status: json['status'] ?? 0,
      statusName: json['statusName'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? ''),
      updatedAt: DateTime.parse(json['updatedAt'] ?? ''),
      task: json['task'] != null ? Task.fromJson(json['task']) : null,
      building:
          json['building'] != null ? BuildingViewModel.fromJson(json['building']) : null,
      images:
          json['images'] != null
              ? List<Image>.from(json['images'].map((x) => Image.fromJson(x)))
              : [],
      matchingSites:
          json['matchingSites'] != null
              ? List<Site>.from(
                json['matchingSites'].map((x) => Site.fromJson(x)),
              )
              : [],
    );
  }

  Object? toJson() {}
}

class Task {
  final int id;
  final String name;
  final String? description;
  final int status;
  final String statusName;
  final int priority;
  final DateTime deadline;
  final int assignedToUserId;

  Task({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.statusName,
    required this.priority,
    required this.deadline,
    required this.assignedToUserId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
      statusName: json['statusName'],
      priority: json['priority'],
      deadline: DateTime.parse(json['deadline']),
      assignedToUserId: json['assignedToUserId'],
    );
  }
}

class BuildingViewModel{
  final int id;
  final String name;
  final int areaId;
  final String status;

  BuildingViewModel({
    required this.id,
    required this.name,
    required this.areaId,
    required this.status,
  });

  factory BuildingViewModel.fromJson(Map<String, dynamic> json) {
    return BuildingViewModel(
      id: json['id'],
      name: json['name'],
      areaId: json['areaId'],
      status: json['status'],
    );
  }
}

class Image {
  final int id;
  final String url;

  Image({required this.id, required this.url});

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(id: json['id'], url: json['url']);
  }
}
