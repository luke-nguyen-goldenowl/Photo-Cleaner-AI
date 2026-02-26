import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:myapp/src/localization/localization_utils.dart';

class ClockLoadingIndicator extends StatefulWidget {
  const ClockLoadingIndicator({super.key});

  @override
  State<ClockLoadingIndicator> createState() => _ClockLoadingIndicatorState();
}

class _ClockLoadingIndicatorState extends State<ClockLoadingIndicator> {
  double progress = 0.0;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    setState(() {
      progress += 0.01;
      if (progress > 0.98) progress = 0.98;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLoadingIndicator(context, progress: progress);
  }
}

Widget _buildLoadingIndicator(BuildContext context, {double? progress}) {
  final primary = const Color(0xFF6C63FF);
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Lottie.asset(
            'assets/lotties/loading-clock.json',
            fit: BoxFit.contain,
            repeat: true,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          S.of(context).common_loading,
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF6C63FF),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 200,
          child: Column(
            children: [
              LinearProgressIndicator(
                value: progress?.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: primary.withOpacity(0.14),
                valueColor: AlwaysStoppedAnimation<Color>(primary),
              ),
              const SizedBox(height: 8),
              Text(
                progress != null
                    ? '${(progress * 100).toInt()}%'
                    : S.of(context).common_loading,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
