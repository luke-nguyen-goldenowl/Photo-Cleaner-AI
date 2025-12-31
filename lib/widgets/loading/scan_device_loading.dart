import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:myapp/src/localization/localization_utils.dart';

class ScanDeviceLoadingIndicator extends StatefulWidget {
  final double? progress;
  const ScanDeviceLoadingIndicator({super.key, this.progress});

  @override
  State<ScanDeviceLoadingIndicator> createState() =>
      _ScanDeviceLoadingIndicatorState();
}

class _ScanDeviceLoadingIndicatorState
    extends State<ScanDeviceLoadingIndicator> {
  double fakeProgress = 0.0;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    if (widget.progress == null) {
      _ticker = Ticker(_onTick)..start();
    }
  }

  void _onTick(Duration elapsed) {
    setState(() {
      fakeProgress += 0.01;
      if (fakeProgress > 0.98) fakeProgress = 0.98;
    });
  }

  @override
  void dispose() {
    if (widget.progress == null) {
      _ticker.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayProgress = widget.progress ?? fakeProgress;
    return _buildLoadingIndicator(context, progress: displayProgress);
  }
}

Widget _buildLoadingIndicator(BuildContext context, {double? progress}) {
  final primary = const Color(0xFF6C63FF);
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Lottie.asset(
            'assets/lotties/scan.json',
            fit: BoxFit.contain,
            repeat: true,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          S.of(context).common_scanning_device,
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
                    : S.of(context).common_scanning_device,
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
