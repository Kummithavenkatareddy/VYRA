import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart'; // Assuming this exists from previous steps

class RecordMemoryScreen extends StatefulWidget {
  const RecordMemoryScreen({super.key});

  @override
  State<RecordMemoryScreen> createState() => _RecordMemoryScreenState();
}

class _RecordMemoryScreenState extends State<RecordMemoryScreen> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  String _statusText = "Tap to Record";
  final ApiService _apiService = ApiService();
  
  // Animation for the pulsing glow
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    setState(() {
      _isRecording = !_isRecording;
      _statusText = _isRecording ? "Listening..." : "Tap to Record";
    });

    if (!_isRecording) {
      // Stopped recording, simulate upload
      setState(() {
        _statusText = "Transcribing...";
      });
      
      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Here you would call _apiService.uploadAudioMemory(path)
      
      if (mounted) {
        setState(() {
          _statusText = "Saved!";
        });
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            _statusText = "Tap to Record";
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient & Lines
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFBF5), // Warm white top
                    Color(0xFFFFFFFF), // White bottom
                  ],
                ),
              ),
              child: CustomPaint(
                painter: FaintLinesPainter(),
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
                        icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Record Memory',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Mic Button Stack
                      GestureDetector(
                        onTap: _toggleRecording,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Glow Ring (Animated when recording, static subtle when not)
                            AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(_isRecording ? 0.3 : 0.1),
                                      width: 2,
                                    ),
                                    color: Colors.blue.withOpacity(_isRecording ? 0.05 : 0.0),
                                    boxShadow: _isRecording ? [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.2),
                                        blurRadius: 20 * _scaleAnimation.value,
                                        spreadRadius: 5,
                                      )
                                    ] : [],
                                  ),
                                );
                              },
                            ),
                            
                            // Inner White Circle
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.mic,
                                  size: 48,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Status Text
                      Text(
                        _statusText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Placeholder for waveform/transient status
                      SizedBox(
                        height: 40,
                        child: _isRecording
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    width: 4,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                }),
                              )
                            : const SizedBox.shrink(),
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

class FaintLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.05) // Very faint
      ..strokeWidth = 1.0;

    double lineHeight = 40.0;
    for (double y = 100; y < size.height; y += lineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
