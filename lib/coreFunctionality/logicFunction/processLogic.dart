import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/coreFunctionality/mainUISettings.dart';

import 'isolateProcessPDV.dart';

Future<void> relativeBoxIsolateFunction(
    {required List<Map<String, dynamic>> queueNormalizeData,
    required List<List<double>> tempPrevCurr,
    required bool nowPerforming,
    required List<double> prevCoordinates,
    required List<double> temp,
    required List<double> currentCoordinates,
    required RootIsolateToken rootIsolateTokenNoMovement,
    required List<Map<String, dynamic>> queueMovementData,
    required Map<String, dynamic> checkMovementIsolate}) async {
  print('relative attempt --> ${queueNormalizeData.elementAt(0)['inputImage']}');
  print('relative attempt2 --> ${queueNormalizeData.elementAt(0)['token']}');

  if (queueNormalizeData.isNotEmpty) {
    compute(coordinatesRelativeBoxIsolate, queueNormalizeData.elementAt(0))
        .then((value) {
      queueNormalizeData.removeAt(0);
      tempPrevCurr.add(value);
      // inferencingList.add(value);
      if (nowPerforming == true) {
        temp = value;
        // temp.add(value);
      }
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
  }
}

Future<void> checkMovementFunction({
  required List<Map<String, dynamic>> queueMovementData,
  required bool checkFramesCaptured,
  required int framesCapturedCtr,
  required int execTotalFrames,
  required bool nowPerforming,
  required bool isDataCollected,
  required List<List<double>> inferencingList,
  required String dynamicCountDownText,
  required Color dynamicCountDownColor,
  required List<dynamic> coordinatesData,
  required int numExec,
  required RootIsolateToken rootIsolateTokenInferencing,
  required Map<String, dynamic> inferencingData,
  required List<double> temp,
  required bool countDowntoPerform,
  required CountDownController controller,
  required VoidCallback setStateCallback,
  required VoidCallback setStateCallback2,
  required int noMovementCtr,
}) async {
  if (queueMovementData.isNotEmpty) {
    compute(checkMovement, queueMovementData.elementAt(0)).then((value) async {
      queueMovementData.removeAt(0);
      print("isolateNoMovementResult ---> $value");

      if (value == true && checkFramesCaptured == false) {
        checkFramesCaptured = true;
        framesCapturedCtr++;
        print("frames captured --> $framesCapturedCtr");
        execTotalFrames = execTotalFrames + framesCapturedCtr;
        framesCapturedCtr = 0;

        if (nowPerforming == true) {
          print("stopping");
          isDataCollected = true;
          if (inferencingList.isNotEmpty) {
            dynamicCountDownText = 'collected';
            dynamicCountDownColor = secondaryColor;
            coordinatesData.add(inferencingList);
            numExec++;
          }
          print("current count---> ${coordinatesData.length}");
          inferencingList = [];
          print(
              "collecting--- ${isDataCollected} -------1---- ${nowPerforming}");
        }

        inferencingData = {
          'inferencingData': inferencingList,
          'token': rootIsolateTokenInferencing,
        };
      } else if (value == false) {
        if (nowPerforming == true) {
          dynamicCountDownText = 'collecting';
          dynamicCountDownColor = Colors.blue;
          checkFramesCaptured = false;

          // inferencingList.add(temp.elementAt(0));
          if (temp.isNotEmpty) {
            inferencingList.add(temp);
          }
          isDataCollected = false;
          print("collecting coordinates");
          print(
              "collecting--- ${isDataCollected} ------2----- ${nowPerforming}");
          temp = [];
        }
      }

      if (value == true) {
        // -----------------checking for movement before executing for collecting data--------------------------------------
        if (nowPerforming == false) {
          if (countDowntoPerform == false) {
            controller.start();
            countDowntoPerform = true;
            dynamicCountDownText = 'Perform';
          }
        }

        if (controller.getTime().toString() == "3" && nowPerforming == false) {
          nowPerforming = true;
        }
        //---------------after not moving for 3 sec-------------------------

        // execTotalFrames = execTotalFrames + noMovementCtr;

        // Map<String, dynamic> inferencingData = {
        //   'inferencingData': inferencingList.sublist(0, noMovementCtr),
        //   'token': rootIsolateTokenInferencing,
        // };
        noMovementCtr = 0;
        setStateCallback();
        // setState(() {
        //   dynamicText = 'no movement detected';
        //   dynamicCtr = noMovementCtr.toString();
        //   try {
        //     avgFrames = execTotalFrames / numExec;
        //     resultAvgFrames = avgFrames.toStringAsFixed(2);
        //     avgFrames = double.parse(resultAvgFrames);
        //   } catch (error) {
        //     avgFrames = 0;
        //   }
        // });
      } else {
        print("outside nowperforming--->, $nowPerforming");

        // noMovementCtr++;
        // -----------------checking for movement before executing for collecting data--------------------------------------

        if (nowPerforming == false) {
          if (countDowntoPerform == true) {
            controller.reset();
            countDowntoPerform = false;
          }
        }
        // -----------------------------------------------------------------------------------------------------------
        setStateCallback2();
        // setState(() {
        //   dynamicText = 'movement detected';
        //   dynamicCtr = noMovementCtr.toString();
        // });
      }
    }).catchError((error) {
      print("Error at checkMovement ---> $error");
    });
  }
}
