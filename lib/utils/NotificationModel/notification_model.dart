// notification_model.dart
class NotificationModel {
  final int notificationId;
  final String notificationName;
  final String description;
  final String taskId;
  final String taskName;
  final String cityDistrict;
  final String taskDescription;
  final DateTime createdAt;
  final DateTime? taskDeadline;
  final String? areaName;
  final bool isRead;

  NotificationModel({
    required this.notificationId,
    required this.notificationName,
    required this.description,
    required this.taskId,
    required this.taskName,
    required this.cityDistrict,
    required this.taskDescription,
    required this.createdAt,
    this.taskDeadline,
    this.areaName,
    this.isRead = false,
  });
}

class NotificationDto {
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;
  final TaskDto task;
  bool isRead;

  NotificationDto({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.task,
    this.isRead = false,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      task: TaskDto.fromJson(json['task'] as Map<String, dynamic>),
      isRead: false, // Mặc định là chưa đọc khi lấy từ API
    );
  }

  // Chuyển đổi thành NotificationModel để hiển thị trên UI
  NotificationModel toModel() {
    final cityDistrict =
        '${task.district}${task.areaName != null ? ', ${task.areaName}' : ''}';

    return NotificationModel(
      notificationId: id,
      notificationName: name,
      description: description,
      taskId: 'T-${task.id.toString()}',
      taskName: task.name,
      cityDistrict: cityDistrict,
      taskDescription: task.description,
      createdAt: createdAt,
      taskDeadline: task.deadline,
      areaName: task.areaName,
      isRead: isRead,
    );
  }

  // Chuyển đổi thành NotificationModel giản lược cho CompactView
  NotificationModel toCompactModel() {
    return NotificationModel(
      notificationId: id,
      notificationName: name,
      description: description,
      taskId: 'T-${task.id.toString()}',
      taskName: task.name,
      cityDistrict: task.district,
      taskDescription: task.description,
      createdAt: createdAt,
      isRead: isRead,
    );
  }
}

class TaskDto {
  final int id;
  final String name;
  final String description;
  final String? areaName;
  final String district;
  final DateTime? deadline;
  final DateTime createdAt;

  TaskDto({
    required this.id,
    required this.name,
    required this.description,
    this.areaName,
    required this.district,
    this.deadline,
    required this.createdAt,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      areaName: json['areaName'] as String?,
      district: json['district'] as String,
      deadline:
          json['deadline'] != null
              ? DateTime.parse(json['deadline'] as String)
              : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
