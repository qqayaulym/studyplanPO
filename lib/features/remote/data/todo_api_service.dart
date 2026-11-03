import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../domain/remote_todo.dart';

/// REST API endpoint-тері (https://jsonplaceholder.typicode.com):
///
///   GET    /todos?userId=1&_limit=15  — тізімді алу
///   GET    /todos/{id}                — бір жазбаны алу
///   POST   /todos                     — жаңа жазба жасау
///   PUT    /todos/{id}                — жазбаны толық ауыстыру
///   PATCH  /todos/{id}                — жазбаның бір бөлігін өзгерту
///   DELETE /todos/{id}                — жазбаны жою
class TodoApiService {
  final ApiClient _api;
  TodoApiService({ApiClient? api}) : _api = api ?? ApiClient.instance;

  static const int userId = 1;

  Future<List<RemoteTodo>> fetchAll({int limit = 15}) async {
    final json = await _api.get('/todos',
        query: {'userId': '$userId', '_limit': '$limit'});
    if (json is! List) throw const ParseException();
    return json.map(RemoteTodo.fromJson).toList();
  }

  Future<RemoteTodo> fetchOne(int id) async =>
      RemoteTodo.fromJson(await _api.get('/todos/$id'));

  Future<RemoteTodo> create(String title, {bool completed = false}) async {
    final json = await _api.post('/todos',
        {'userId': userId, 'title': title, 'completed': completed});
    return RemoteTodo.fromJson(json);
  }

  Future<RemoteTodo> replace(RemoteTodo todo) async =>
      RemoteTodo.fromJson(await _api.put('/todos/${todo.id}', todo.toJson()));

  Future<RemoteTodo> patch(int id, Map<String, dynamic> fields) async =>
      RemoteTodo.fromJson(await _api.patch('/todos/$id', fields));

  Future<void> delete(int id) async {
    await _api.delete('/todos/$id');
  }
}
