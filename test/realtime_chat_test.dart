import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:studyplan/features/realtime/data/realtime_chat.dart';

class _FakeConnection implements RealtimeConnection {
  final incoming = StreamController<Object?>.broadcast();
  final sent = <String>[];

  @override
  Stream<Object?> get stream => incoming.stream;

  @override
  void send(String data) => sent.add(data);

  @override
  Future<void> close() => incoming.close();
}

Future<void> flushEvents() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  test('бастапқы күй офлайн', () {
    final chat = RealtimeChatController(connector: () async => _FakeConnection());
    expect(chat.status, RealtimeStatus.offline);
    chat.dispose();
  });

  test('байланыс орнағанда онлайн күйге өтеді', () async {
    final socket = _FakeConnection();
    final chat = RealtimeChatController(connector: () async => socket);
    await chat.connect();
    expect(chat.status, RealtimeStatus.online);
    await socket.close();
    chat.dispose();
  });

  test('жіберілген хабар сервер эхосы келгенде бір жазба болып қалады', () async {
    final socket = _FakeConnection();
    final chat = RealtimeChatController(connector: () async => socket);
    await chat.connect();
    chat.send('Flutter тапсырмасы');
    expect(socket.sent, hasLength(1));
    final echo = jsonDecode(socket.sent.single) as Map<String, dynamic>;
    socket.incoming.add(jsonEncode(echo));
    await flushEvents();
    expect(chat.messages, hasLength(1));
    expect(chat.messages.single.text, 'Flutter тапсырмасы');
    await socket.close();
    chat.dispose();
  });

  test('оффлайн кезінде жіберілген хабар қосылған соң кезектен жіберіледі', () async {
    final socket = _FakeConnection();
    final ready = Completer<RealtimeConnection>();
    final chat = RealtimeChatController(connector: () => ready.future);
    chat.send('Желіге қайта қосылғанда жібер');
    expect(chat.messages, hasLength(1));
    ready.complete(socket);
    await flushEvents();
    expect(chat.status, RealtimeStatus.online);
    expect(socket.sent, hasLength(1));
    expect((jsonDecode(socket.sent.single) as Map)['text'],
        'Желіге қайта қосылғанда жібер');
    await socket.close();
    chat.dispose();
  });

  test('қате JSON пайдаланушыға түсінікті error күйін береді', () async {
    final socket = _FakeConnection();
    final chat = RealtimeChatController(connector: () async => socket);
    await chat.connect();
    socket.incoming.add('{broken');
    await flushEvents();
    expect(chat.errorMessage, 'Сервер хабарламасын оқу мүмкін болмады.');
    expect(chat.status, RealtimeStatus.online);
    await socket.close();
    chat.dispose();
  });

  test('қосылым қатесі error төлөв харуулна', () async {
    final chat = RealtimeChatController(
      connector: () => Future<RealtimeConnection>.error(StateError('offline')),
    );
    await chat.connect();
    expect(chat.status, RealtimeStatus.error);
    expect(chat.errorMessage, contains('Қайта қосылып жатыр'));
    chat.dispose();
  });
}
