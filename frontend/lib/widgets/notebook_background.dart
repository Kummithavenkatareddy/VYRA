import 'package:flutter/material.dart';

class NotebookBackground extends StatelessWidget {
  final Widget? child;

  const NotebookBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFDFBF7), // Off-white paper color
      child: CustomPaint(painter: _NotebookPainter(), child: child),
    );
  }
}

class _NotebookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1.0;

    final marginPaint = Paint()
      ..color = Colors.red.withOpacity(0.2)
      ..strokeWidth = 1.0;

    // Draw horizontal lines
    double lineHeight = 30.0;
    double topMargin = 60.0;

    for (double y = topMargin; y < size.height; y += lineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical margin line
    double marginX = 40.0;
    canvas.drawLine(
      Offset(marginX, 0),
      Offset(marginX, size.height),
      marginPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
