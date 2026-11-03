import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/app_strings.dart';
import 'api_exceptions.dart';

/// Төмен деңгейлі HTTP клиент: барлық сұрау осы жерден өтеді.
///  - timeout (әдепкі 10 с);
///  - қателерді ApiException түріне түрлендіру (интернет жоқ, timeout, сервер қатесі, JSON қатесі);
///  - JSON кодтау/декодтау.
/// Тест үшін [http.Client] сырттан беріледі (MockClient).
class ApiClient {
  final String baseUrl;
  final http.Client _client;
  final Duration timeout;

  ApiClient({
    this.baseUrl = 'https://jsonplaceholder.typicode.com',
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  static final ApiClient instance = ApiClient();

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send(() => _client.get(_uri(path, query), headers: _headers));

  Future<dynamic> post(String path, Map<String, dynamic> body) => _send(
      () => _client.post(_uri(path), headers: _headers, body: jsonEncode(body)));

  Future<dynamic> put(String path, Map<String, dynamic> body) => _send(
      () => _client.put(_uri(path), headers: _headers, body: jsonEncode(body)));

  Future<dynamic> patch(String path, Map<String, dynamic> body) => _send(() =>
      _client.patch(_uri(path), headers: _headers, body: jsonEncode(body)));

  Future<dynamic> delete(String path) =>
      _send(() => _client.delete(_uri(path), headers: _headers));

  /// Сұрауды орындап, жауапты тексереді және барлық қатені ApiException-ға айналдырады.
  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(timeout);
      return _handle(response);
    } on TimeoutException {
      throw const ApiTimeoutException();
    } on http.ClientException catch (e) {
      // SocketException (интернет жоқ) және веб-тегі желі қателері осында келеді
      debugPrint('Network error: $e');
      throw const NoInternetException();
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw const ApiException(AppStrings.unknownError);
    }
  }

  dynamic _handle(http.Response r) {
    final code = r.statusCode;
    if (code >= 200 && code < 300) {
      if (r.body.trim().isEmpty) return null;
      try {
        return jsonDecode(utf8.decode(r.bodyBytes));
      } on FormatException {
        throw const ParseException();
      }
    }
    if (code == 404) {
      throw ServerException(code, AppStrings.notFoundError);
    }
    if (code >= 500) {
      throw ServerException(code, '${AppStrings.serverError} ($code)');
    }
    throw ServerException(code, '${AppStrings.unknownError} ($code)');
  }

  void close() => _client.close();
}
