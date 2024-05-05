// import 'dart:core';
// import 'package:flutter/services.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';

// Map<String, dynamic> coordinatesRelativeBoxIsolate(
//   Map<String, dynamic> inputs,
// ) {
// // Specified decimal place for normalization
//   int dataNormalizedDecimalPlace = 4;
//   List<int> coordinatesIgnore = [];

// // Dart component: Isolate token for running on different threads for heavy processes.
//   if (inputs.containsKey('token')) {
//     var rootIsolateToken = inputs['token'];
//     BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
//   }
// // Checking if token exists
//   if (inputs.containsKey('coordinatesIgnore')) {
//     coordinatesIgnore = inputs['coordinatesIgnore'];
//   }

//   Iterable<PoseLandmark> rawCoordiantes = inputs['inputImage'];

//   List<double> translatedCoordinates = [];

// // Initializing the minimum and maximum of X and Y coordinates.
//   double minCoordinatesX = rawCoordiantes.first.x;
//   double minCoordinatesY = rawCoordiantes.first.y;

//   double maxCoordinatesX = rawCoordiantes.first.x;
//   double maxCoordinatesY = rawCoordiantes.first.y;

//   double valueXRange;
//   double valueYRange;

//   int ctr = 0;
//   int ctr2 = 0;

//   int checkLikelihoodCtr = 0;
//   bool allCoordinatesPresent = true;

// // Checking if all coordinates are present
// // Note: this is to require the researcher to have all the coordinates present when
// // collecting data, however it certain parts can be disabled and ignored in checking.
//   for (var pose in rawCoordiantes) {
//     if (coordinatesIgnore.contains(ctr) == false) {
//       if (pose.likelihood <= .75) {
//         checkLikelihoodCtr++;
//       }
//       if (minCoordinatesX >= pose.x) {
//         minCoordinatesX = pose.x;
//       }
//       if (minCoordinatesY >= pose.y) {
//         minCoordinatesY = pose.y;
//       }

//       if (maxCoordinatesX <= pose.x) {
//         maxCoordinatesX = pose.x;
//       }
//       if (maxCoordinatesY <= pose.y) {
//         maxCoordinatesY = pose.y;
//       }
//     }
//     ctr++;
//   }

//   if (checkLikelihoodCtr >= 1) {
//     allCoordinatesPresent = false;
//   }

// // Normalizing the raw pixel data into scale of 0-1.
//   for (var pose in rawCoordiantes) {
//     // Ignoring certain coordinates from being collected.
//     if (coordinatesIgnore.contains(ctr2) == false) {
//       // If coordinates is not ignored, it is converted.
//       valueXRange =
//           (pose.x - minCoordinatesX) / (maxCoordinatesX - minCoordinatesX);
//       valueYRange =
//           (pose.y - minCoordinatesY) / (maxCoordinatesY - minCoordinatesY);
//     } else {
//       // if coordinates is ignored then give a 0.
//       valueXRange = 0.0;
//       valueYRange = 0.0;
//     }

//     print("coordinates ignore ctr2[ $ctr] -->  $valueXRange - $valueYRange");
// // Limiting the decimal places, this is to simplify the data.
//     translatedCoordinates.add(
//         double.parse(valueXRange.toStringAsFixed(dataNormalizedDecimalPlace)));
//     translatedCoordinates.add(
//         double.parse(valueYRange.toStringAsFixed(dataNormalizedDecimalPlace)));
//     ctr2++;
//   }
//   ctr2 = 0;
// // data preparation for returning.
//   Map<String, dynamic> dataNormalizationIsolateResults = {
//     'translatedCoordinates': translatedCoordinates,
//     'allCoordinatesPresent': allCoordinatesPresent,
//   };

//   return dataNormalizationIsolateResults;
// }

import 'dart:core';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

Map<String, dynamic> coordinatesRelativeBoxIsolate(
  Map<String, dynamic> inputs,
) {
// Specified decimal place for normalization
  int dataNormalizedDecimalPlace = 4;
  List<int> coordinatesIgnore = [];

// Dart component: Isolate token for running on different threads for heavy processes.
  if (inputs.containsKey('token')) {
    var rootIsolateToken = inputs['token'];
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  }
// Checking if token exists
  if (inputs.containsKey('coordinatesIgnore')) {
    coordinatesIgnore = inputs['coordinatesIgnore'];
  }

  Iterable<PoseLandmark> rawCoordiantes = inputs['inputImage'];

  List<double> translatedCoordinates = [];

// Initializing the minimum and maximum of X and Y coordinates.
  double minCoordinatesX = rawCoordiantes.first.x;
  double minCoordinatesY = rawCoordiantes.first.y;

  double maxCoordinatesX = rawCoordiantes.first.x;
  double maxCoordinatesY = rawCoordiantes.first.y;

  double valueXRange;
  double valueYRange;

  int ctr = 0;
  int ctr2 = 0;

  int checkLikelihoodCtr = 0;
  bool allCoordinatesPresent = true;

// Checking if all coordinates are present
// Note: this is to require the researcher to have all the coordinates present when
// collecting data, however it certain parts can be disabled and ignored in checking.
  for (var pose in rawCoordiantes) {
    if (coordinatesIgnore.contains(ctr) == true) {
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

  print(
      "minMaxXY ---> minX:${minCoordinatesX} , minY:${minCoordinatesY} , maxX:${maxCoordinatesX} , maxY:${maxCoordinatesY} ");

  if (checkLikelihoodCtr >= 1) {
    allCoordinatesPresent = false;
  }

// Normalizing the raw pixel data into scale of 0-1.
  for (var pose in rawCoordiantes) {
    // Ignoring certain coordinates from being collected.
    if (coordinatesIgnore.contains(ctr2) == true) {
      // If coordinates is not ignored, it is converted.
      valueXRange =
          (pose.x - minCoordinatesX) / (maxCoordinatesX - minCoordinatesX);
      valueYRange =
          (pose.y - minCoordinatesY) / (maxCoordinatesY - minCoordinatesY);
    } else {
      // if coordinates is ignored then give a 0.
      valueXRange = 0.0;
      valueYRange = 0.0;
    }

    print("coordinates ignore ctr2[ $ctr2] -->  $valueXRange - $valueYRange");
// Limiting the decimal places, this is to simplify the data.
    translatedCoordinates.add(
        double.parse(valueXRange.toStringAsFixed(dataNormalizedDecimalPlace)));
    translatedCoordinates.add(
        double.parse(valueYRange.toStringAsFixed(dataNormalizedDecimalPlace)));
    ctr2++;
  }
// data preparation for returning.
  Map<String, dynamic> dataNormalizationIsolateResults = {
    'translatedCoordinates': translatedCoordinates,
    'allCoordinatesPresent': allCoordinatesPresent,
    'minCoordinatesX': minCoordinatesX,
    'maxCoordinatesX': maxCoordinatesX,
    'minCoordinatesY': minCoordinatesY,
    'maxCoordinatesY': maxCoordinatesY,
  };

  return dataNormalizationIsolateResults;
}
