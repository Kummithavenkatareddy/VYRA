import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TextMemoryScreen extends StatefulWidget {
  const TextMemoryScreen({super.key});

  @override
  State<TextMemoryScreen> createState() => _TextMemoryScreenState();
}

class _TextMemoryScreenState extends State<TextMemoryScreen> {
  final _textController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isSaving = false;

  Future<void> _saveMemory() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    // Call API
    await _apiService.createTextMemory(_textController.text);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memory Saved!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF5F7FA), // Light blue-grey top
                    Color(0xFFE4E8F0), // Slightly darker bottom
                  ],
                ),
              ),
            ),
          ),

          // 2. Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black54, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Text Memory Entry',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance back button
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Main Card with Input
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        Container(
                          height: 300, // Fixed height for the card look
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CustomPaint(
                              foregroundPainter: LinedPaperPainter(),
                              child: TextField(
                                controller: _textController,
                                maxLines: null, // Allow unlimited lines
                                // expand: true, // Fill the container
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.55, // Match line height of painter
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Start typing your memory here...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 18,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(24),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveMemory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF89C4F4), // Soft Blue
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: const Color(0xFF89C4F4).withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
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

class LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;

    // Match the TextField height and padding
    double lineHeight = 28.0; // Approx 18 * 1.55
    double paddingTop = 24.0;
    
    // Draw lines starting from where text begins
    for (double y = paddingTop + lineHeight; y < size.height - paddingTop; y += lineHeight) {
      canvas.drawLine(Offset(24, y), Offset(size.width - 24, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
