import 'package:flutter/material.dart';

class MemoryDetailScreen extends StatelessWidget {
  const MemoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      appBar: AppBar(title: const Text('Memory Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Memory ID: $args', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            const Text(
              'Full text of the memory goes here. I met Rahul at the cafe and we talked about the project...',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              children: const [
                Chip(label: Text('friend')),
                Chip(label: Text('happy')),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Emotion Summary: You felt excited and proud.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
