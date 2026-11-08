import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/utils/app_logger.dart';

enum RealtimeStatus { connecting, online, offline, error }

class ChatMessage {
  final String id;
  final String text;
  final bool fromMe;
  final DateTime time;

  const ChatMessage({required this.id, required this.text, required this.fromMe, required this.time});

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        text: json['text'] as String,
        fromMe: json['fromMe'] as bool? ?? false,
        time: DateTime.parse(json['time'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'fromMe': fromMe,
        'time': time.toIso8601String(),
      };
}

abstract interface class RealtimeConnection {
  Stream<Object?> get stream;
  void send(String data);
  Future<void> close();
}

typedef RealtimeConnector = Future<RealtimeConnection> Function();

class _WebSocketConnection implements RealtimeConnection {
  _WebSocketConnection(this.channel);
  final WebSocketChannel channel;

  @override
  Stream<Object?> get stream => channel.stream;
  @override
  void send(String data) => channel.sink.add(data);
  @override
  Future<void> close() async => channel.sink.close();
}

Future<RealtimeConnection> _connectToEchoServer() async {
  final channel = WebSocketChannel.connect(
    Uri.parse('wss://ws.postman-echo.com/raw'),
  );
  await channel.ready.timeout(const Duration(seconds: 8));
  return _WebSocketConnection(channel);
}

/// Echo WebSocket чатын басқарады. Қосылым үзілсе, 3 секундтан кейін қайта
/// қосылып, желі жоқ кезде кезекте тұрған хабарларды жібереді.
class RealtimeChatController extends ChangeNotifier {
  RealtimeChatController({RealtimeConnector? connector})
      : _connector = connector ?? _connectToEchoServer;

  final RealtimeConnector _connector;
  final List<ChatMessage> messages = [];
  final List<String> _pending = [];
  RealtimeConnection? _connection;
  StreamSubscription<Object?>? _subscription;
  Timer? _retryTimer;
  RealtimeStatus status = RealtimeStatus.offline;
  String? errorMessage;
  bool _disposed = false;
  bool _connecting = false;

  Future<void> connect() async {
    if (_disposed || _connecting || status == RealtimeStatus.online) return;
    _connecting = true;
    _retryTimer?.cancel();
    status = RealtimeStatus.connecting;
    errorMessage = null;
    notifyListeners();
    try {
      final connection = await _connector();
      if (_disposed) {
        await connection.close();
        return;
      }
      _connection = connection;
      status = RealtimeStatus.online;
      AppLogger.info('WebSocket қосылды', name: 'RealtimeChat');
      _subscription = connection.stream.listen(
        _receive,
        onError: (Object error, StackTrace stack) => _disconnect(error, stack),
        onDone: () => _disconnect(StateError('Қосылым жабылды'), StackTrace.current),
      );
      for (final payload in List<String>.from(_pending)) {
        connection.send(payload);
        _pending.remove(payload);
      }
    } catch (error, stack) {
      _disconnect(error, stack);
    } finally {
      _connecting = false;
      if (!_disposed) notifyListeners();
    }
  }

  void send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _disposed) return;
    final message = ChatMessage(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      text: trimmed,
      fromMe: true,
      time: DateTime.now(),
    );
    messages.add(message);
    final payload = jsonEncode(message.toJson());
    if (status == RealtimeStatus.online && _connection != null) {
      try {
        _connection!.send(payload);
      } catch (error, stack) {
        _pending.add(payload);
        _disconnect(error, stack);
      }
    } else {
      _pending.add(payload);
      if (status == RealtimeStatus.offline || status == RealtimeStatus.error) {
        unawaited(connect());
      }
    }
    AppLogger.info('Хабарлама жіберуге кезекке қойылды', name: 'RealtimeChat');
    notifyListeners();
  }

  void _receive(Object? data) {
    try {
      if (data is! String) throw const FormatException('Мәтіндік JSON күтілді');
      final decoded = jsonDecode(data);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('JSON объект болуы керек');
      }
      final echo = ChatMessage.fromJson(decoded);
      final index = messages.indexWhere((message) => message.id == echo.id);
      if (index >= 0) {
        messages[index] = ChatMessage(
          id: echo.id,
          text: echo.text,
          fromMe: true,
          time: echo.time,
        );
      } else {
        messages.add(echo);
      }
      notifyListeners();
    } catch (error, stack) {
      AppLogger.error('WebSocket хабарламасын өңдеу қатесі', error, stack,
          name: 'RealtimeChat');
      errorMessage = 'Сервер хабарламасын оқу мүмкін болмады.';
      notifyListeners();
    }
  }

  void _disconnect(Object error, StackTrace stack) {
    if (_disposed) return;
    AppLogger.error('WebSocket байланысы үзілді', error, stack,
        name: 'RealtimeChat');
    status = RealtimeStatus.error;
    errorMessage = 'Байланыс үзілді. Қайта қосылып жатыр…';
    _connection = null;
    unawaited(_subscription?.cancel());
    _subscription = null;
    notifyListeners();
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 3), () {
      if (!_disposed) unawaited(connect());
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _retryTimer?.cancel();
    unawaited(_subscription?.cancel());
    unawaited(_connection?.close());
    super.dispose();
  }
}
