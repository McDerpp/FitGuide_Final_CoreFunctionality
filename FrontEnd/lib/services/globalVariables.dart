import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// final StateProvider<int> bufferProvider = StateProvider((ref) => 2);

final StateProvider<String> IP_Adress_used =
    StateProvider((ref) => "192.168.1.18:8000");

final StateProvider<double> varianceFrameState = StateProvider((ref) => 0.0);
final counterProvider = StateProvider((ref) => 0);
final StateProvider<bool> collectState = StateProvider((ref) => false);

// based on width
final StateProvider<Map<String, double>> textSizeModifier =
    StateProvider((ref) => {
          "smallText": 0.03,
          "smallText2": 0.04,
          "mediumText": 0.05,
          "largeText": 0.07,
        });

final StateProvider<double> textAdaptModifierState =
    StateProvider((ref) => 0.0009);

final StateProvider<int> collectingCtrDelayState = StateProvider((ref) => 0);
final StateProvider<double> correctThresholdState =
    StateProvider((ref) => 0.75);

final StateProvider<int> currentDurationState = StateProvider((ref) => 3);
final StateProvider<int> _durationState = StateProvider((ref) => 10);

final StateProvider<Map<String, bool>> ignorePoseList = StateProvider((ref) => {
      "head": true,
      "leftUpperArm": true,
      "leftLowerArm": true,
      "rightUpperArm": true,
      "rightLowerArm": true,
      "leftUpperLeg": true,
      "leftLowerLeg": true,
      "rightLowerLeg": true,
      "rightUpperLeg": true,
    });

final StateProvider<Map<String, List<int>>> ignoreCoordinates =
    StateProvider((ref) => {
          "head": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
          "body": [],
          "leftArm": [11, 13, 25, 21, 17, 19],
          "rightArm": [12, 14, 16, 18, 20, 22],
          "leftLeg": [23, 25, 27, 29, 31],
          "rightLeg": [24, 26, 28, 32, 30],
        });

final StateProvider<List<bool>> ignoreCoordinatesList = StateProvider((ref) => [
      false,
      false,
      false,
      false,
      false,
      false,
    ]);

final StateProvider<List<int>> ignoreCoordinatesProvider =
    StateProvider((ref) => [8, 6, 4, 0, 1, 3, 7]);

final StateProvider<String> vidPath = StateProvider((ref) => "");

final StateProvider<String> exerciseNameProvider = StateProvider((ref) => "");
final StateProvider<String> descriptionProvider = StateProvider((ref) => "");
final StateProvider<String> additionalNotesProvider =
    StateProvider((ref) => "");
final StateProvider<String> partsAffectedProvider = StateProvider((ref) => "");
final StateProvider<int> exerciseNumSetProvider = StateProvider((ref) => 0);
final StateProvider<int> exerciseNumExecutionProvider =
    StateProvider((ref) => 0);
final StateProvider<int> inputNumProvider = StateProvider((ref) => 0);

final StateProvider<String> correctDataSetPath = StateProvider((ref) => "");
final StateProvider<String> incorrectDataSetPath = StateProvider((ref) => "");

final StateProvider<bool> showPreviewProvider = StateProvider((ref) => true);

final StateProvider<String> videoPreviewProvider = StateProvider((ref) => "");










// ref.watch(recording)
// ref.read(recording.notifier).state = value;


