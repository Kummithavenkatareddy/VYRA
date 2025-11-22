import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TextMemoryScreen extends StatefulWidget {
  const TextMemoryScreen({super.key});

  @override
  State<TextMemoryScreen> createState() => _TextMemoryScreenState();
}

class _TextMemoryScreenState extends State<TextMemoryScreen> {
  // 1. Controller handles the text input
  final TextEditingController _textController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isSaving = false;

  // 2. Tone Selection State
  String _selectedTone = "neutral";
  final List<String> _tones = [
    "neutral",
    "happy",
    "sad",
    "excited",
    "anxious",
    "confident",
  ];

  @override
  void dispose() {
    _textController.dispose(); // Always clean up controllers
    super.dispose();
  }

  Future<void> _saveMemory() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first!')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 3. Call the API with Text AND Tone
      // Endpoint: /memory/text
      await _apiService.addTextMemory(_textController.text, _selectedTone);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Memory Saved Successfully!')),
        );
        Navigator.pop(context, true); // Return "true" to refresh the timeline
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
    return Scaffold(
      resizeToAvoidBottomInset: true, // Key for text fields
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF5F7FA), Color(0xFFE4E8F0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
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
                            'New Text Memory',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Input Card
                        Container(
                          constraints: const BoxConstraints(minHeight: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CustomPaint(
                              foregroundPainter: LinedPaperPainter(),
                              child: TextField(
                                controller: _textController,
                                maxLines: null,
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.55,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Write your memory here...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(24),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Tone Selector (Horizontal Scroll)
                        SizedBox(
                          height: 50,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: _tones.map((tone) {
                              final isSelected = _selectedTone == tone;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(tone.toUpperCase()),
                                  selected: isSelected,
                                  onSelected: (selected) =>
                                      setState(() => _selectedTone = tone),
                                  selectedColor: const Color(0xFF89C4F4),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black54,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveMemory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF89C4F4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: _isSaving
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Save Memory',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
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

// Your custom painter logic
class LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;
    double lineHeight = 28.0; // matches TextField height approx
    double paddingTop = 24.0;
    for (
      double y = paddingTop + lineHeight;
      y < size.height - paddingTop;
      y += lineHeight
    ) {
      canvas.drawLine(Offset(24, y), Offset(size.width - 24, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
