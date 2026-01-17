import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String _apiKey = "";
  late GenerativeModel _model;
  late ChatSession _chatSession;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        "You are 'DeepDeen', a wise and humble Islamic AI. built by Ruhan "
        "1. Provide Quranic/Hadith citations (Surah:Ayah). "
        "2. Provide Arabic text followed by English translation. "
        "3. If an image is provided, analyze it for Islamic context (halal labels, script, etc.). "
        "4. Always be respectful and scholarly."
      ),
    );
    _chatSession = _model.startChat();
  }

  Future<String> sendMessage(String prompt, File? attachment) async {
    try {
      if (attachment != null) {
        final bytes = await attachment.readAsBytes();
        final content = [
          Content.multi([
            TextPart(prompt.isEmpty ? "Explain this image." : prompt),
            DataPart('image/jpeg', bytes),
          ])
        ];
        final response = await _model.generateContent(content);
        return response.text ?? "Something went wrong. Please try again.";
      } else {
        final response = await _chatSession.sendMessage(Content.text(prompt));
        return response.text ?? "Something went wrong. Please try again.";
      }
    } on SocketException {
      return "Check internet connection. DeepDeen cannot reach the knowledge base.";
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  void resetChat() {
    _chatSession = _model.startChat();
  }
}