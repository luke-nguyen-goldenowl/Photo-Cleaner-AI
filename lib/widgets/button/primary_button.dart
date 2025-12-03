import 'package:flutter/material.dart';

class XPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const XPrimaryButton(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4834D4)],
              )
            : null,
        color: isEnabled ? null : Colors.grey, // Màu xám khi disable
        borderRadius: BorderRadius.circular(15),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
