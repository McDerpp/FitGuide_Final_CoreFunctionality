import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final StateProvider<String> sessionKeyProvider = StateProvider((ref) => "");

final StateProvider<int> bufferProvider = StateProvider((ref) => 2);

final StateProvider<String> IP_Adress_used =
    StateProvider((ref) => "192.168.1.18:8000");

final StateProvider<Color> maxFrameColorProvider =
    StateProvider((ref) => Colors.red);
final StateProvider<Color> minFrameColorProvider =
    StateProvider((ref) => Colors.red);

final StateProvider<Color> averageColorProvider =
    StateProvider((ref) => Colors.red);

final StateProvider<int> averageThresholdBad = StateProvider((ref) => 5);
final StateProvider<int> averageThresholdIdeal = StateProvider((ref) => 10);

final StateProvider<int> minFrameThresholdBad = StateProvider((ref) => 5);
final StateProvider<int> minFrameThresholdIdeal = StateProvider((ref) => 10);

final StateProvider<int> maxFrameThresholdBad = StateProvider((ref) => 5);
final StateProvider<int> maxFrameThresholdIdeal = StateProvider((ref) => 10);

// Positive dataset quality check
final StateProvider<double> averageFrameState = StateProvider((ref) => 0.0);
final StateProvider<int> maxFrameState = StateProvider((ref) => 0);
final StateProvider<int> minFrameState = StateProvider((ref) => 0);
final StateProvider<int> numExec = StateProvider((ref) => 0);
final StateProvider<int> execTotalFrames = StateProvider((ref) => 0);

// negative dataset quality check
final StateProvider<double> averageFrameNegativeState =
    StateProvider((ref) => 0.0);
final StateProvider<int> maxFrameNegativeState = StateProvider((ref) => 0);
final StateProvider<int> minFrameNegativeState = StateProvider((ref) => 0);
final StateProvider<int> numExecNegative = StateProvider((ref) => 0);
final StateProvider<int> execTotalFramesNegative = StateProvider((ref) => 0);

final StateProvider<List<String>> ignoreCoordinatesInitialized =
    StateProvider((ref) => []);

final StateProvider<Color> averageColorState =
    StateProvider((ref) => Colors.yellow);
final StateProvider<Color> varianceColorState =
    StateProvider((ref) => Colors.yellow);
final StateProvider<Color> minFrameColorState =
    StateProvider((ref) => Colors.yellow);
final StateProvider<Color> maxFrameColorState =
    StateProvider((ref) => Colors.yellow);

final StateProvider<Color> mainColorState =
    StateProvider((ref) => Color.fromARGB(255, 27, 26, 26));
final StateProvider<Color> secondaryColorState =
    StateProvider((ref) => Color.fromARGB(255, 207, 84, 84));
final StateProvider<Color> tertiaryColorState =
    StateProvider((ref) => Color.fromARGB(255, 255, 255, 255));

final counterProvider = StateProvider((ref) => 0);
final StateProvider<double> luminanceProvider = StateProvider((ref) => 0.0);
final StateProvider<bool> collectState = StateProvider((ref) => false);
final StateProvider<int> recording = StateProvider((ref) => 0);

final StateProvider<Map<String, Color>> headColor =
    StateProvider((ref) => ref.watch(ColorSet)["ColorSet1"]!);
final StateProvider<Map<String, Color>> leftArmColor =
    StateProvider((ref) => ref.watch(ColorSet)["ColorSet1"]!);
final StateProvider<Map<String, Color>> rightArmColor =
    StateProvider((ref) => ref.watch(ColorSet)["ColorSet1"]!);
final StateProvider<Map<String, Color>> leftLegColor =
    StateProvider((ref) => ref.watch(ColorSet)["ColorSet1"]!);
final StateProvider<Map<String, Color>> rightLegColor =
    StateProvider((ref) => ref.watch(ColorSet)["ColorSet1"]!);
