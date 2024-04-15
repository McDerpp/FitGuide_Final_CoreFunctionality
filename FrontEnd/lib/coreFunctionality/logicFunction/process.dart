import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:frontend/coreFunctionality/mainUISettings.dart';
import 'package:frontend/coreFunctionality/logicFunction/movementCheck.dart';
import 'package:frontend/coreFunctionality/logicFunction/normalizeCoordinates.dart';
import 'package:frontend/services/provider_collection.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void HeavyProcess(List<Pose> poses) {
  print("heavyprocess1");
  final ref = ProviderContainer();
  RootIsolateToken rootIsolateTokenNormalization = RootIsolateToken.instance!;
  RootIsolateToken rootIsolateTokenNoMovement = RootIsolateToken.instance!;
  RootIsolateToken rootIsolateTokenInferencing = RootIsolateToken.instance!;
  RootIsolateToken rootIsolateTokenTranslating = RootIsolateToken.instance!;

  int test = 0;
// IMPORTANT CONFIGURATIONS---------------------------------------------------------------------------------------
  double requiredDataNum = 50;

// IMPORTANT CONFIGURATIONS---------------------------------------------------------------------------------------

  List<double> prevCoordinates = [];
  List<double> currentCoordinates = [];
  List<List<double>> inferencingList = [];
  List<List<double>> tempPrevCurr = [];
  bool checkFramesCaptured = false;
  int framesCapturedCtr = 0;

  String dynamicText = 'no movement \n detected';
  String dynamicCtr = '0';
  int execTotalFrames = 0;
  int numExec = 0;
  double avgFrames = 0.0;
  int minFrame = 0;
  int maxFrame = 0;

  Map<String, dynamic> inferencingData = {};
  Map<String, dynamic> checkMovementIsolate = {};

  List<Map<String, dynamic>> queueNormalizeData = [];
  List<Map<String, dynamic>> queueMovementData = [];
  List<Map<String, dynamic>> queueInferencingData = [];
  int noMovementCtr = 0;
  int executionStateResult = 0;
  Color dynamicCountDownColor = secondaryColor;

  late Map<String, Color> colorSet1;
  late Map<String, Color> colorSet2;

  bool allCoordinatesPresent = false;

  int buffer = 0;
  int bufferCtr = 0;
  buffer = ref.read(bufferProvider);

  late int _seconds;
  late Timer _timer;

  List<double> temp = [];
// List<dynamic> coordinatesData = [];
  List<List<List<double>>> coordinatesData = [];

  bool isSet = true;
  bool isDataCollected = true;
  int collectingCtr = 0;
  double _progress = 0.0;
  double _sliderValue = 0.0;
  int _sliderValue2 = 0;
  double variance = 0;
  int numFrameVariance = 5;
  int collectingCtrDelay = 0;

  bool nowPerforming = false;
  bool countDowntoPerform = false;
  bool checkCountDowntoPerform = false;

  String dynamicCountDownText = 'Ready';

  String resultAvgFrames = '';

  // ==================================[isolate function processImage ]==================================

// // ==================================[isolate function forcoordinatesRelativeBoxIsolate ]==================================
  print("heavyprocess2");

  test++;
  try {
    print("normalizing...");
    Map<String, dynamic> dataNormalizationIsolate = {
      'inputImage': poses.first.landmarks.values,
      'token': rootIsolateTokenNormalization,
      'coordinatesIgnore': ignoreCoordinatesInitialized,
    };
    // for (int ctrCheck = 0;
    //     ctrCheck >= poses.first.landmarks.values.length;
    //     ctrCheck++) {
    //   print(
    //       "ctrCheckLikelihood ---> ${poses.first.landmarks.values.elementAt(ctrCheck).likelihood}");
    // }
    queueNormalizeData.add(dataNormalizationIsolate);
    print("queueNormalizeData --> ${queueNormalizeData.length}");
  } catch (error) {
    print("error at data normalization ----> $error");
  }
  print("heavyprocess3");

// // ==================================[isolate function forcoordinatesRelativeBoxIsolate ]==================================
  bufferCtr++;
  if (queueNormalizeData.isNotEmpty) {
    if (bufferCtr >= buffer) {
      bufferCtr = 0;
      compute(coordinatesRelativeBoxIsolate, queueNormalizeData.elementAt(0))
          .then((value) {
        print("coordinatesRelativeBoxIsolate3423423");

        queueNormalizeData.removeAt(0);
        tempPrevCurr.add(value['translatedCoordinates']);

        if (nowPerforming == true) {
          temp = value['translatedCoordinates'];
        }
        print("heavyprocess4");

// need ref
        allCoordinatesPresent = value['allCoordinatesPresent'];

        if (tempPrevCurr.length > 1) {
          prevCoordinates = tempPrevCurr.elementAt(0);
          currentCoordinates = tempPrevCurr.elementAt(1);

          Map<String, dynamic> checkMovementIsolate = {
            'prevCoordinates': prevCoordinates,
            'currentCoordinates': currentCoordinates,
            'token': rootIsolateTokenNoMovement,
          };
          queueMovementData.add(checkMovementIsolate);
          tempPrevCurr.removeAt(0);
        }
      }).catchError((error) {
        print("Error at coordinate relative ---> $error");
      });
    } else {
      queueNormalizeData.removeAt(0);
      print("buffering...");
    }
  }
  print("heavyprocess5");

