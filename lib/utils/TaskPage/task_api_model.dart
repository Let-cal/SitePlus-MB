import '../constants.dart';

class BrandInfo {
  final String name;

  BrandInfo({required this.name});
}

class BuildingInfo {
  final String name;

  BuildingInfo({required this.name});
}

class RequestInfo {
  final String id;
  final BrandInfo brand;

  RequestInfo({required this.id, required this.brand});
}

class SiteInfo {
  final String id;
  final String areaName;
  final String address;
  final BuildingInfo? building;

  SiteInfo({
    required this.id,
    required this.areaName,
    required this.address,
    this.building,
  });
}

class Task {
  final String id;
  final String name;
  final String description;
  final String status;
  final String priority;
  final String? requestId;
  final RequestInfo? request;
  final SiteInfo? site;
  final DateTime deadline;
  final String areaName;
  final int? areaId;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.priority,
    this.requestId,
    this.request,
    this.site,
    required this.deadline,
    required this.areaName,
    required this.areaId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // Convert numerical status to string status for display
    String statusText;
    switch (json['status']) {
      case 1:
        statusText = STATUS_CHUA_NHAN;
        break;
      case 2:
        statusText = STATUS_DA_NHAN;
        break;
      case 3:
        statusText = STATUS_HOAN_THANH;
        break;
      default:
        statusText = "Không xác định";
    }

    // Convert numerical priority to string priority for display
    String priorityText;
    switch (json['priority']) {
      case 1:
        priorityText = PRIORITY_THAP;
        break;
      case 2:
        priorityText = PRIORITY_TRUNG_BINH;
        break;
      case 3:
        priorityText = PRIORITY_CAO;
        break;
      default:
        priorityText = "Không xác định";
    }

    // Create RequestInfo if brandInfo exists
    RequestInfo? requestInfo;
    if (json['brandInfo'] != null && json['brandInfo']['requestId'] != 0) {
      requestInfo = RequestInfo(
        id: json['brandInfo']['requestId'].toString(),
        brand: BrandInfo(
          name: json['brandInfo']['brandName'] ?? "Không xác định",
        ),
      );
    }

    // Extract areaName directly from location object
    String areaName = "Không xác định";
    if (json['location'] != null && json['location']['areaName'] != null) {
      areaName = json['location']['areaName'];
    }
    int? areaId;
    if (json['location'] != null && json['location']['areaId'] != null) {
      areaId = json['location']['areaId'];
    }

    // Create SiteInfo if location exists and status is completed
    SiteInfo? siteInfo;
    if (json['location'] != null &&
        json['location']['siteId'] != null &&
        json['location']['siteId'] != 0) {
      BuildingInfo? buildingInfo;
      if (json['location']['buildingName'] != null) {
        buildingInfo = BuildingInfo(name: json['location']['buildingName']);
      }

      siteInfo = SiteInfo(
        id: json['location']['siteId'].toString(),
        areaName: areaName,
        address: json['location']['siteAddress'] ?? "Không xác định",
        building: buildingInfo,
      );
    }

    return Task(
      id: json['id'].toString(),
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      status: statusText,
      priority: priorityText,
      requestId:
          json['brandInfo'] != null && json['brandInfo']['requestId'] != 0
              ? json['brandInfo']['requestId'].toString()
              : null,
      request: requestInfo,
      site: siteInfo,
      deadline: DateTime.parse(json['deadline']),
      areaName: areaName,
      areaId: areaId,
    );
  }
}

class TaskResponse {
  final int page;
  final int totalPage;
  final int totalRecords;
  final List<Task> listData;

  TaskResponse({
    required this.page,
    required this.totalPage,
    required this.totalRecords,
    required this.listData,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return TaskResponse(
      page: data['page'],
      totalPage: data['totalPage'],
      totalRecords: data['totalRecords'],
      listData:
          (data['listData'] as List)
              .map((item) => Task.fromJson(item))
              .toList(),
    );
  }
}
