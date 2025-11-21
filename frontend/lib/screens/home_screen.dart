import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FA), Color(0xFFC3CFE2)], // Light background gradient
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Home',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            _buildGradientButton(
              context,
              icon: Icons.mic_none_outlined,
              label: 'Record Memory',
              onTap: () => Navigator.pushNamed(context, '/record'),
            ),
            const SizedBox(height: 20),
            _buildGradientButton(
              context,
              icon: Icons.keyboard_outlined,
              label: 'Text Memory Entry',
              onTap: () => Navigator.pushNamed(context, '/text_entry'),
            ),
            const SizedBox(height: 20),
            _buildGradientButton(
              context,
              icon: Icons.access_time,
              label: 'Timeline View',
              onTap: () => Navigator.pushNamed(context, '/timeline'),
            ),
            const SizedBox(height: 20),
            _buildGradientButton(
              context,
              icon: Icons.auto_awesome_outlined,
              label: 'Ask AI',
              onTap: () => Navigator.pushNamed(context, '/ask_ai'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 280,
      height: 70,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)], // Dark blue gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 20),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
