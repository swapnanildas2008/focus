class TodoItem {
  int? id;
  String title;
  String description;
  DateTime createdAt;
  DateTime? dueTime;
  bool isCompleted;
  int priority; // 0: Low, 1: Medium, 2: High
  int colorIndex;
  int estimatedMinutes;

  TodoItem({
    this.id,
    required this.title,
    this.description = '',
    required this.createdAt,
    this.dueTime,
    this.isCompleted = false,
    this.priority = 0,
    this.colorIndex = 0,
    this.estimatedMinutes = 25,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'dueTime': dueTime?.millisecondsSinceEpoch,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority,
      'colorIndex': colorIndex,
      'estimatedMinutes': estimatedMinutes,
    };
  }

  static TodoItem fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      dueTime: map['dueTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['dueTime']) 
          : null,
      isCompleted: map['isCompleted'] == 1,
      priority: map['priority'] ?? 0,
      colorIndex: map['colorIndex'] ?? 0,
      estimatedMinutes: map['estimatedMinutes'] ?? 25,
    );
  }
}
