import 'package:flutter/material.dart';

class TextMemoryScreen extends StatefulWidget {
  const TextMemoryScreen({super.key});

  @override
  State<TextMemoryScreen> createState() => _TextMemoryScreenState();
}

class _TextMemoryScreenState extends State<TextMemoryScreen> {
  final _textController = TextEditingController();

  void _saveMemory() {
    // TODO: Implement save logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Memory Saved!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Memory')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'What happened today?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMemory,
              child: const Text('Save Memory'),
            ),
          ],
        ),
      ),
    );
  }
}
