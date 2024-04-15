import 'dart:math' as math;
import 'package:flutter/material.dart';

class HalfCircleProgressBar extends StatelessWidget {
  final Color backgroundColor;
  // final Color valueColor;
  // final Color valueColor2;

  final double strokeWidth;
  final int executionCount;
  final int incorrectExecutionCount;

  final int maxExecution;
  final Size sizeOfCircle;

  HalfCircleProgressBar({
    required this.backgroundColor,
    // required this.valueColor,
    // required this.valueColor2,
    required this.strokeWidth,
    required this.sizeOfCircle,
    required this.maxExecution,
    required this.executionCount,
    required this.incorrectExecutionCount,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: sizeOfCircle,
      painter: HalfCirclePainter(
        backgroundColor: backgroundColor,
        // valueColor: valueColor,
        // valueColor2: valueColor2,
        strokeWidth: strokeWidth,
        executionCount: executionCount,
        incorrectExecutionCount: incorrectExecutionCount,
        maxExecution: maxExecution,
      ),
    );
  }
}

class HalfCirclePainter extends CustomPainter {
  final Color backgroundColor;
  // final Color valueColor;
  // final Color valueColor2;
  final double strokeWidth;
  final int executionCount;
  final int incorrectExecutionCount;

  final int maxExecution;

  HalfCirclePainter({
    required this.backgroundColor,
    // required this.valueColor,
    // required this.valueColor2,
    required this.strokeWidth,
    required this.executionCount,
    required this.incorrectExecutionCount,
    required this.maxExecution,
  });

  @override
  void paint(Canvas canvas, Size size) {
    late double value = executionCount / maxExecution;
    late double value2 = incorrectExecutionCount / maxExecution;

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
      ..color = Colors.lightGreen[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final paintValue2 = Paint()
      ..color = Colors.red[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final startAngle = -math.pi;
    final sweepAngleCorrect = math.pi * value;
    final sweepAngleIncorrect = math.pi * value2;

    // Draw background arc
    canvas.drawArc(rect, startAngle, math.pi, false, paintBackground);

    // Draw value arc
    canvas.drawArc(rect, startAngle, sweepAngleCorrect, false, paintValue);
    canvas.drawArc(rect, sweepAngleCorrect + startAngle, sweepAngleIncorrect,
        false, paintValue2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
