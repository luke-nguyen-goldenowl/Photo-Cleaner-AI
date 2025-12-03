import 'package:flutter/material.dart';

// Logo động với Hero Animation
class XAppLogo extends StatelessWidget {
  final double size;
  const XAppLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'app_logo',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF4834D4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          Icons.auto_awesome, // Icon đại diện cho AI/Magic
          color: Colors.orangeAccent,
          size: size * 0.5,
        ),
      ),
    );
  }
}
