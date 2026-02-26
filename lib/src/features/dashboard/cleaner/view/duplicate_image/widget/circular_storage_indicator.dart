import 'dart:math' as math;
import 'package:flutter/material.dart';

class CircularStorageIndicator extends StatelessWidget {
  final double percentage;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;
  final String? centerText;

  const CircularStorageIndicator({
    super.key,
    required this.percentage,
    this.size = 80,
    this.strokeWidth = 6,
    this.color = const Color(0xFF667EEA),
    this.backgroundColor = const Color(0xFFE5E7EB),
    this.centerText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CircularProgressPainter(
          percentage: percentage.clamp(0, 100),
          strokeWidth: strokeWidth,
          color: color,
          backgroundColor: backgroundColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                  height: 1.0,
                ),
              ),
              if (centerText != null)
                Text(
                  centerText!,
                  style: TextStyle(
                    fontSize: size * 0.12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + (2 * math.pi * percentage / 100),
      colors: [
        color,
        color.withOpacity(0.7),
      ],
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (percentage / 100);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
