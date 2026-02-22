import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class ScoreRing extends StatefulWidget {
  const ScoreRing({
    super.key,
    required this.score,
    required this.total,
    this.size = 160,
    this.strokeWidth = 10,
  });

  final int score;
  final int total;
  final double size;
  final double strokeWidth;

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.scoreRing,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.total == 0 ? 0.0 : widget.score / widget.total;
    final pct = (ratio * 100).round();

    Color arcColor;
    if (ratio >= 0.8) {
      arcColor = AppColors.success;
    } else if (ratio >= 0.5) {
      arcColor = AppColors.warning;
    } else {
      arcColor = AppColors.error;
    }

    final trackColor = Theme.of(
      context,
    ).colorScheme.outline.withValues(alpha: 0.2);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _ScoreRingPainter(
            value: _animation.value * ratio,
            trackColor: trackColor,
            arcColor: arcColor,
            strokeWidth: widget.strokeWidth,
          ),
          child: child,
        );
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$pct%',
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              '${widget.score}/${widget.total}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({
    required this.value,
    required this.trackColor,
    required this.arcColor,
    required this.strokeWidth,
  });

  final double value;
  final Color trackColor;
  final Color arcColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track circle
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Foreground arc
    if (value > 0) {
      final arcPaint = Paint()
        ..color = arcColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * value,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreRingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.arcColor != arcColor;
}
