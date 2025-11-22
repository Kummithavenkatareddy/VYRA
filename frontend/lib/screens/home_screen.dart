import 'package:flutter/material.dart';
import '../widgets/notebook_background.dart';
import '../widgets/vintage_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotebookBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header Area
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () {
                        // Handle back navigation if needed, or maybe this is the root
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Buttons
              VintageButton(
                label: 'Capture Your Moment',
                icon: Icons.edit_note, // Using edit_note as a proxy for the pen
                onTap: () => Navigator.pushNamed(context, '/enter_memory'),
                showArrow:
                    false, // The image doesn't show an arrow for the first button, but maybe it's nice?
                // Actually the image DOES NOT show an arrow for the first one, but DOES for the others.
                // Wait, looking closely at the image...
                // "Enter Memory" has a pen icon and NO arrow.
                // "Timeline" has a clock icon and an arrow.
                // "Ask AI" has a brain icon and an arrow.
              ),

              VintageButton(
                label: 'Life Replay',
                icon: Icons.access_time,
                onTap: () => Navigator.pushNamed(context, '/timeline'),
                showArrow: true,
              ),

              VintageButton(
                label: 'Ask Vyra',
                icon: Icons.psychology, // Brain icon
                onTap: () => Navigator.pushNamed(context, '/ask_ai'),
                showArrow: true,
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
