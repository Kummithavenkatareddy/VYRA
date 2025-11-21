import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/record_memory_screen.dart';
import 'screens/text_memory_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/memory_detail_screen.dart';
import 'screens/ask_ai_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Memory Prosthetic',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/record': (context) => const RecordMemoryScreen(),
        '/text_entry': (context) => const TextMemoryScreen(),
        '/timeline': (context) => const TimelineScreen(),
        '/memory_detail': (context) => const MemoryDetailScreen(),
        '/ask_ai': (context) => const AskAIScreen(),
      },
    );
  }
}
