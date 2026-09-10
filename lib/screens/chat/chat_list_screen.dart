import 'package:flutter/material.dart';

import '../../models/mechanic.dart';
import '../../services/app_events.dart';
import '../../services/chat_service.dart';
import '../../services/mechanic_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String ownerEmail;

  const ChatListScreen({super.key, required this.ownerEmail});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ThreadEntry {
  final Mechanic mechanic;
  final String lastMessage;
  final DateTime? lastTime;

  _ThreadEntry({
    required this.mechanic,
    required this.lastMessage,
    this.lastTime,
  });
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<_ThreadEntry> _threads = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    AppEvents.chatTick.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    AppEvents.chatTick.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final ids = await ChatService.instance.getThreadIds(widget.ownerEmail);
    final entries = <_ThreadEntry>[];
    for (final id in ids) {
      final messages = await ChatService.instance.getMessages(widget.ownerEmail, id);
      final mechanic = MechanicService.instance.byId(id);
      entries.add(_ThreadEntry(
        mechanic: mechanic,
        lastMessage: messages.isEmpty ? 'Say hello to get started' : messages.last.text,
        lastTime: messages.isEmpty ? null : messages.last.time,
      ));
    }
    if (!mounted) return;
    setState(() {
      _threads = entries;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages (${_threads.length})'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _threads.isEmpty
              ? const _EmptyChats()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _threads.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final t = _threads[index];
                      return Card(
                        child: ListTile(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                mechanicId: t.mechanic.id,
                                ownerEmail: widget.ownerEmail,
                              ),
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                            child: const Icon(Icons.car_repair, color: AppTheme.primary),
                          ),
                          title: Text(
                            t.mechanic.businessName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            t.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          isThreeLine: false,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (t.lastTime != null)
                                Text(
                                  formatTime(t.lastTime!),
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                ),
                              const SizedBox(height: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: t.mechanic.available ? AppTheme.success : Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No conversations yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Browse nearby mechanics and start a chat, or open a conversation from an assistance request.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}