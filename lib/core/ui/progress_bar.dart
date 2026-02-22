import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.height = 8});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final normalized = value.clamp(0.0, 1.0);
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: normalized),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, animatedValue, _) {
        return CustomPaint(
          size: Size(double.infinity, height),
          painter: _ProgressPainter(
            value: animatedValue,
            trackColor: scheme.outline.withValues(alpha: 0.4),
            fillColor: scheme.primary,
          ),
        );
      },
    );
  }
}

class _ProgressPainter extends CustomPainter {
  _ProgressPainter({
    required this.value,
    required this.trackColor,
    required this.fillColor,
  });

  final double value;
  final Color trackColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height / 2;

    // Track
    final trackPaint = Paint()..color = trackColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ),
      trackPaint,
    );

    // Fill
    if (value > 0) {
      final fillWidth = size.width * value;
      final fillPaint = Paint()..color = fillColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            0,
            0,
            fillWidth.clamp(size.height, size.width),
            size.height,
          ),
          Radius.circular(radius),
        ),
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.fillColor != fillColor;
}
