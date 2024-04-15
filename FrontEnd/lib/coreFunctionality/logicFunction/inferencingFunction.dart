import 'dart:core';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

import 'dart:core';
import 'dart:math';

List<double> paddingList = [];

void paddingInitialize() {
  for (int i = 0; i < 66; i++) {
    paddingList.add(0);
  }
}

List<List<double>> padding(List<List<double>> input, int requiredLength) {
  List<List<double>> result =
      List.from(input); // Create a copy of the input list
  List<double> paddingList =
      List.filled(66, 0); // Initialize paddingList with zeros

  while (result.length > requiredLength) {
    int maxRange = result.length;
    int randomNumber = Random().nextInt(maxRange);
    result.removeAt(randomNumber);
  }

  while (result.length < requiredLength) {
    result.add(
        List.from(paddingList)); // Create a new instance of the padding list
  }

  print("result of padding is --> ${result.length}");
  return result;
}

Future<void> modelInitialize(String modelPath) async {
  final head = await tfl.Interpreter.fromAsset(modelPath);
}

Future<bool> inferencingCoordinatesData(
    Map<String, dynamic> inputs, String modelPath, int inputNum) async {
  final head = await tfl.Interpreter.fromAsset(modelPath);
  tfl.Tensor inputDetails = head.getInputTensor(0);

  // print("head.getInputTensor(0) ---> ${head.getInputTensor(0)}");

  bool isCorrect = false;
  List<List<double>> tempArray = [];

  var output = List.generate(1, (index) => List<double>.filled(1, 0));

  List<List<double>> coordinates = inputs['coordinatesData'];
  coordinates = padding(coordinates, inputNum);

  var testtestset = head.getInputTensors();

  try {
    head.run(coordinates, output);
    print("output of inferencing( ---> $output");
  } catch (error) {
    print("error at inferencing ---> $error");
  }

  try {
    head.runInference(coordinates);
    print("runInference ---> $output");
  } catch (error) {}
// threshold
  if (output.elementAt(0).elementAt(0) >= .90) {
    return true;
  } else {
    return false;
  }
}