final StateProvider<Map<String, Color>> bodyColor =
    StateProvider((ref) => ref.watch(ColorSet)["ColorSet1"]!);

final StateProvider<bool> headBoolState = StateProvider((ref) => true);
final StateProvider<bool> leftArmBoolState = StateProvider((ref) => true);
final StateProvider<bool> rightArmBoolState = StateProvider((ref) => true);
final StateProvider<bool> leftLegBoolState = StateProvider((ref) => true);
final StateProvider<bool> rightLegBoolState = StateProvider((ref) => true);
final StateProvider<bool> bodyBoolState = StateProvider((ref) => true);

final StateProvider<List<int>> head =
    StateProvider((ref) => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
final StateProvider<List<int>> body = StateProvider((ref) => []);
final StateProvider<List<int>> leftArm =
    StateProvider((ref) => [11, 13, 25, 21, 17, 19]);
final StateProvider<List<int>> rightArm =
    StateProvider((ref) => [12, 14, 16, 18, 20, 22]);
final StateProvider<List<int>> leftLeg =
    StateProvider((ref) => [23, 25, 27, 29, 31]);
final StateProvider<List<int>> rightLeg =
    StateProvider((ref) => [24, 26, 28, 32, 30]);

final StateProvider<Map<String, Map<String, Color>>> ColorSet =
    StateProvider((ref) => {
          "ColorSet1": {
            "mainColor": ref.watch(mainColorState),
            "secondaryColor": ref.watch(secondaryColorState),
            "tertiaryColor": ref.watch(tertiaryColorState),
          },
          "ColorSet2": {
            "mainColor": ref.watch(mainColorState),
            "secondaryColor": ref.watch(tertiaryColorState),
            "tertiaryColor": ref.watch(secondaryColorState),
          },
        });

final StateProvider<bool> isTimerStart = StateProvider((ref) => false);
final StateProvider<bool> isTimerReset = StateProvider((ref) => false);
final StateProvider<bool> isTimerRestart = StateProvider((ref) => false);
final StateProvider<int> timerDuration = StateProvider((ref) => 10);
final StateProvider<String?> timerCurrentTime = StateProvider((ref) => "");

final StateProvider<List<Map<String, dynamic>>?> queueNormalizeData =
    StateProvider((ref) => []);

// ==========================================================================

final StateProvider<coordinatesData> coordinatesDataProvider =
    StateProvider((ref) => coordinatesData());

class coordinatesData extends StateNotifier<List<List<List<double>>>> {
  coordinatesData() : super([]);

  void addItem(List<List<double>> item) {
    state = [...state, item];
  }

  void removeItem(List<List<double>> item) {
    state = [...state]..remove(item);
  }

  void removeLastItem() {
    if (state.isNotEmpty) {
      state = List.from(state)..removeLast();
    }
  }

  void clearItems() {
    state = [];
  }
}

final StateProvider<incorrectCoordinates> incorrectCoordinatesDataProvider =
    StateProvider((ref) => incorrectCoordinates());

class incorrectCoordinates extends StateNotifier<List<List<List<double>>>> {
  incorrectCoordinates() : super([]);

  void addItem(List<List<double>> item) {
    state = [...state, item];
  }

  void removeItem(List<List<double>> item) {
    state = [...state]..remove(item);
  }

  void removeLastItem() {
    if (state.isNotEmpty) {
      state = List.from(state)..removeLast();
    }
  }

  void clearItems() {
    state = [];
  }
}

final StateProvider<bool> isPerforming = StateProvider((ref) => false);
final StateProvider<bool> isRetraining = StateProvider((ref) => false);


final StateProvider<bool> isAllCoordinatesPresent =
    StateProvider((ref) => false);

final StateProvider<bool> isCollectingCorrect = StateProvider((ref) => true);

final StateProvider<String> exerciseID = StateProvider((ref) => "");








          //  final coordinates = context.read(coordinatesDataProvider);
          //   coordinates.addItem("New Coordinate");
// ==========================================================================
