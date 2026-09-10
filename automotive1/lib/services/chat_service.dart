import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';
import 'mechanic_service.dart';

class ChatService {
  ChatService._();

  static final ChatService instance = ChatService._();

  static const List<String> _replies = [
    'Hello! I have received your message. Could you share a little more detail about the problem you are facing?',
    'Thanks for letting me know. I can be with you within about 30 minutes. Please share your exact location.',
    'Understood. I recommend not driving the vehicle further if it is unsafe. Let me send a colleague who is closer to you.',
    'I have the tools and the common part for this kind of issue. Shall I proceed to prepare for the service?',
    'The cost will be fair and we will agree on it before any work begins. You can also check my ratings from other drivers.',
  ];

  static String _threadKey(String email, String mechanicId) =>
      'autoassist_chat_${email.trim().toLowerCase()}_$mechanicId';

  static String _threadsKey(String email) =>
      'autoassist_threads_${email.trim().toLowerCase()}';

  Future<List<String>> getThreadIds(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_threadsKey(email));
    if (raw == null) return <String>[];
    return (jsonDecode(raw) as List<dynamic>).map((e) => e.toString()).toList();
  }

  Future<void> _saveThreadIds(String email, List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_threadsKey(email), jsonEncode(ids));
  }

  Future<void> ensureThread(String email, String mechanicId) async {
    final ids = await getThreadIds(email);
    if (!ids.contains(mechanicId)) {
      ids.insert(0, mechanicId);
      await _saveThreadIds(email, ids);
    }
  }

  Future<List<ChatMessage>> getMessages(String email, String mechanicId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_threadKey(email, mechanicId));
    if (raw == null) return <ChatMessage>[];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessage> sendMessage(
    String email,
    String mechanicId,
    String text,
    bool isUser,
  ) async {
    await ensureThread(email, mechanicId);
    final messages = await getMessages(email, mechanicId);
    final message = ChatMessage(
      id: 'msg-${DateTime.now().microsecondsSinceEpoch}',
      senderName: isUser ? 'You' : _mechanicName(mechanicId),
      isUser: isUser,
      isAI: false,
      text: text,
      time: DateTime.now(),
    );
    messages.add(message);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _threadKey(email, mechanicId),
      jsonEncode(messages.map((m) => m.toJson()).toList()),
    );
    return message;
  }

  Future<ChatMessage> autoReply(String email, String mechanicId, int index) {
    final reply = ChatMessage(
      id: 'msg-${DateTime.now().microsecondsSinceEpoch}',
      senderName: _mechanicName(mechanicId),
      isUser: false,
      isAI: false,
      text: _replies[index % _replies.length],
      time: DateTime.now(),
    );
    return Future.delayed(const Duration(milliseconds: 900), () async {
      final messages = await getMessages(email, mechanicId);
      messages.add(reply);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _threadKey(email, mechanicId),
        jsonEncode(messages.map((m) => m.toJson()).toList()),
      );
      return reply;
    });
  }

  String _mechanicName(String mechanicId) =>
      MechanicService.instance.byId(mechanicId).businessName;
}