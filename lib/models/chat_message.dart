import 'dart:io';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final File? attachment;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.attachment,
  });
}