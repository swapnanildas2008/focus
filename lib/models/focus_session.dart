class FocusSession {
  int? id;
  DateTime startTime;
  DateTime? endTime;
  int durationMinutes;
  bool isCompleted;
  int? todoItemId;

  FocusSession({
    this.id,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    this.isCompleted = false,
    this.todoItemId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted ? 1 : 0,
      'todoItemId': todoItemId,
    };
  }

  static FocusSession fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: map['endTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime']) 
          : null,
      durationMinutes: map['durationMinutes'],
      isCompleted: map['isCompleted'] == 1,
      todoItemId: map['todoItemId'],
    );
  }
}
