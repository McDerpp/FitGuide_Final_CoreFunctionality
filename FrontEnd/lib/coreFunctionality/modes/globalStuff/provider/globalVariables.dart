import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// final StateProvider<int> bufferProvider = StateProvider((ref) => 2);

final StateProvider<String> IP_Adress_used =
    StateProvider((ref) => "192.168.1.18:8000");

// final StateProvider<int> averageThresholdBad = StateProvider((ref) => 5);
// final StateProvider<int> averageThresholdIdeal = StateProvider((ref) => 10);

// final StateProvider<int> minFrameThresholdBad = StateProvider((ref) => 5);
// final StateProvider<int> minFrameThresholdIdeal = StateProvider((ref) => 10);

// final StateProvider<int> maxFrameThresholdBad = StateProvider((ref) => 5);
// final StateProvider<int> maxFrameThresholdIdeal = StateProvider((ref) => 10);

// final StateProvider<double> averageFrameState = StateProvider((ref) => 0.0);
final StateProvider<double> varianceFrameState = StateProvider((ref) => 0.0);
// final StateProvider<int> minFrameState = StateProvider((ref) => 0);
// final StateProvider<int> maxFrameState = StateProvider((ref) => 0);

// final StateProvider<Color> averageColorState =
//     StateProvider((ref) => Colors.yellow);
// final StateProvider<Color> varianceColorState =
//     StateProvider((ref) => Colors.yellow);
// final StateProvider<Color> minFrameColorState =
//     StateProvider((ref) => Colors.yellow);
// final StateProvider<Color> maxFrameColorState =
//     StateProvider((ref) => Colors.yellow);

final counterProvider = StateProvider((ref) => 0);
// final StateProvider<double> luminanceProvider = StateProvider((ref) => 0.0);
final StateProvider<bool> collectState = StateProvider((ref) => false);
// final StateProvider<int> recording = StateProvider((ref) => 0);

// final StateProvider<Color> headColor =
//     StateProvider((ref) => ref.watch(secondaryColorState));
// final StateProvider<Color> leftArmColor =
//     StateProvider((ref) => ref.watch(secondaryColorState));
// final StateProvider<Color> leftLegColor =
//     StateProvider((ref) => ref.watch(secondaryColorState));
// final StateProvider<Color> rightLegColor =
//     StateProvider((ref) => ref.watch(secondaryColorState));
// final StateProvider<Color> bodyColor =
//     StateProvider((ref) => ref.watch(secondaryColorState));

// final StateProvider<Color> mainColorState =
//     StateProvider((ref) => Color.fromARGB(255, 27, 26, 26));
// final StateProvider<Color> secondaryColorState =
//     StateProvider((ref) => Color.fromARGB(255, 207, 84, 84));
// final StateProvider<Color> tertiaryColorState =
//     StateProvider((ref) => Color.fromARGB(255, 255, 255, 255));

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

final StateProvider<List<String>> ignoreCoordinatesInitialized =
    StateProvider((ref) => []);

// final StateProvider<Map<String, Map<String, Color>>> ColorSet =
//     StateProvider((ref) => {
//           "ColorSet1": {
//             "mainColor": ref.watch(mainColorState),
//             "secondaryColor": ref.watch(secondaryColorState),
//             "tertiaryColor": ref.watch(tertiaryColorState),
//           },
//           "ColorSet2": {
//             "mainColor": ref.watch(mainColorState),
//             "secondaryColor": ref.watch(tertiaryColorState),
//             "tertiaryColor": ref.watch(secondaryColorState),
//           },
//         });

// final StateProvider<Map<String, Color>> headColor =
//     StateProvider((ref) => ref.watch(ColorSet)["ColorSet1"]!);
// final StateProvider<Map<String, Color>> leftArmColor =
//     StateProvider((ref) => ref.watch(ColorSet)["ColorSet1"]!);
// final StateProvider<Map<String, Color>> rightArmColor =
//     StateProvider((ref) => ref.watch(ColorSet)["ColorSet1"]!);
// final StateProvider<Map<String, Color>> leftLegColor =
//     StateProvider((ref) => ref.watch(ColorSet)["ColorSet1"]!);
// final StateProvider<Map<String, Color>> rightLegColor =
//     StateProvider((ref) => ref.watch(ColorSet)["ColorSet1"]!);
// final StateProvider<Map<String, Color>> bodyColor =
//     StateProvider((ref) => ref.watch(ColorSet)["ColorSet1"]!);

// final StateProvider<bool> headBoolState = StateProvider((ref) => true);
// final StateProvider<bool> leftArmBoolState = StateProvider((ref) => true);
// final StateProvider<bool> rightArmBoolState = StateProvider((ref) => true);
// final StateProvider<bool> leftLegBoolState = StateProvider((ref) => true);
// final StateProvider<bool> rightLegBoolState = StateProvider((ref) => true);
// final StateProvider<bool> bodyBoolState = StateProvider((ref) => true);

// final StateProvider<List<int>> head =
//     StateProvider((ref) => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
// final StateProvider<List<int>> body = StateProvider((ref) => []);
// final StateProvider<List<int>> leftArm =
//     StateProvider((ref) => [11, 13, 25, 21, 17, 19]);
// final StateProvider<List<int>> rightArm =
//     StateProvider((ref) => [12, 14, 16, 18, 20, 22]);
// final StateProvider<List<int>> leftLeg =
//     StateProvider((ref) => [23, 25, 27, 29, 31]);
// final StateProvider<List<int>> rightLeg =
//     StateProvider((ref) => [24, 26, 28, 32, 30]);

final StateProvider<String> vidPath = StateProvider((ref) => "");

// final StateProvider<String> sessionKeyProvider = StateProvider((ref) => "");

final StateProvider<String> exerciseNameProvider = StateProvider((ref) => "");
final StateProvider<String> descriptionProvider = StateProvider((ref) => "");
final StateProvider<String> additionalNotesProvider =
    StateProvider((ref) => "");
final StateProvider<String> partsAffectedProvider = StateProvider((ref) => "");
final StateProvider<int> exerciseNumSetProvider = StateProvider((ref) => 0);
final StateProvider<int> exerciseNumExecutionProvider =
    StateProvider((ref) => 0);
final StateProvider<int> inputNumProvider = StateProvider((ref) => 0);

final StateProvider<String> filePathProvider = StateProvider((ref) => "");








  










// ref.watch(recording)
// ref.read(recording.notifier).state = value;


