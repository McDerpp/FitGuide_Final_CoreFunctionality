import 'dart:math' as math;
import 'package:flutter/material.dart';

class HalfCircleProgressBar extends StatelessWidget {
  final Color backgroundColor;
  final Color valueColor;
  final double strokeWidth;
  final int executionCount;
  final int maxExecution;
  final Size sizeOfCircle;

  HalfCircleProgressBar({
    required this.backgroundColor,
    required this.valueColor,
    required this.strokeWidth,
    required this.sizeOfCircle,
    required this.maxExecution,
    required this.executionCount,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: sizeOfCircle,
      painter: HalfCirclePainter(
        backgroundColor: backgroundColor,
        valueColor: valueColor,
        strokeWidth: strokeWidth,
        executionCount: executionCount,
        maxExecution: maxExecution,
      ),
    );
  }
}

class HalfCirclePainter extends CustomPainter {
  final Color backgroundColor;
  final Color valueColor;
  final double strokeWidth;
  final int executionCount;
  final int maxExecution;

  HalfCirclePainter({
    required this.backgroundColor,
    required this.valueColor,
    required this.strokeWidth,
    required this.executionCount,
    required this.maxExecution,
  });

  @override
  void paint(Canvas canvas, Size size) {
    late double value = executionCount / maxExecution;

    print("executionCount --- $executionCount");
    print("maxExecution --- $maxExecution");
    print("value --- $value");

    if (value > 1) {
      value = 1;
    }

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paintBackground = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final paintValue = Paint()
      ..color = valueColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final startAngle = -math.pi;
    final sweepAngle = math.pi * value;

    // Draw background arc
    canvas.drawArc(rect, startAngle, math.pi, false, paintBackground);

    // Draw value arc
    canvas.drawArc(rect, startAngle, sweepAngle, false, paintValue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