// // ==================================[isolate function forcoordinatesRelativeBoxIsolate ]==================================

// // ==================================[isolate function checkMovement ]==================================
  if (queueMovementData.isNotEmpty) {
    compute(checkMovement, queueMovementData.elementAt(0)).then((value) async {
      print("heavyprocess6");

      queueMovementData.removeAt(0);
      print("MOVEMENT COLELCTED ---> $value");

      if (value == true && checkFramesCaptured == false) {
        checkFramesCaptured = true;

        if (nowPerforming == true) {
          isDataCollected = true;
          if (inferencingList.isNotEmpty) {
            executionStateResult = 2;

            // need ref
            executionStateResult = 2;

            dynamicCountDownText = 'collected';
            dynamicCountDownColor = secondaryColor;
            coordinatesData.add(inferencingList);

            execTotalFrames = execTotalFrames + inferencingList.length;

            if (minFrame == 0) {
              minFrame = inferencingList.length;
              ref.read(minFrameState.notifier).state = minFrame;
            }

            if (minFrame > inferencingList.length) {
              minFrame = inferencingList.length;
              ref.read(minFrameState.notifier).state = minFrame;
              print("minFrame ---> $minFrame ");
            }

            if (maxFrame < inferencingList.length) {
              maxFrame = inferencingList.length;
              ref.read(maxFrameState.notifier).state = maxFrame;
              print("maxFrame ---> $maxFrame ");
            }

            numExec++;
          }

          inferencingList = [];
        }

        // }
      } else if (value == false) {
        if (nowPerforming == true) {
          executionStateResult = 1;

// need ref
          executionStateResult = 1;

          dynamicCountDownText = 'collecting';
          dynamicCountDownColor = Colors.blue;
          checkFramesCaptured = false;

          if (temp.isNotEmpty) {
            inferencingList.add(temp);
          }
          isDataCollected = false;
          temp = [];
        }
      }

      if (value == true) {
        // -----------------checking for movement before executing for collecting data--------------------------------------
        if (nowPerforming == false) {
          if (countDowntoPerform == false) {
            // need ref(bool control_start = true/false)
            // _controller.start();
            ref.read(isTimerStart.notifier).state = true;

            countDowntoPerform = true;
            dynamicCountDownText = 'Perform';
          }
        }

        if (ref.read(timerCurrentTime) == "3" && nowPerforming == false) {
          nowPerforming = true;
        }

        noMovementCtr = 0;

        dynamicCtr = noMovementCtr.toString();
        try {
          avgFrames = execTotalFrames / numExec;
          resultAvgFrames = avgFrames.toStringAsFixed(2);
          avgFrames = double.parse(resultAvgFrames);
          ref.read(averageFrameState.notifier).state = avgFrames;

          if (avgFrames <= ref.read(averageThresholdBad)) {
            ref.read(averageColorProvider.notifier).state = Colors.red;
          } else if (avgFrames >= ref.read(averageThresholdBad) &&
              avgFrames <= ref.read(averageThresholdIdeal)) {
            ref.read(averageColorProvider.notifier).state = Colors.orange;
          } else if (avgFrames >= ref.read(averageThresholdIdeal)) {
            ref.read(averageColorProvider.notifier).state = Colors.green;
          }
          // ref.read(averageColorState.notifier).state = averageColor;
        } catch (error) {
          avgFrames = 0;
        }
        print("heavyprocess7");

        try {
          if (minFrame <= ref.read(minFrameThresholdBad)) {
            ref.read(maxFrameColorProvider.notifier).state = Colors.red;
          } else if (minFrame >= ref.read(minFrameThresholdBad) &&
              minFrame <= ref.read(minFrameThresholdIdeal)) {
            ref.read(maxFrameColorProvider.notifier).state = Colors.orange;
          } else if (minFrame >= ref.read(minFrameThresholdIdeal)) {
            ref.read(maxFrameColorProvider.notifier).state = Colors.green;
          }
          // ref.read(minFrameColorState.notifier).state = minFrameColor;
        } catch (error) {
          minFrame = 0;
        }

        try {
          if (maxFrame <= ref.read(maxFrameThresholdBad)) {
            ref.read(maxFrameColorProvider.notifier).state = Colors.red;
          } else if (maxFrame >= ref.read(maxFrameThresholdBad) &&
              maxFrame <= ref.read(maxFrameThresholdIdeal)) {
            ref.read(maxFrameColorProvider.notifier).state = Colors.orange;
          } else if (maxFrame >= ref.read(maxFrameThresholdIdeal)) {
            ref.read(maxFrameColorProvider.notifier).state = Colors.green;
          }
          // ref.read(maxFrameColorState.notifier).state = maxFrameColor;
        } catch (error) {
          maxFrame = 0;
        }
      } else {
        // -----------------checking for movement before executing for collecting data--------------------------------------

        if (nowPerforming == false) {
          if (countDowntoPerform == true) {
            // need ref(bool control_reset = true/false)
            // _controller.reset();
            ref.read(isTimerStart.notifier).state = true;
            countDowntoPerform = false;
          }
        }
        // -----------------------------------------------------------------------------------------------------------
      }
    }).catchError((error) {
      print("Error at checkMovement ---> $error");
    });
  }
}
