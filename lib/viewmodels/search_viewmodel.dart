import 'dart:io';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';

class SearchViewModel extends ChangeNotifier {
  final GeminiService _service = GeminiService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendChat(String text, File? attachment) async {
    if (text.trim().isEmpty && attachment == null) return;

    // Add User Message
    _messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      attachment: attachment,
    ));
    
    _isLoading = true;
    notifyListeners();

    // Get AI Response
    final response = await _service.sendMessage(text, attachment);

    // Add AI Response
    _messages.add(ChatMessage(
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    ));

    _isLoading = false;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _service.resetChat();
    notifyListeners();
  }
}