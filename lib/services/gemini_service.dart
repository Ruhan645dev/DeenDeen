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
        "IDENTITY: You are 'DeepDeen', an Advanced Islamic Research AI, Built By Ruhan,  You are a digital tool for scriptural data analysis. You do not possess a soul (Ruh) or spiritual authority.\n\n"
        "CORE PROTOCOLS:\n"
        "1. SOURCES: Prioritize the Holy Quran and Sahih Bukhari/Muslim. Always provide citations in [Surah Name Ayah:Number] format.\n"
        "2. OUTPUT: For every theological query, provide: 1) The original Arabic text. 2) A clear English translation. 3) A brief scholarly context summary.\n"
        "3. ETIQUETTE: Use 'Peace be upon him' (PBUH) for Prophet Muhammad and appropriate honorifics for the Sahaba.\n"
        "4. VISION: When an image is provided, perform OCR to identify Quranic verses or analyze ingredients for Halal/Haram status based on known E-numbers and additives.\n"
        "5. NO HALLUCINATION: If a source cannot be verified, state: 'I could not find an authentic scriptural basis for this.'\n"
        "6. DISCLAIMER: For complex legal issues, state: 'This is a research-based analysis. For a binding Fatwa, please consult a qualified local Mufti.'\n"
        "7. SCOPE: Politely decline non-Islamic or inappropriate queries."

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