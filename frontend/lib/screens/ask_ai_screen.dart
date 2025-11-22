import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/api_models.dart'; // To access TimelineResponse

class AskAIScreen extends StatefulWidget {
  const AskAIScreen({super.key});

  @override
  State<AskAIScreen> createState() => _AskAIScreenState();
}

// Updated Message Model to include "Sources"
class _ChatMessage {
  final String sender; // 'user' or 'ai'
  final String text;
  final List<TimelineResponse>? sources; // The RAG memories found

  _ChatMessage({required this.sender, required this.text, this.sources});
}

class _AskAIScreenState extends State<AskAIScreen> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage(
        sender: 'ai',
        text:
            "Hello. I am your memory assistant. Ask me anything about your past...",
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _askAI() async {
    // Shortcut: Guard clause for empty text
    if (_queryController.text.trim().isEmpty) return;

    final userText = _queryController.text.trim();

    // 1. Add User Message immediately
    setState(() {
      _messages.add(_ChatMessage(sender: 'user', text: userText));
      _isLoading = true;
      _queryController.clear();
    });
    _scrollToBottom();

    try {
      // 2. Call Real API endpoint (/ask)
      final response = await _apiService.askAI(userText);

      if (!mounted) return;

      // 3. Add AI Response with Sources
      setState(() {
        _messages.add(
          _ChatMessage(
            sender: 'ai',
            text: response.answer,
            sources: response.usedMemories, // Pass the RAG sources
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            sender: 'ai',
            text: "I'm having trouble accessing your memories right now. ($e)",
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background
          Positioned.fill(child: CustomPaint(painter: DiaryPagePainter())),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black54,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Ask Your Memory",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Serif',
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Chat Area
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 10,
                    ),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

                      final msg = _messages[index];
                      return _buildMessageItem(msg);
                    },
                  ),
                ),

                // Input Area
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _queryController,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'e.g., "What did I eat last week?"',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) =>
                              _askAI(), // Allow 'Enter' to submit
                        ),
                      ),
                      const SizedBox(width: 12),
                      FloatingActionButton(
                        onPressed: _isLoading ? null : _askAI,
                        backgroundColor: const Color(0xFF2c5364),
                        mini: true,
                        elevation: 2,
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(_ChatMessage msg) {
    final isUser = msg.sender == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Sender Name
          Text(
            isUser ? "You" : "Memory AI",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isUser ? Colors.blueGrey : Colors.deepPurple,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),

          // Message Bubble
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFFE3F2FD) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(16),
              ),
              boxShadow: [
                if (!isUser)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
              ],
              border: !isUser ? Border.all(color: Colors.grey.shade100) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.text,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),

                // SOURCES SECTION (RAG)
                if (msg.sources != null && msg.sources!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  const Text(
                    "Found in memories:",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Render Sources using list.map shortcut
                  ...msg.sources!.map(
                    (source) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.history,
                            size: 14,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  source.text,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${source.date} • ${source.tone}",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DiaryPagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);

    final linePaint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.05)
      ..strokeWidth = 1.0;
    for (double y = 40; y < size.height; y += 30.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
