/// Оқу тапсырмасы (Entity №3). Сыртқы кілттер: userId → User, subjectId → Subject.
class Task {
  final String id;
  final String userId;
  final String subjectId;
  final String title;
  final String description;
  final DateTime deadline;
  final String reminder;
  final bool isDone;
  final bool isFavorite;
  final DateTime createdAt;

  /// Серверлік id (JSONPlaceholder todo.id). null — тапсырма тек жергілікті.
  final int? remoteId;

  const Task({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.title,
    required this.deadline,
    required this.createdAt,
    this.description = '',
    this.reminder = 'Еске салғышсыз',
    this.isDone = false,
    this.isFavorite = false,
    this.remoteId,
  });

  Task copyWith({
    String? subjectId,
    String? title,
    String? description,
    DateTime? deadline,
    String? reminder,
    bool? isDone,
    bool? isFavorite,
    int? remoteId,
  }) {
    return Task(
      id: id,
      userId: userId,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      reminder: reminder ?? this.reminder,
      isDone: isDone ?? this.isDone,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'subjectId': subjectId,
        'title': title,
        'description': description,
        'deadline': deadline.millisecondsSinceEpoch,
        'reminder': reminder,
        'isDone': isDone,
        'isFavorite': isFavorite,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'remoteId': remoteId,
      };

  factory Task.fromMap(Map<dynamic, dynamic> m) => Task(
        id: m['id'] as String,
        userId: m['userId'] as String,
        subjectId: m['subjectId'] as String,
        title: m['title'] as String,
        description: (m['description'] as String?) ?? '',
        deadline: DateTime.fromMillisecondsSinceEpoch(m['deadline'] as int),
        reminder: (m['reminder'] as String?) ?? 'Еске салғышсыз',
        isDone: (m['isDone'] as bool?) ?? false,
        isFavorite: (m['isFavorite'] as bool?) ?? false,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
        remoteId: m['remoteId'] as int?,
      );
}
