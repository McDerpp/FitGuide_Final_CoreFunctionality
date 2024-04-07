import 'dart:core';
import 'package:frontend/coreFunctionality/modes/dataCollection/process/isolates/padding.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

Future<void> modelInitialize(String modelPath) async {
  final head = await tfl.Interpreter.fromAsset(modelPath);
}

Future<bool> inferencingCoordinatesData(
    Map<String, dynamic> inputs, String modelPath) async {
  final head = await tfl.Interpreter.fromAsset(modelPath);
  tfl.Tensor inputDetails = head.getInputTensor(0);

  // print("head.getInputTensor(0) ---> ${head.getInputTensor(0)}");

  bool isCorrect = false;
  List<List<double>> tempArray = [];

  var output = List.generate(1, (index) => List<double>.filled(1, 0));

  List<List<double>> coordinates = inputs['coordinatesData'];
  coordinates = padding(coordinates, 8);

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
