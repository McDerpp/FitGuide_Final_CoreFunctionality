import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/globalVariables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logicFunction/isolateProcessPDV.dart';
import '../mainUISettings.dart';

void dialogBoxNotif(
  BuildContext context,
  int notifState,
  String nextExercise, {
  double widthMultiplier = .5,
  double heightMultiplier = 0.35,
  int alphaValue = 190,
}) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  void cancelfunc() {
    Navigator.pop(context);
  }

  void dismissDialog() {
    Navigator.pop(context);
  }

  List<List<dynamic>> content = [
    [],
    [
      "Seems like you're having a hard time.",
      "I'll play the video again, just follow it.",
      Icons.sentiment_dissatisfied_sharp,
      Colors.red,
    ],
    [
      "GREAT WORK!",
      "Just keep doing that.",
      Icons.sentiment_very_satisfied,
      Colors.green,
    ],
    [
      "Good Job!",
      "(Follow the preview video to start the exercise)",
      Icons.check_circle_outline_sharp,
      mainColor,
    ],
    [
      "Next: ${nextExercise}",
      "(Follow the preview video to start the exercise)",
      Icons.check_circle_outline_sharp,
    ],
    [
      "Now collecting",
      "Positive datasets",
      Icons.check,
      Colors.green,
    ],
    [
      "Now collecting",
      "Negative datasets",
      Icons.close,
      Colors.red,
    ],
  ];

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      Timer(Duration(seconds: 3), dismissDialog);
      return AlertDialog(
        backgroundColor: content[notifState][3],
        // ----------------------------------------------------------------------------------------------------[STATE 1]

        content: Container(
          width: screenWidth * widthMultiplier,
          height: screenHeight * heightMultiplier,
          child: Padding(
            padding:
                EdgeInsets.all(16.0), // Adjust the padding values as needed
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  content[notifState][0],
                  style: TextStyle(
                    fontSize: 0.05 * screenWidth,
                    fontWeight: FontWeight.w800,
                    color: tertiaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                Icon(
                  content[notifState][2],
                  size: screenWidth * 0.35,
                  color: tertiaryColor,
                ),
                Text(
                  content[notifState][1],
                  style: TextStyle(
                    fontSize: 0.05 * screenWidth,
                    fontWeight: FontWeight.w800,
                    color: tertiaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
