import 'dart:convert'; // <--- FIXED: Added this missing import
import 'package:flutter/material.dart';
import '../../Data/Repository/repo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _ingredientsController = TextEditingController();
  final HomePageRepo _repository = HomePageRepo();
  final ScrollController _scrollController = ScrollController();

  // Store chat history here
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final ingredients = _ingredientsController.text.trim();
    if (ingredients.isEmpty) return;

    // 1. Add User Message & Clear Input
    setState(() {
      _messages.add(ChatMessage(text: ingredients, isUser: true));
      _isLoading = true;
    });
    _ingredientsController.clear();
    _scrollToBottom();

    // 2. Unfocus keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      // 3. Get AI Response
      final result = await _repository.askAI(ingredients);

      // FIXED: Check if the widget is still on screen before updating UI
      if (!mounted) return;

      // 4. Add AI Message
      setState(() {
        _messages.add(ChatMessage(text: result, isUser: false));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(text: "Error: $e", isUser: false));
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // Modern Gradient AppBar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFE8C00), Color(0xFFF83600)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "AI CheF",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Chat List
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                            ),
                          ),
                        );
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.soup_kitchen,
            size: 80,
            color: Colors.orange.withOpacity(0.3),
          ),
          const SizedBox(height: 10),
          Text(
            "What's in your kitchen? Aj Kia Bnany Ka Mood Ha",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Type ingredients to start cooking!",
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.orange.shade600 : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: message.isUser
                ? const Radius.circular(20)
                : Radius.zero,
            bottomRight: message.isUser
                ? Radius.zero
                : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: message.isUser
            ? Text(
                message.text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
            : _buildFormattedRecipe(message.text), // Custom Formatter
      ),
    );
  }

  // Parses raw text into a beautiful UI
  Widget _buildFormattedRecipe(String text) {
    List<Widget> content = [];
    LineSplitter ls = const LineSplitter();
    List<String> lines = ls.convert(text);

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('#')) {
        // Headers (Title, Ingredients, Instructions)
        content.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              line.replaceAll('#', '').trim(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
          ),
        );
      } else if (line.startsWith('*') || line.startsWith('-')) {
        // Bullet Points
        content.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "• ",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    line
                        .replaceAll(RegExp(r'^[\*\-]\s*'), '')
                        .replaceAll('**', ''), // Remove bold markers
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Normal Body Text
        content.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              line.replaceAll('**', ''), // Remove markdown bolding marks
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content,
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  hintText: "Enter ingredients...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor: Colors.orange,
            elevation: 2,
            mini: true,
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

// Simple Model for Chat Messages
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}
