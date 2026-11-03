import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studyplan/core/network/api_client.dart';
import 'package:studyplan/core/network/api_exceptions.dart';
import 'package:studyplan/features/remote/data/todo_api_service.dart';
import 'package:studyplan/features/remote/domain/remote_todo.dart';

/// REST қабатының тесттері: нақты интернет керек емес (MockClient).
TodoApiService serviceWith(MockClientHandler handler,
    {Duration timeout = const Duration(seconds: 2)}) {
  return TodoApiService(
      api: ApiClient(client: MockClient(handler), timeout: timeout));
}

http.Response json(Object body, [int code = 200]) => http.Response(
    jsonEncode(body), code,
    headers: {'content-type': 'application/json; charset=utf-8'});

void main() {
  test('GET: JSON → RemoteTodo тізімі', () async {
    final s = serviceWith((req) async {
      expect(req.method, 'GET');
      expect(req.url.path, '/todos');
      return json([
        {'userId': 1, 'id': 1, 'title': 'a', 'completed': false},
        {'userId': 1, 'id': 2, 'title': 'ә', 'completed': true},
      ]);
    });
    final list = await s.fetchAll();
    expect(list.length, 2);
    expect(list[1].completed, isTrue);
  });

  test('POST: дене жіберіледі, жауап модельге айналады', () async {
    final s = serviceWith((req) async {
      expect(req.method, 'POST');
      expect(jsonDecode(req.body)['title'], 'Жаңа');
      return json({'userId': 1, 'id': 201, 'title': 'Жаңа', 'completed': false}, 201);
    });
    final todo = await s.create('Жаңа');
    expect(todo.id, 201);
  });

  test('PUT, PATCH, DELETE әдістері мен жолдары', () async {
    final methods = <String>[];
    final s = serviceWith((req) async {
      methods.add('${req.method} ${req.url.path}');
      if (req.method == 'DELETE') return json({});
      return json({'userId': 1, 'id': 5, 'title': 'x', 'completed': true});
    });
    await s.replace(const RemoteTodo(id: 5, userId: 1, title: 'x', completed: true));
    await s.patch(5, {'completed': true});
    await s.delete(5);
    expect(methods, ['PUT /todos/5', 'PATCH /todos/5', 'DELETE /todos/5']);
  });

  test('Сервер қатесі (500) → ServerException', () async {
    final s = serviceWith((req) async => http.Response('err', 500));
    expect(s.fetchAll(), throwsA(isA<ServerException>()));
  });

  test('404 → ServerException', () async {
    final s = serviceWith((req) async => http.Response('{}', 404));
    expect(s.fetchOne(999), throwsA(isA<ServerException>()));
  });

  test('Интернет жоқ → NoInternetException', () async {
    final s = serviceWith((req) async => throw http.ClientException('offline'));
    expect(s.fetchAll(), throwsA(isA<NoInternetException>()));
  });

  test('Timeout → ApiTimeoutException', () async {
    final s = serviceWith(
      (req) => Completer<http.Response>().future, // ешқашан жауап бермейді
      timeout: const Duration(milliseconds: 50),
    );
    expect(s.fetchAll(), throwsA(isA<ApiTimeoutException>()));
  });

  test('Бүлінген JSON → ParseException', () async {
    final s = serviceWith((req) async => http.Response('<html>', 200));
    expect(s.fetchAll(), throwsA(isA<ParseException>()));
  });

  test('Күтілмеген пішін → ParseException', () async {
    final s = serviceWith((req) async => json({'a': 1}));
    expect(s.fetchAll(), throwsA(isA<ParseException>()));
  });
}
