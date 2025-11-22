import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/api_service.dart';

class RecordMemoryScreen extends StatefulWidget {
  const RecordMemoryScreen({super.key});

  @override
  State<RecordMemoryScreen> createState() => _RecordMemoryScreenState();
}

class _RecordMemoryScreenState extends State<RecordMemoryScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late stt.SpeechToText _speech;

  // We use a Controller so the user can EDIT the text manually if STT makes a mistake
  final TextEditingController _textController = TextEditingController();

  bool _isListening = false;
  bool _isSaving = false;
  bool _speechAvailable = false;

  // Animation for the pulsing glow
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) => debugPrint('Status: $status'),
        onError: (error) => debugPrint('Error: $error'),
      );
      setState(() {});
    } catch (e) {
      debugPrint("Speech init error: $e");
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _animationController.dispose();
    _textController.dispose(); // Always dispose controllers to free memory
    super.dispose();
  }

  // Toggle Microphone
  Future<void> _toggleRecording() async {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    } else {
      if (!_speechAvailable) {
        await _speech.initialize();
      }
      setState(() => _isListening = true);

      _speech.listen(
        onResult: (val) {
          setState(() {
            // Update the text field in real-time
            _textController.text = val.recognizedWords;
            // Move cursor to the end of text
            _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: _textController.text.length),
            );
          });
        },
      );
    }
  }

  // Manual Save Action
  Future<void> _saveMemory() async {
    if (_textController.text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      // Send the text from the controller (spoken OR typed)
      await _apiService.recordMemory(_textController.text, "spoken");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Memory Saved Successfully!')),
        );
        _textController.clear(); // Clear input after save
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we have content to save
    bool canSave = _textController.text.isNotEmpty && !_isSaving;

    return Scaffold(
      // Prevent keyboard from covering the button
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFFBF5), Color(0xFFFFFFFF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: CustomPaint(painter: FaintLinesPainter()),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Record Memory',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 1. Editable Text Area
                        TextField(
                          controller: _textController,
                          maxLines: null, // Grows with text
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: _isListening
                                ? "Listening..."
                                : "Tap mic to record or type here...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                          ),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // 2. Mic Button
                        GestureDetector(
                          onTap: _toggleRecording,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_isListening)
                                AnimatedBuilder(
                                  animation: _scaleAnimation,
                                  builder: (context, child) => Container(
                                    width: 150 * _scaleAnimation.value,
                                    height: 150 * _scaleAnimation.value,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isListening
                                      ? Colors.redAccent
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isListening ? Icons.stop : Icons.mic,
                                  color: _isListening
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 3. Save Button (Visible only when there is text)
                        AnimatedOpacity(
                          opacity: canSave ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: ElevatedButton.icon(
                            onPressed: canSave ? _saveMemory : null,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_alt),
                            label: Text(
                              _isSaving ? "Saving..." : "Save Memory",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
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

// (Keep your FaintLinesPainter class here)
class FaintLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.05)
      ..strokeWidth = 1.0;
    for (double y = 100; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
