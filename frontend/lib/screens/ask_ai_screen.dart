import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AskAIScreen extends StatefulWidget {
  const AskAIScreen({super.key});

  @override
  State<AskAIScreen> createState() => _AskAIScreenState();
}

class _ChatMessage {
  final String sender; // 'user' or 'ai'
  final String text;

  _ChatMessage({required this.sender, required this.text});
}

class _AskAIScreenState extends State<AskAIScreen> {
  final _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add an initial greeting from the AI
    _messages.add(_ChatMessage(
      sender: 'ai',
      text: "Hello. I am your memory assistant. Ask me anything about your past days...",
    ));
  }

  void _askAI() async {
    if (_queryController.text.trim().isEmpty) return;

    final userText = _queryController.text.trim();
    setState(() {
      _messages.add(_ChatMessage(sender: 'user', text: userText));
      _isLoading = true;
      _queryController.clear();
    });
    _scrollToBottom();

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _messages.add(_ChatMessage(
        sender: 'ai',
        text: "Based on your memories, it seems you were quite happy about that event. You mentioned feeling proud and excited.",
      ));
    });
    _scrollToBottom();
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
      // Resize to avoid bottom inset when keyboard opens
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Background with diary lines
          Positioned.fill(
            child: CustomPaint(
              painter: DiaryPagePainter(),
            ),
          ),
          
          // 2. Content
          SafeArea(
            child: Column(
              children: [
                // Header: Back Button & Date
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black54),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        DateFormat('MMMM d, yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontFamily: 'Serif',
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // Chat List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        // Loading indicator
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            children: const [
                              Text(
                                "AI is writing...",
                                style: TextStyle(
                                  fontFamily: 'Serif',
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final msg = _messages[index];
                      final isUser = msg.sender == 'user';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUser ? "You:" : "AI:",
                              style: TextStyle(
                                fontFamily: 'Serif',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isUser ? Colors.blueGrey.shade700 : Colors.deepPurple.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg.text,
                              style: TextStyle(
                                fontFamily: 'Serif',
                                fontSize: 18,
                                height: 1.5, // Matches line height roughly
                                color: isUser ? Colors.black87 : const Color(0xFF424242),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Input Area
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _queryController,
                          style: const TextStyle(fontFamily: 'Serif', fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Write your question here...',
                            hintStyle: TextStyle(
                              fontFamily: 'Serif',
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade400,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          minLines: 1,
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _askAI,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2c5364), // Dark blue from home screen
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: const Text('Ask'),
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
}

class DiaryPagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 1. White Background
    canvas.drawRect(Offset.zero & size, paint);

    // 2. Soft Vertical Gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white,
        Colors.grey.shade50,
        Colors.grey.shade100,
      ],
    );
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
    paint.shader = null;

    // 3. Horizontal Lines
    final linePaint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.1)
      ..strokeWidth = 1.0;

    double lineHeight = 30.0;
    // Start drawing lines from a bit lower to account for header, but cover entire scrollable area
    for (double y = 60; y < size.height; y += lineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // 4. Vertical Margin Line
    final marginPaint = Paint()
      ..color = Colors.redAccent.withOpacity(0.15)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(40, 0), Offset(40, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
