// this one is being used
import 'dart:io';
import 'dart:core';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<void> translateCollectedDatatoTxt2(
  Map<String, dynamic> inputs,
) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(inputs['token']);
  Directory externalDir = await getApplicationDocumentsDirectory();
  String externalPath = externalDir!.path;
  String filePath = '$externalPath/coordinatesCollected.txt';
  File file = File(filePath);
  file.writeAsStringSync('');
  int progressCtr = 0;

  for (List exerciseSet in inputs['coordinates']) {
    progressCtr++;
    print("progressCtr --> $progressCtr");
    await file.writeAsString('START\n', mode: FileMode.append);

    for (List sequence in exerciseSet) {
      for (double individualCoordinate in sequence) {
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
      // }
      await file.writeAsString('END\n', mode: FileMode.append);
      // print(
      // "=========================================================================");
    }
  }
}
