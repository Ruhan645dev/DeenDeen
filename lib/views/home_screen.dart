import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../viewmodels/search_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  
  late stt.SpeechToText _speech;
  bool _isListening = false;
  File? _tempImage;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }


  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Status: $status');
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (errorNotification) {
          debugPrint('Error: $errorNotification');
          setState(() => _isListening = false);
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
              if (result.finalResult) {
                _isListening = false;
              }
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _tempImage = File(pickedFile.path));
    }
  }

  void _handleSend(SearchViewModel viewModel) {
    if (_controller.text.isNotEmpty || _tempImage != null) {
      viewModel.sendChat(_controller.text, _tempImage);
      _controller.clear();
      setState(() {
        _tempImage = null;
        _isListening = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SearchViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text("DEEPDEEN", 
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: viewModel.clearChat, icon: const Icon(Icons.refresh, color: Colors.grey))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: viewModel.messages.isEmpty ? _buildWelcome() : _buildChatList(viewModel),
          ),
          if (viewModel.isLoading) 
            const LinearProgressIndicator(color: Color(0xFFD4AF37), backgroundColor: Colors.transparent),
          _buildInputArea(viewModel),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 80, color: Color(0xFF064E3B)),
          const SizedBox(height: 20),
          const Text("DEEPDEEN", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 5)),
          const Text("Advanced Deen Intelligence", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChatList(SearchViewModel viewModel) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(15),
      itemCount: viewModel.messages.length,
      itemBuilder: (context, index) {
        final msg = viewModel.messages[index];
        bool isUser = msg.isUser;
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF064E3B) : Colors.white,
              borderRadius: BorderRadius.circular(15).copyWith(
                bottomRight: isUser ? Radius.zero : const Radius.circular(15),
                bottomLeft: isUser ? const Radius.circular(15) : Radius.zero,
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg.attachment != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(msg.attachment!, height: 200, width: double.infinity, fit: BoxFit.cover),
                    ),
                  ),
                MarkdownBody(
                  data: msg.text,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: msg.isUser 
                          ? Colors.white 
                          : (msg.text.contains("wrong") || msg.text.contains("internet") 
                              ? Colors.red[700] 
                              : Colors.black87), 
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea(SearchViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200))
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (_tempImage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_tempImage!, height: 60, fit: BoxFit.cover),
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image_outlined, color: Color(0xFF064E3B)), 
                  onPressed: _pickImage
                ),
                
                
                GestureDetector(
                  onTap: _listen,
                  child: CircleAvatar(
                    backgroundColor: _isListening ? Colors.red.withOpacity(0.1) : Colors.transparent,
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none, 
                      color: _isListening ? Colors.red : const Color(0xFF064E3B)
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25)
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "Ask DeepDeen...", 
                        border: InputBorder.none
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _handleSend(viewModel),
                  child: const CircleAvatar(
                    backgroundColor: Color(0xFF064E3B),
                    child: Icon(Icons.arrow_upward, color: Colors.white, size: 20),
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