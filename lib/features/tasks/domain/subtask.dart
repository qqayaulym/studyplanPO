/// Тапсырма қадамы / чек-лист тармағы (Entity №4). Байланыс: Task 1 — N SubTask.
class SubTask {
  final String id;
  final String taskId;
  final String title;
  final bool isDone;
  final DateTime createdAt;

  const SubTask({
    required this.id,
    required this.taskId,
    required this.title,
    required this.createdAt,
    this.isDone = false,
  });

  SubTask copyWith({String? title, bool? isDone}) => SubTask(
        id: id,
        taskId: taskId,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'taskId': taskId,
        'title': title,
        'isDone': isDone,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory SubTask.fromMap(Map<dynamic, dynamic> m) => SubTask(
        id: m['id'] as String,
        taskId: m['taskId'] as String,
        title: m['title'] as String,
        isDone: (m['isDone'] as bool?) ?? false,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
      );
}
