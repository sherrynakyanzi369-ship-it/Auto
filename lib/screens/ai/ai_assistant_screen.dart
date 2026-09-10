import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/chat_message.dart';
import '../../services/ai_assistant_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final name = (AuthService.instance.currentUser?.name ?? 'Driver').split(' ').first;
      _addBot(AiAssistantService.instance.greet(name));
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _addBot(String text) {
    final msg = ChatMessage(
      id: 'ai-${DateTime.now().microsecondsSinceEpoch}',
      senderName: 'AutoAssist AI',
      isUser: false,
      isAI: true,
      text: text,
      time: DateTime.now(),
    );
    setState(() => _messages.add(msg));
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
    final userMsg = ChatMessage(
      id: 'u-${DateTime.now().microsecondsSinceEpoch}',
      senderName: 'You',
      isUser: true,
      isAI: false,
      text: text,
      time: DateTime.now(),
    );
    setState(() {
      _messages.add(userMsg);
      _typing = true;
    });
    _scrollToBottom();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final name = (AuthService.instance.currentUser?.name ?? 'Driver').split(' ').first;
    final reply = AiAssistantService.instance.respond(text, name);
    if (!mounted) return;
    setState(() => _typing = false);
    _addBot(reply);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Vehicle Assistant', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text(
              'Preliminary guidance · not a diagnosis',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              reverse: true,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: _messages.length + (_typing ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _messages.length) return const _TypingBubble();
                final msg = _messages[_messages.length - 1 - index];
                return _AiBubble(message: msg);
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: AppTheme.accent.withValues(alpha: 0.12),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.brown),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AiAssistantService.disclaimer,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          _InputBar(controller: _input, onSend: _send),
        ],
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  final ChatMessage message;

  const _AiBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : const Color(0xFFEDE7F6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: const Color(0xFFD1C4E9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const Row(
                children: [
                  Icon(Icons.smart_toy_outlined, size: 14, color: AppTheme.primary),
                  SizedBox(width: 4),
                  Text(
                    'AutoAssist AI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF1F2937),
                fontSize: 14,
                height: 1.45,
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
          color: const Color(0xFFEDE7F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD1C4E9)),
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
      decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
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
                  hintText: 'Describe your vehicle problem...',
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