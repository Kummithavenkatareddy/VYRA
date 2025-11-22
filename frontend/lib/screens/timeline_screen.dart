import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/api_models.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final ApiService _apiService = ApiService();

  late Future<List<TimelineResponse>> _memoriesFuture;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  void _loadMemories() {
    String? dateStr;
    if (_selectedDate != null) {
      dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    }

    setState(() {
      _memoriesFuture = _apiService.getTimeline(date: dateStr);
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2c5364),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _loadMemories();
    });
  }

  String _formatDisplayDate(String dateStr, String timeStr) {
    try {
      final date = DateTime.parse(dateStr);
      final formattedDate = DateFormat('MMM d, yyyy').format(date);
      return "$formattedDate • $timeStr";
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: NotebookLinesPainter())),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black87,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Column(
                        children: [
                          const Text(
                            'Timeline',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_selectedDate != null)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDate = null;
                                  _loadMemories();
                                });
                              },
                              child: Text(
                                "Clear Filter",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          _selectedDate == null
                              ? Icons.calendar_today_outlined
                              : Icons.event_available,
                          color: _selectedDate == null
                              ? Colors.black87
                              : Colors.blue.shade700,
                        ),
                        onPressed: _pickDate,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<TimelineResponse>>(
                    future: _memoriesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error loading memories:\n${snapshot.error}",
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            "No memories found.\nTry recording one!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        );
                      }

                      final memories = snapshot.data!;

                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 40),
                        itemCount: memories.length,
                        itemBuilder: (context, index) {
                          final memory = memories[index];
                          return TimelineItem(
                            dateDisplay: _formatDisplayDate(
                              memory.date,
                              memory.time,
                            ),
                            text: memory.text,
                            tone: memory.tone,
                            isLast: index == memories.length - 1,
                          );
                        },
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
  final String dateDisplay;
  final String text;
  final String tone;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.dateDisplay,
    required this.text,
    required this.tone,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: 40,
                    bottom: 0,
                    child: Container(width: 2, color: Colors.grey.shade300),
                  ),
                Positioned(
                  top: 0,
                  height: 40,
                  child: Container(width: 4, color: Colors.grey.shade300),
                ),
                Positioned(
                  top: 40,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _getToneColor(tone),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0, right: 20.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7),
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
                      dateDisplay,
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

  Color _getToneColor(String tone) {
    switch (tone.toLowerCase()) {
      case 'happy':
        return Colors.orangeAccent;
      case 'sad':
        return Colors.blueGrey;
      case 'excited':
        return Colors.pinkAccent;
      case 'anxious':
        return Colors.purpleAccent;
      case 'confident':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}

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
