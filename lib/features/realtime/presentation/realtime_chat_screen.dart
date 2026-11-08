import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/realtime_chat.dart';

class RealtimeChatScreen extends StatelessWidget {
  const RealtimeChatScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => RealtimeChatController()..connect(),
        child: const _ChatView(),
      );
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(RealtimeChatController chat) {
    chat.send(_input.text);
    _input.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<RealtimeChatController>();
    final colors = Theme.of(context).colorScheme;
    final (statusText, statusColor, statusIcon) = switch (chat.status) {
      RealtimeStatus.connecting => ('Қосылып жатыр…', colors.tertiary, Icons.sync),
      RealtimeStatus.online => ('Онлайн · серверге қосылған', Colors.green, Icons.wifi),
      RealtimeStatus.offline => ('Офлайн', colors.error, Icons.wifi_off),
      RealtimeStatus.error => ('Қайта қосылуда…', colors.error, Icons.cloud_off),
    };
    return Scaffold(
      appBar: AppBar(
        title: const Text('Нақты уақыттағы чат'),
        actions: [
          IconButton(
            tooltip: 'Қайта қосылу',
            onPressed: chat.status == RealtimeStatus.connecting ? null : chat.connect,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: statusColor.withAlpha(22),
              child: Row(children: [
                Icon(statusIcon, size: 18, color: statusColor),
                const SizedBox(width: 8),
                Expanded(child: Text(statusText, style: TextStyle(color: statusColor))),
                if (chat.status == RealtimeStatus.connecting)
                  const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
              ]),
            ),
            if (chat.errorMessage != null)
              MaterialBanner(
                content: Text(chat.errorMessage!),
                leading: Icon(Icons.info_outline, color: colors.error),
                actions: [
                  TextButton(onPressed: chat.connect, child: const Text('Қайталау')),
                ],
              ),
            Expanded(
              child: chat.messages.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(28),
                        child: Text(
                          'Оқу тапсырмалары туралы хабарлама жіберіңіз. Сервер жауабы келгенде чат автоматты жаңарады.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(16),
                      itemCount: chat.messages.length,
                      itemBuilder: (context, index) {
                        final message = chat.messages[index];
                        return Align(
                          alignment: message.fromMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 300),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: message.fromMe
                                  ? colors.primaryContainer
                                  : colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(message.text),
                                const SizedBox(height: 4),
                                Text(
                                  '${message.fromMe ? 'Сіз' : 'Сервер'} · ${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(chat),
                      decoration: const InputDecoration(
                        hintText: 'Хабарлама жазыңыз…',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Жіберу',
                    onPressed: _input.text.trim().isEmpty
                        ? null
                        : () => _send(chat),
                    icon: const Icon(Icons.send),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
