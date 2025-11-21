import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  // Mock Data
  final List<Map<String, String>> memories = [
    {
      "date": "October 26, 2023",
      "text": "Walked through the old park today, the autumn leaves were golden and vibrant. It reminded me of..."
    },
    {
      "date": "October 15, 2023",
      "text": "Finally finished reading that book about the history of coffee. So fascinating how..."
    },
    {
      "date": "September 30, 2023",
      "text": "Celebrated Sarah's birthday at the new Italian place. The pasta was incredible, and..."
    },
  ];

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2023, 10, 26), // Set to a date within mock range for demo
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2c5364), // Dark blue theme
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (!mounted) return;
      // Simulate redirection/filtering
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Jumping to ${DateFormat('MMMM d, yyyy').format(picked)}..."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2c5364),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Background Lines
          Positioned.fill(
            child: CustomPaint(
              painter: NotebookLinesPainter(),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Timeline',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today_outlined, color: Colors.black87),
                        onPressed: _pickDate,
                      ),
                    ],
                  ),
                ),

                // Timeline List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 40),
                    itemCount: memories.length,
                    itemBuilder: (context, index) {
                      final memory = memories[index];
                      return TimelineItem(
                        date: memory['date']!,
                        text: memory['text']!,
                        isLast: index == memories.length - 1,
                      );
                    },
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

class TimelineItem extends StatelessWidget {
  final String date;
  final String text;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.date,
    required this.text,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Timeline Section
          SizedBox(
            width: 80,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Vertical Line
                if (!isLast)
                  Positioned(
                    top: 40,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
                // Top connection line
                 Positioned(
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 4,
                      color: Colors.grey.shade300,
                    ),
                  ),
                
                // Dot
                Positioned(
                  top: 40,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right Card Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0, right: 20.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7), // Creamy white
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontFamily: 'Serif',
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotebookLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.5;

    double lineHeight = 32.0;
    for (double y = 60; y < size.height; y += lineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
