import 'package:flutter/material.dart';

class VintageButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool showArrow;

  const VintageButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFF2E8D5), // Light beige
                Color(0xFFE6DCC3), // Slightly darker beige
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                offset: const Offset(0, -1),
                blurRadius: 2,
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.black87, size: 24),
                const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontFamily: 'Serif', // Using default serif for now
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (showArrow)
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black54,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
