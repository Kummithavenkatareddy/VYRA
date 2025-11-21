import 'package:flutter/material.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timeline')),
      body: ListView.builder(
        itemCount: 5, // Placeholder count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text('Memory #$index'),
              subtitle: const Text('Short preview of the memory...'),
              onTap: () {
                Navigator.pushNamed(context, '/memory_detail', arguments: index);
              },
            ),
          );
        },
      ),
    );
  }
}
