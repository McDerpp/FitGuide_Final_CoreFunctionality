import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'coordinates_translator.dart';

class PosePainter extends CustomPainter {
  PosePainter(
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
    this.executionState,
  );

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  late int executionState;

  @override
  void paint(Canvas canvas, Size size) {
    Color currentColorState = Colors.white;

    if (executionState == 0) {
      currentColorState = Colors.white;
    } else if (executionState == 1) {
      currentColorState = Colors.red;
    } else if (executionState == 2) {
      currentColorState = Colors.blue;
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..color = currentColorState;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..color = currentColorState;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..color = currentColorState;

    final List<int> ignoreCoordinates = [8, 6, 4, 0, 1, 3, 7];
    int ignoreCtr = 0;

    for (final pose in poses) {
      if (ignoreCoordinates.contains(ignoreCtr) == false) {
        pose.landmarks.forEach((_, landmark) {
          canvas.drawCircle(
              Offset(
                translateX(
                  landmark.x,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
                translateY(
                  landmark.y,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
              ),
              1,
              paint);
        });
      }
      ignoreCtr++;

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
            Offset(
                translateX(
                  joint1.x,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
                translateY(
                  joint1.y,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                )),
            Offset(
                translateX(
                  joint2.x,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
                translateY(
                  joint2.y,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                )),
            paintType);
      }

      paintLine(
        PoseLandmarkType.leftEye,
        PoseLandmarkType.rightEye,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.leftEye,
        PoseLandmarkType.leftMouth,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.rightEye,
        PoseLandmarkType.rightMouth,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.leftMouth,
        PoseLandmarkType.rightMouth,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftElbow,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.rightShoulder,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.leftHip,
        PoseLandmarkType.rightHip,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftWrist,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightElbow,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.rightElbow,
        PoseLandmarkType.rightWrist,
        rightPaint,
      );

      //Draw Body
      paintLine(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftHip,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightHip,
        rightPaint,
      );

      //Draw legs
      paintLine(
        PoseLandmarkType.leftHip,
        PoseLandmarkType.leftKnee,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.leftKnee,
        PoseLandmarkType.leftAnkle,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.rightHip,
        PoseLandmarkType.rightKnee,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.rightKnee,
        PoseLandmarkType.rightAnkle,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.rightIndex,
        PoseLandmarkType.rightWrist,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.rightPinky,
        PoseLandmarkType.rightWrist,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.rightPinky,
        PoseLandmarkType.rightIndex,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.leftIndex,
        PoseLandmarkType.leftWrist,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.leftPinky,
        PoseLandmarkType.leftWrist,
        rightPaint,
      );

      paintLine(
        PoseLandmarkType.leftPinky,
        PoseLandmarkType.leftIndex,
        rightPaint,
      );

      paintLine(
        PoseLandmarkType.rightAnkle,
        PoseLandmarkType.rightFootIndex,
        rightPaint,
      );

      paintLine(
        PoseLandmarkType.rightFootIndex,
        PoseLandmarkType.rightHeel,
        rightPaint,
      );

      paintLine(
        PoseLandmarkType.rightHeel,
        PoseLandmarkType.rightAnkle,
        rightPaint,
      );

      paintLine(
        PoseLandmarkType.leftAnkle,
        PoseLandmarkType.leftFootIndex,
        leftPaint,
      );

      paintLine(
        PoseLandmarkType.leftFootIndex,
        PoseLandmarkType.leftHeel,
        leftPaint,
      );

      paintLine(
        PoseLandmarkType.leftHeel,
        PoseLandmarkType.leftAnkle,
        leftPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }
}
