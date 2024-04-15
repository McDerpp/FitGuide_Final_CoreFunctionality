// import 'dart:io';
// import 'dart:core';
// import 'package:path_provider/path_provider.dart';

// double progressT = 1.0;

// Future<void> translateCollectedDatatoTxt(
//   List<dynamic> dataCollected,
//   Function(double) updateProgress,
// ) async {
//   Directory externalDir = await getApplicationDocumentsDirectory();
//   String externalPath = externalDir!.path;
//   String filePath = '$externalPath/coordinatesCollected.txt';
//   File file = File(filePath);
//   file.writeAsStringSync('');
//   int progressCtr = 0;

//   for (List exerciseSet in dataCollected) {
//     progressCtr++;
//     progressT = (progressCtr / dataCollected.length);
//     updateProgress(progressT);

//     print("progressT---> $progressT");
//     await file.writeAsString('START\n', mode: FileMode.append);

//     for (List sequence in exerciseSet) {
//       for (double individualCoordinate in sequence) {
//         if (individualCoordinate.toString().length > 10) {
//           await file.writeAsString(
//               '${individualCoordinate.toString().substring(0, 10)}|',
//               mode: FileMode.append);
//         } else {
//           await file.writeAsString('${individualCoordinate.toString()}|',
//               mode: FileMode.append);
//         }
//       }
//       await file.writeAsString('\n', mode: FileMode.append);
//     }
//     await file.writeAsString('END\n', mode: FileMode.append);
//   }
// }
