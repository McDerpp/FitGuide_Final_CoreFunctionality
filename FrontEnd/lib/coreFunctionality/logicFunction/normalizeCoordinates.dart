import 'dart:core';

import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math' as math;

Map<String, dynamic> coordinatesRelativeBoxIsolate(
  Map<String, dynamic> inputs,
) {
  // BE AWARE OF THIS PARAMETER
  // This should match the training data pre process...currently its 4 decimal places
  int dataNormalizedDecimalPlace = 4;
  List<int> coordinatesIgnore = [];

  if (inputs.containsKey('token')) {
    var rootIsolateToken = inputs['token'];
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  }

  if (inputs.containsKey('coordinatesIgnore')) {
    coordinatesIgnore = inputs['coordinatesIgnore'];
  }
  Iterable<PoseLandmark> rawCoordiantes = inputs['inputImage'];

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
  int ctr = 0;
  int ctr2 = 0;

  int checkLikelihoodCtr = 0;
  bool allCoordinatesPresent = true;

  for (var pose in rawCoordiantes) {
    if (coordinatesIgnore.contains(ctr) == false) {
      print("pose.likelihood ---> ${pose.likelihood}");
      if (pose.likelihood <= .75) {
        checkLikelihoodCtr++;
      }

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
    ctr++;
  }

  for (var pose in rawCoordiantes) {
    if (coordinatesIgnore.contains(ctr2) == false) {
      valueXRange =
          (pose.x - minCoordinatesX) / (maxCoordinatesX - minCoordinatesX);
      valueYRange =
          (pose.y - minCoordinatesY) / (maxCoordinatesY - minCoordinatesY);
    } else {
      valueXRange = 0.0;
      valueYRange = 0.0;
    }
    // flattening it ahead of time for later processes later...

    translatedCoordinates.add(
        double.parse(valueXRange.toStringAsFixed(dataNormalizedDecimalPlace)));
    translatedCoordinates.add(
        double.parse(valueYRange.toStringAsFixed(dataNormalizedDecimalPlace)));

    ctr2++;
  }
  int ctr3 = 0;

  if (checkLikelihoodCtr >= 1) {
    allCoordinatesPresent = false;
  }
  print("checkLikelihoodCtr --> $checkLikelihoodCtr");

  Map<String, double> minMaxCoordinatesXY = {
    'maxCoor_Y': maxCoordinatesY,
    'maxCoor_X': maxCoordinatesX,
    'minCoor_Y': minCoordinatesY,
    'minCoor_X': minCoordinatesX,
  };

  Map<String, dynamic> dataNormalizationIsolateResults = {
    'translatedCoordinates': translatedCoordinates,
    'allCoordinatesPresent': allCoordinatesPresent,
    'minMaxCoordinatesXY': minMaxCoordinatesXY
  };

  return dataNormalizationIsolateResults;
}
