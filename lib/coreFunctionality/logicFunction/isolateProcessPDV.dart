import 'dart:io';
import 'dart:core';

import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

late List<double> paddingList;
late tfl.Interpreter head;
double progressT = 1.0;

void paddingInitialize() {
  for (int i = 0; i < 66; i++) {
    paddingList.add(0);
  }
}

Future<void> modelInitialize(String modelPath) async {
  final head = await tfl.Interpreter.fromAsset(modelPath);
}

List<List<double>> padding(List<List<double>> input, int requiredlength) {
  List<List<double>> result = [];
  if (paddingList.length != 66) {
    for (int i = 0; i < 66; i++) {
      paddingList.add(0);
    }
  }

  for (int i = 0; i < requiredlength - input.length; i++) {
    result.add(paddingList);
  }

  return result;
}

Future<bool> inferencingCoordinatesData(Map<String, dynamic> inputs) async {
  print("entering inferencing");
  bool isCorrect = false;
  List<List<double>> tempArray = [];

  var output = List.generate(1, (index) => List<double>.filled(1, 0));

  List<List<double>> coordinates = inputs['coordinatesData'];

  var testtestset = head.getInputTensors();

  print("tensor needed ----> $testtestset ");

  for (int i = 0; i < 23; i++) {
    tempArray.add(coordinates.elementAt(0));

    try {
      head.run(tempArray, output);

      print("output of inferencing( ---> $output");
    } catch (error) {
      print("head.run(coordinates, output); error! -> $error");
    }

    try {
      head.runInference(tempArray);
      print("runInference ---> $output");
    } catch (error) {
      print("head.runInference(coordinates); error! -> $error");
    }
  }

  return isCorrect;
}

List<double> coordinatesRelativeBoxIsolate(Map<String, dynamic> inputs) {
  var rootIsolateToken = inputs['token'];
  Iterable<PoseLandmark> rawCoordiantes = inputs['inputImage'];
  // print("coordinatesRelativeBox ---> ${rawCoordiantes.first.x}");

  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

  List<double> translatedCoordinates = [];
  double allowance = .03;

  double minCoordinatesX = rawCoordiantes.first.x;
  double minCoordinatesY = rawCoordiantes.first.y;

  double maxCoordinatesX = rawCoordiantes.first.x;
  double maxCoordinatesY = rawCoordiantes.first.y;

  var valueXRange;
  var valueYRange;

  var rawX;
  var rawY;

  for (var pose in rawCoordiantes) {
    if (minCoordinatesX >= pose.x) {
      minCoordinatesX = pose.x;
    }
    if (minCoordinatesY >= pose.y) {
      minCoordinatesY = pose.y;
    }

    if (maxCoordinatesX <= pose.x) {
      maxCoordinatesX = pose.x;
    }
    if (maxCoordinatesY <= pose.y) {
      maxCoordinatesY = pose.y;
    }
  }

  for (var pose in rawCoordiantes) {
    valueXRange =
        (pose.x - minCoordinatesX) / (maxCoordinatesX - minCoordinatesX);
    valueYRange =
        (pose.y - minCoordinatesY) / (maxCoordinatesY - minCoordinatesY);

    // flattening it ahead of time for later processes later...
    translatedCoordinates.add(valueXRange);
    translatedCoordinates.add(valueYRange);
  }

  return translatedCoordinates;
}

bool checkMovement(Map<String, dynamic> input) {
  var prevCoordinates = input['prevCoordinates'];
  var currentCoordinates = input['currentCoordinates'];
  var token = input['token'];

  bool noMovement = false;
  double changeRange = 0.07;
  int noMovementCtr = 0;

  for (int ctr = 0; ctr < prevCoordinates.length; ctr++) {
    if (prevCoordinates.elementAt(ctr) - changeRange <=
            currentCoordinates.elementAt(ctr) &&
        prevCoordinates.elementAt(ctr) + changeRange >=
            currentCoordinates.elementAt(ctr)) {
      noMovementCtr++;
      // print("checking(not moving) - $ctr");
    } else {
      // print(
      //     "===========================[YOU MOOOOOVED!]======================================");
      return false;
    }
  }
  // print(
  //     "======================================================================================");

  // print("noMovementCtr --> $noMovementCtr");
  if (noMovementCtr >= 65) {
    return true;
  } else {
    return false;
  }
}

Future<void> translateCollectedDatatoTxt(
  List<dynamic> dataCollected,
  Function(double) updateProgress,
) async {
  Directory externalDir = await getApplicationDocumentsDirectory();
  String externalPath = externalDir!.path;
  String filePath = '$externalPath/coordinatesCollected.txt';
  File file = File(filePath);
  file.writeAsStringSync('');
  int progressCtr = 0;

  for (List exerciseSet in dataCollected) {
    progressCtr++;
    progressT = (progressCtr / dataCollected.length);
    updateProgress(progressT);

    print("progressT---> $progressT");
    await file.writeAsString('START\n', mode: FileMode.append);
    print("len_per_set ---> ${exerciseSet.length}");
    print(
        "=========================================================================");

    for (List sequence in exerciseSet) {
      print("test1");
      print("seq_per_set ---> ${exerciseSet.length}");
      print("->> $sequence ");

      for (double individualCoordinate in sequence) {
        print("individualCoordinate");
        print(
            "individualCoordinate(len)--> ${individualCoordinate.toString().length}");

        if (individualCoordinate.toString().length > 10) {
          await file.writeAsString(
              '${individualCoordinate.toString().substring(0, 10)}|',
              mode: FileMode.append);
        } else {
          await file.writeAsString('${individualCoordinate.toString()}|',
              mode: FileMode.append);
        }
      }
      await file.writeAsString('\n', mode: FileMode.append);
    }
    await file.writeAsString('END\n', mode: FileMode.append);
    print(
        "=========================================================================");
  }
}
