import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'coordinates_translator.dart';

class PosePainter extends CustomPainter {
  PosePainter(this.poses, this.imageSize, this.rotation,
      this.cameraLensDirection, this.executionState, this.ignoreCoordinates);

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  late int executionState;
  final List ignoreCoordinates;

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

    // final List<int> ignoreCoordinates = [8, 6, 4, 0, 1, 3, 7];
    int ignoreCtr = 0;
    print("pose painter coordinates ignore ---> ${ignoreCoordinates} ");

    for (final pose in poses) {
      // if (ignoreCoordinates.contains(ignoreCtr) == true) {
      //   pose.landmarks.forEach((_, landmark) {
      //     canvas.drawCircle(
      //         Offset(
      //           translateX(
      //             landmark.x,
      //             size,
      //             imageSize,
      //             rotation,
      //             cameraLensDirection,
      //           ),
      //           translateY(
      //             landmark.y,
      //             size,
      //             imageSize,
      //             rotation,
      //             cameraLensDirection,
      //           ),
      //         ),
      //         1,
      //         paint);
      //   });
      // }
      // ignoreCtr++;

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

      if (ignoreCoordinates.contains(2) && ignoreCoordinates.contains(5)) {
        paintLine(
          PoseLandmarkType.leftEye,
          PoseLandmarkType.rightEye,
          leftPaint,
        );
      }
      if (ignoreCoordinates.contains(2) && ignoreCoordinates.contains(9)) {
        paintLine(
          PoseLandmarkType.leftEye,
          PoseLandmarkType.leftMouth,
          leftPaint,
        );
      }
      if (ignoreCoordinates.contains(5) && ignoreCoordinates.contains(10)) {
        paintLine(
          PoseLandmarkType.rightEye,
          PoseLandmarkType.rightMouth,
          leftPaint,
        );
      }
      if (ignoreCoordinates.contains(9) && ignoreCoordinates.contains(10)) {
        paintLine(
          PoseLandmarkType.leftMouth,
          PoseLandmarkType.rightMouth,
          leftPaint,
        );
      }
      if (ignoreCoordinates.contains(11) && ignoreCoordinates.contains(13)) {
        paintLine(
          PoseLandmarkType.leftShoulder,
          PoseLandmarkType.leftElbow,
          leftPaint,
        );
      }
      if (ignoreCoordinates.contains(11) && ignoreCoordinates.contains(12)) {
        paintLine(
          PoseLandmarkType.leftShoulder,
          PoseLandmarkType.rightShoulder,
          leftPaint,
        );
      }
      if (ignoreCoordinates.contains(23) && ignoreCoordinates.contains(24)) {
        paintLine(
          PoseLandmarkType.leftHip,
          PoseLandmarkType.rightHip,
          leftPaint,
        );
      }
      if (ignoreCoordinates.contains(13) && ignoreCoordinates.contains(15)) {
        paintLine(
          PoseLandmarkType.leftElbow,
          PoseLandmarkType.leftWrist,
          leftPaint,
        );
      }
      if (ignoreCoordinates.contains(10) && ignoreCoordinates.contains(14)) {
        paintLine(
          PoseLandmarkType.rightShoulder,
          PoseLandmarkType.rightElbow,
          rightPaint,
        );
      }
      if (ignoreCoordinates.contains(14) && ignoreCoordinates.contains(16)) {
        paintLine(
          PoseLandmarkType.rightElbow,
          PoseLandmarkType.rightWrist,
          rightPaint,
        );
      }

      //Draw Body
      if (ignoreCoordinates.contains(23) && ignoreCoordinates.contains(11)) {
        paintLine(
          PoseLandmarkType.leftShoulder,
          PoseLandmarkType.leftHip,
          leftPaint,
        );
      }
      if (ignoreCoordinates.contains(12) && ignoreCoordinates.contains(24)) {
        paintLine(
          PoseLandmarkType.rightShoulder,
          PoseLandmarkType.rightHip,
          rightPaint,
        );
      }
      //Draw legs
      if (ignoreCoordinates.contains(23) && ignoreCoordinates.contains(25)) {
        paintLine(
          PoseLandmarkType.leftHip,
          PoseLandmarkType.leftKnee,
          leftPaint,
        );
      }
      if (ignoreCoordinates.contains(25) && ignoreCoordinates.contains(27)) {
        paintLine(
          PoseLandmarkType.leftKnee,
          PoseLandmarkType.leftAnkle,
          leftPaint,
        );
      }
      if (ignoreCoordinates.contains(24) && ignoreCoordinates.contains(26)) {
        paintLine(
          PoseLandmarkType.rightHip,
          PoseLandmarkType.rightKnee,
          rightPaint,
        );
      }
      if (ignoreCoordinates.contains(26) && ignoreCoordinates.contains(28)) {
        paintLine(
          PoseLandmarkType.rightKnee,
          PoseLandmarkType.rightAnkle,
          rightPaint,
        );
      }
      if (ignoreCoordinates.contains(20) && ignoreCoordinates.contains(16)) {
        paintLine(
          PoseLandmarkType.rightIndex,
          PoseLandmarkType.rightWrist,
          rightPaint,
        );
      }
      if (ignoreCoordinates.contains(18) && ignoreCoordinates.contains(16)) {
        paintLine(
          PoseLandmarkType.rightPinky,
          PoseLandmarkType.rightWrist,
          rightPaint,
        );
      }
      if (ignoreCoordinates.contains(18) && ignoreCoordinates.contains(20)) {
        paintLine(
          PoseLandmarkType.rightPinky,
          PoseLandmarkType.rightIndex,
          rightPaint,
        );
      }
      if (ignoreCoordinates.contains(19) && ignoreCoordinates.contains(15)) {
        paintLine(
          PoseLandmarkType.leftIndex,
          PoseLandmarkType.leftWrist,
          rightPaint,
        );
      }
      if (ignoreCoordinates.contains(17) && ignoreCoordinates.contains(15)) {
        paintLine(
          PoseLandmarkType.leftPinky,
          PoseLandmarkType.leftWrist,
          rightPaint,
        );
      }

      if (ignoreCoordinates.contains(17) && ignoreCoordinates.contains(19)) {
        paintLine(
          PoseLandmarkType.leftPinky,
          PoseLandmarkType.leftIndex,
          rightPaint,
        );
      }
      if (ignoreCoordinates.contains(28) && ignoreCoordinates.contains(32)) {
        paintLine(
          PoseLandmarkType.rightAnkle,
          PoseLandmarkType.rightFootIndex,
          rightPaint,
        );
      }
      if (ignoreCoordinates.contains(32) && ignoreCoordinates.contains(30)) {
        paintLine(
          PoseLandmarkType.rightFootIndex,
          PoseLandmarkType.rightHeel,
          rightPaint,
        );
      }
      if (ignoreCoordinates.contains(30) && ignoreCoordinates.contains(28)) {
        paintLine(
          PoseLandmarkType.rightHeel,
          PoseLandmarkType.rightAnkle,
          rightPaint,
        );
      }
      if (ignoreCoordinates.contains(27) && ignoreCoordinates.contains(31)) {
        paintLine(
          PoseLandmarkType.leftAnkle,
          PoseLandmarkType.leftFootIndex,
          leftPaint,
        );
      }
      if (ignoreCoordinates.contains(31) && ignoreCoordinates.contains(29)) {
        paintLine(
          PoseLandmarkType.leftFootIndex,
          PoseLandmarkType.leftHeel,
          leftPaint,
        );
      }
      if (ignoreCoordinates.contains(29) && ignoreCoordinates.contains(27)) {
        paintLine(
          PoseLandmarkType.leftHeel,
          PoseLandmarkType.leftAnkle,
          leftPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }
}
