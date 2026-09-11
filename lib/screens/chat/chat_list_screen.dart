import 'package:flutter/material.dart';

import '../../data/app_images.dart';
import '../../models/mechanic.dart';
import '../../services/app_events.dart';
import '../../services/chat_service.dart';
import '../../services/mechanic_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/animated_entry.dart';
import '../../widgets/app_image.dart';
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
      final messages =
          await ChatService.instance.getMessages(widget.ownerEmail, id);
      final mechanic = MechanicService.instance.byId(id);
      entries.add(_ThreadEntry(
        mechanic: mechanic,
        lastMessage:
            messages.isEmpty ? 'Say hello to get started' : messages.last.text,
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Text(
                'Messages (${_threads.length})',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _threads.isEmpty
                      ? const _EmptyChats()
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: _threads.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final t = _threads[index];
                              return AnimatedEntry(
                                index: index,
                                child: _ThreadCard(
                                  thread: t,
                                  ownerEmail: widget.ownerEmail,
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  final _ThreadEntry thread;
  final String ownerEmail;

  const _ThreadCard({required this.thread, required this.ownerEmail});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            mechanicId: thread.mechanic.id,
            ownerEmail: ownerEmail,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppTheme.brandGradient),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.car_repair, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.mechanic.businessName,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    thread.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (thread.lastTime != null)
                  Text(
                    formatTime(thread.lastTime!),
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                const SizedBox(height: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: thread.mechanic.available
                        ? AppTheme.success
                        : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
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
            Container(
              width: 100,
              height: 100,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: AppImage(
                AppImages.emptyChats,
                width: 100,
                height: 100,
                radius: BorderRadius.circular(50),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No conversations yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse nearby mechanics and start a chat, or open a conversation from an assistance request.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}