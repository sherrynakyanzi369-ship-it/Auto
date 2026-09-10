import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/chat_message.dart';
import '../../services/app_events.dart';
import '../../services/chat_service.dart';
import '../../services/mechanic_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

class ChatScreen extends StatefulWidget {
  final String mechanicId;
  final String ownerEmail;

  const ChatScreen({super.key, required this.mechanicId, required this.ownerEmail});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _typing = false;
  int _replyIndex = 0;

  @override
  void initState() {
    super.initState();
    ChatService.instance.ensureThread(widget.ownerEmail, widget.mechanicId);
    _load();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final messages =
        await ChatService.instance.getMessages(widget.ownerEmail, widget.mechanicId);
    if (!mounted) return;
    setState(() {
      _messages = messages;
      _loading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    final message =
        await ChatService.instance.sendMessage(widget.ownerEmail, widget.mechanicId, text, true);
    if (!mounted) return;
    setState(() => _messages.add(message));
    AppEvents.bumpChat();
    _scrollToBottom();
    unawaited(_autoReply());
  }

  Future<void> _autoReply() async {
    setState(() => _typing = true);
    _scrollToBottom();
    final reply = await ChatService.instance.autoReply(
      widget.ownerEmail,
      widget.mechanicId,
      _replyIndex++,
    );
    if (!mounted) return;
    setState(() {
      _typing = false;
      _messages.add(reply);
    });
    AppEvents.bumpChat();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final mechanic = MechanicService.instance.byId(widget.mechanicId);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mechanic.businessName,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text(
              mechanic.available ? 'Available now' : 'Currently busy',
              style: TextStyle(
                fontSize: 12,
                color: mechanic.available ? AppTheme.success : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scroll,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: _messages.length + (_typing ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _messages.length) {
                        return const _TypingBubble();
                      }
                      final msg = _messages[_messages.length - 1 - index];
                      return _MessageBubble(message: msg);
                    },
                  ),
          ),
          if (_typing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${mechanic.businessName} is typing...',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          _InputBar(controller: _input, onSend: _send),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF1F2937),
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatTime(message.time),
              style: TextStyle(
                color: isUser ? Colors.white70 : Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(),
            const SizedBox(width: 4),
            _dot(),
            const SizedBox(width: 4),
            _dot(),
          ],
        ),
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: onSend,
              icon: const Icon(Icons.send),
              tooltip: 'Send',
            ),
          ],
        ),
      ),
    );
  }
}