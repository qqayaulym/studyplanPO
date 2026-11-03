import '../constants/app_strings.dart';

/// Желілік сұраулар кезіндегі қателердің барлығы осы класстан тарайды.
/// UI тек [message] мәтінін көрсетеді.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Интернет жоқ / серверге қосылу мүмкін емес.
class NoInternetException extends ApiException {
  const NoInternetException() : super(AppStrings.noInternet);
}

/// Сервер уақытында жауап бермеді.
class ApiTimeoutException extends ApiException {
  const ApiTimeoutException() : super(AppStrings.timeoutError);
}

/// Сервер 4xx / 5xx статус қайтарды.
class ServerException extends ApiException {
  final int statusCode;
  const ServerException(this.statusCode, String message) : super(message);
}

/// JSON дұрыс емес не күтілген пішінде емес.
class ParseException extends ApiException {
  const ParseException() : super(AppStrings.badResponse);
}
