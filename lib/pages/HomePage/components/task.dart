class Task {
  final String id;
  final String name;
  final String description;
  final String status;
  final String priority;
  final String areaId;
  final String requestId;
  final String assignedTo;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.priority,
    required this.areaId,
    required this.requestId,
    required this.assignedTo,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
  });
}

