import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:myapp/src/localization/localization_utils.dart';

class AutoProgressLoadingIndicator extends StatefulWidget {
  const AutoProgressLoadingIndicator({super.key});

  @override
  State<AutoProgressLoadingIndicator> createState() =>
      _AutoProgressLoadingIndicatorState();
}

class _AutoProgressLoadingIndicatorState
    extends State<AutoProgressLoadingIndicator> {
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
      if (progress > 0.98) {
        progress = 0.98;
      }
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
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (progress != null)
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 5,
                  color: const Color(0xFF6C63FF),
                  backgroundColor: const Color(0xFF6C63FF).withOpacity(0.15),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                  fontSize: 16,
                ),
              ),
            ],
          )
        else
          const CircularProgressIndicator(
            color: Color(0xFF6C63FF),
            strokeWidth: 5,
          ),
        const SizedBox(height: 20),
        Text(
          S.of(context).common_loading,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6C63FF),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
