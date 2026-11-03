import '../../../core/network/api_exceptions.dart';

/// Серверлік жазба (JSONPlaceholder /todos). JSON ↔ Dart Model.
/// {"userId": 1, "id": 1, "title": "delectus aut autem", "completed": false}
class RemoteTodo {
  final int id;
  final int userId;
  final String title;
  final bool completed;

  const RemoteTodo({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });

  RemoteTodo copyWith({String? title, bool? completed, int? id}) => RemoteTodo(
        id: id ?? this.id,
        userId: userId,
        title: title ?? this.title,
        completed: completed ?? this.completed,
      );

  /// JSON → модель. Өріс жоқ немесе типі басқа болса ParseException тастайды.
  factory RemoteTodo.fromJson(dynamic json) {
    if (json is! Map) throw const ParseException();
    final id = json['id'];
    final userId = json['userId'];
    final title = json['title'];
    final completed = json['completed'];
    if (id is! int || title is! String) throw const ParseException();
    return RemoteTodo(
      id: id,
      userId: userId is int ? userId : 1,
      title: title,
      completed: completed is bool ? completed : false,
    );
  }

  /// Модель → JSON (POST / PUT денесі).
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'id': id,
        'title': title,
        'completed': completed,
      };
}
