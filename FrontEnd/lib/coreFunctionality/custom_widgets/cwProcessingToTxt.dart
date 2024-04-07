import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class processingToTxt extends StatefulWidget {
  // final List<List<List<double>>> data;

  const processingToTxt({
    super.key,
    // required this.data,
  });

  @override
  State<processingToTxt> createState() => _processingToTxtState();
}

class _processingToTxtState extends State<processingToTxt> {
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

  @override
  Widget build(BuildContext context) {
    print("in processing...");

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Downloading...'),
        SizedBox(height: 20),
        Container(
          width: 200, // Specify a fixed width
          child: LinearProgressIndicator(
            minHeight: 20,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            value: 0.5,
          ),
        ),
      ],
    );
  }
}
