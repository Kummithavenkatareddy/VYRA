import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/snackbar_utils.dart';

class EnterMemoryScreen extends StatefulWidget {
  const EnterMemoryScreen({super.key});

  @override
  State<EnterMemoryScreen> createState() => _EnterMemoryScreenState();
}

class _EnterMemoryScreenState extends State<EnterMemoryScreen> {
  final TextEditingController _textController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isSaving = false;
  bool _isRecording = false;

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    // TODO: Implement actual recording logic using whisper_ggml or record package
    if (_isRecording) {
      SnackbarUtils.showSuccess(context, 'Recording started (Placeholder)');
    } else {
      SnackbarUtils.showSuccess(context, 'Recording stopped (Placeholder)');
    }
  }

  Future<void> _saveMemory() async {
    if (_textController.text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      await _apiService.addTextMemory(
        _textController.text,
        "neutral",
      ); // Default to neutral
      if (mounted) {
        SnackbarUtils.showSuccess(context, 'Memory Saved Successfully!');
        _textController.clear();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background (Notebook Lines)
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: CustomPaint(painter: NotebookLinesPainter()),
            ),
          ),

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
                            'Capture Your Moment',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),

                // Main Content Area (Scrollable text display if needed, or just empty space)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Focus text field when tapping background?
                      // Or maybe just let it be.
                    },
                    child: Container(
                      color: Colors.transparent,
                      // We could show the conversation history here if it was a chat,
                      // but for "Enter Memory", it's just a single entry.
                      // Maybe we show what's being typed in a larger view?
                      // The user said "text field in that only at right end we'll have voice button like chatgpt".
                      // This implies the text field is at the bottom.
                    ),
                  ),
                ),

                // Bottom Input Area
                Container(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    top: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  minLines: 1,
                                  maxLines: 5,
                                  decoration: const InputDecoration(
                                    hintText: 'Message',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              // Voice Button inside the text field container at the right end
                              GestureDetector(
                                onTap: _toggleRecording,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _isRecording
                                          ? Colors.red
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isRecording ? Icons.stop : Icons.mic,
                                      color: _isRecording
                                          ? Colors.white
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Send/Save Button
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.arrow_upward,
                                  color: Colors.white,
                                ),
                          onPressed: _isSaving ? null : _saveMemory,
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
}

// Duplicated from timeline_screen.dart to avoid import issues or refactoring
class NotebookLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.5;

    for (double y = 60; y < size.height; y += 32.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
