class NotificationModel {
  final int notificationId;
  final String notificationName;
  final String description;
  final String taskId;
  final String taskName;
  final String cityDistrict;
  final String taskDescription;
  final DateTime createdAt;
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
    this.isRead = false,
  });
}

class NotificationDto {
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;
  final int taskId;
  final String taskName;
  final String taskDescription;
  bool isRead;

  NotificationDto({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.taskId,
    required this.taskName,
    required this.taskDescription,
    this.isRead = false,
  });
  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      taskId: json['taskId'],
      taskName: json['taskName'],
      taskDescription: json['taskDescription'],
      isRead: false, // Mặc định là chưa đọc khi lấy từ API
    );
  }

  // Chuyển đổi thành NotificationModel để hiển thị trên UI
  NotificationModel toModel() {
    return NotificationModel(
      notificationId: id,
      notificationName: name,
      description: description,
      taskId: 'T-${taskId.toString()}',
      taskName: taskName,
      cityDistrict: 'TP.HCM', // Giá trị mặc định vì API không trả về trường này
      taskDescription: taskDescription,
      createdAt: createdAt,
      isRead: isRead,
    );
  }
}
