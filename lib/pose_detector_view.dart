import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

import 'detector_view.dart';
import 'painters/pose_painter.dart';
// import 'painters/coordinate_relative.dart';

enum PoseLandmarkType {
  nose,
  leftEyeInner,
  leftEye,
  leftEyeOuter,
  rightEyeInner,
  rightEye,
  rightEyeOuter,
  leftEar,
  rightEar,
  leftMouth,
  rightMouth,
  leftShoulder,
  rightShoulder,
  leftElbow,
  rightElbow,
  leftWrist,
  rightWrist,
  leftPinky,
  rightPinky,
  leftIndex,
  rightIndex,
  leftThumb,
  rightThumb,
  leftHip,
  rightHip,
  leftKnee,
  rightKnee,
  leftAnkle,
  rightAnkle,
  leftHeel,
  rightHeel,
  leftFootIndex,
  rightFootIndex
}

class PoseDetectorView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Pose Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final poses = await _poseDetector.processImage(inputImage);
    // print("coordinates_relative_box");
    if (poses.isNotEmpty) {
      coordinates_relative_box(poses);
    }

    for (var po in poses) {
      for (var x in po.landmarks.values) {
        print(
            "${x.type} -- ${x.x} -- ${x.y} =============================================================");
      }
    }
    print("poses--------------------------->  $poses");
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = 'Poses found: ${poses.length}\n\n';
      // TODO: set _customPaint to draw landmarks on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  List<double> coordinates_relative_box(List<Pose> rawCoordiantes) {
    print("coordinates_relative_box");
    late List<double> translated_coordinates;
    translated_coordinates = [];

    if (rawCoordiantes.length != 32) {
      return translated_coordinates;
    }

    double min_coordinates_x = rawCoordiantes.first.landmarks.values.first.x;
    double min_coordinates_y = rawCoordiantes.first.landmarks.values.first.y;

    double max_coordinates_x = rawCoordiantes.first.landmarks.values.first.x;
    double max_coordinates_y = rawCoordiantes.first.landmarks.values.first.y;

    var value_x_range;
    var value_y_range;

    var raw_x;
    var raw_y;

    for (var poseList in rawCoordiantes) {
      for (var pose in poseList.landmarks.values) {
        if (min_coordinates_x >= pose.x) {
          min_coordinates_x = pose.x;
        }
        if (min_coordinates_x >= pose.y) {
          min_coordinates_x = pose.y;
        }

        if (max_coordinates_x <= pose.x) {
          max_coordinates_x = pose.x;
        }
        if (max_coordinates_x <= pose.y) {
          max_coordinates_x = pose.y;
        }
      }
      print("min_coordinates_x-> $min_coordinates_x");
      print("min_coordinates_y $min_coordinates_y");
      print("max_coordinates_x $max_coordinates_x");
      print("max_coordinates_y $max_coordinates_y");

      for (var pose in poseList.landmarks.values) {
        value_x_range = (pose.x - min_coordinates_x) /
            (max_coordinates_x - min_coordinates_x);
        value_y_range = (pose.y - min_coordinates_y) /
            (max_coordinates_y - min_coordinates_y);
        print(
            "value_x_range-->$value_x_range value_y_range-->$value_y_range --------------------------------------------()");
        // flattening it ahead of time for later processes later...
        translated_coordinates.add(value_x_range);
        translated_coordinates.add(value_y_range);
      }
    }

    return translated_coordinates;
  }

  Future<bool> coordinatesInferencingIndividual(List<double> translatedCoordinates) async {
    bool isCorrect = false;

    try {
      final head = await tfl.Interpreter.fromAsset(
          'lib/assets/models/updated_model/converted_model_head6093(loss_0.048)(acc_0.995).tflite');
      final left_feet = await tfl.Interpreter.fromAsset(
          'lib/assets/models/updated_model/converted_model_left_feet6093(loss_0.045)(acc_0.995).tflite');
      final left_hand = await tfl.Interpreter.fromAsset(
          'lib/assets/models/updated_model/converted_model_left_hand6093(loss_0.047)(acc_0.989).tflite');
      final left_lower_arm = await tfl.Interpreter.fromAsset(
          'lib/assets/models/updated_model/converted_model_left_lower_arm6093(loss_0.137)(acc_0.963).tflite');
      final left_lower_leg = await tfl.Interpreter.fromAsset(
          'lib/assets/models/updated_model/converted_model_left_lower_leg6093(loss_0.046)(acc_0.989).tflite');
      final left_upper_arm = await tfl.Interpreter.fromAsset(
          'lib/assets/models/updated_model/converted_model_left_upper_arm6093(loss_0.049)(acc_0.984).tflite');
      final left_upper_leg = await tfl.Interpreter.fromAsset(
          'lib/assets/models/updated_model/converted_model_left_upper_leg6093(loss_0.083)(acc_0.973).tflite');
      final right_feet = await tfl.Interpreter.fromAsset(
          'lib/assets/models/updated_model/converted_model_right_hand6093(loss_0.137)(acc_0.979).tflite');
      final right_hand = await tfl.Interpreter.fromAsset(
          'lib/assets/models/updated_model/converted_model_right_lower_arm6093(loss_0.199)(acc_0.957).tflite');
      final right_lower_arm = await tfl.Interpreter.fromAsset(
          'lib/assets/models/updated_model/converted_model_right_lower_arm6093(loss_0.199)(acc_0.957).tflite');
      final right_lower_leg = await tfl.Interpreter.fromAsset(
          'lib/assets/models/updated_model/converted_model_right_lower_leg6093(loss_0.57)(acc_0.84).tflite');
      final right_upper_arm = await tfl.Interpreter.fromAsset(
          'lib/assets/models/updated_model/converted_model_right_upper_arm6093(loss_0.105)(acc_0.952).tflite');
      final right_upper_leg = await tfl.Interpreter.fromAsset(
          'lib/assets/models/updated_model/converted_model_right_upper_leg6093(loss_0.239)(acc_0.915).tflite');


      var head_inference = head.run(input, output);

    } catch (error) {
      print("inferencing initializing error! -> $error");

    }

    return isCorrect;
  }
}
