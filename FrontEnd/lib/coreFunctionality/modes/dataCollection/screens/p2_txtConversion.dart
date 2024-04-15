import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/coreFunctionality/custom_widgets/customButton.dart';
import 'package:frontend/coreFunctionality/modes/dataCollection/screens/p3_videoRecord.dart';
import 'package:frontend/coreFunctionality/modes/globalStuff/provider/globalVariables.dart';
import 'package:frontend/coreFunctionality/modes/dataCollection/screens/p4_exerciseDetail.dart';
import 'package:frontend/services/api.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;

import '../../../../services/provider_collection.dart';

class collectionDataP1 extends ConsumerStatefulWidget {
  final List<List<List<double>>> correctDataset;
  final List<List<List<double>>> incorretcDataset;

  const collectionDataP1({
    super.key,
    required this.correctDataset,
    required this.incorretcDataset,
  });

  @override
  ConsumerState<collectionDataP1> createState() => _collectionDataP1State();
}

class _collectionDataP1State extends ConsumerState<collectionDataP1> {
  late int progress;
  // late int fullProgress = widget.correctDataset['coordinates'];
  double progressT = 0;
  int seriousFactsRandIndex = 0;
  var random = Random();

  List<String> seriousFacts = [
    "Did you know? Regular exercise boosts mood and energy levels!",
    "Exercise is not just about physical health, it's also great for mental well-being.",
    "A balanced diet and regular exercise are key to a healthy lifestyle.",
    "Stay hydrated! Drinking water before, during, and after exercise is essential.",
    "Set goals, stay consistent, and celebrate your progress on your fitness journey!",
    "Remember, every step you take towards better health counts, no matter how small.",
    "Exercise doesn't have to be intense to be beneficial. Find activities you enjoy and make them a part of your routine.",
    "Quality sleep is just as important as exercise and nutrition for overall health.",
    "Variety is the spice of life! Mix up your workouts to keep things interesting and challenge your body.",
    "Listen to your body. Rest when needed and don't push yourself beyond your limits.",
    "Running late counts as cardio, right? Asking for a friend.",
    "Sweat is just fat crying because you're about to burn it off!",
    "Remember, the only bad workout is the one that didn't happen. So get moving and make your couch jealous!",
    "Want to be as strong as Saitama? Just do 100 push-ups, 100 sit-ups, 100 squats, and run 10 kilometers every single day! No AC!",
    "Saitama didn't become the strongest hero overnight. It took 100 push-ups, sit-ups, squats, and a lot of bananas!",
    "ARE YOU KIRIN ME?!",
    "???",
    "AI: WHAT KIND OF EXERCISE IS THIS?!",
    "AI: YOU CALL THIS AN EXERCISE?!",
    "AI: ARE TRYING TO KILL SOMEONE WITH THIS EXERCISE OF YOURS",
    "AI: 01101011 01100001 01110000 01101111 01111001 01100001 00100000 01110100 01101000 01100101 01110011 01101001 01110011 00100000 01101111 01101001",
  ];

  Future<void> translateCollectedDatatoTxt(
      List<dynamic> dataCollected, bool isCorrectDataset) async {
    Directory externalDir = await getApplicationDocumentsDirectory();
    String externalPath = externalDir!.path;

    String filePath = isCorrectDataset == true
        ? '$externalPath/coordinatesCollected.txt'
        : '$externalPath/coordinatesCollected(incorrect).txt';
    File file = File(filePath);
    file.writeAsStringSync('');
    int progressCtr = 0;

    for (List exerciseSet in dataCollected) {
      progressCtr++;
      try {
        setState(() {
          progressT = (progressCtr / dataCollected.length);

          if (double.parse(progressT.toStringAsFixed(2)) % .10 == 0) {
            seriousFactsRandIndex = random.nextInt(seriousFacts.length);
          }
        });
      } catch (e) {
        break;
      }
      print("progressT---> $progressT");
      await file.writeAsString('START\n', mode: FileMode.append);

      for (List sequence in exerciseSet) {
        for (double individualCoordinate in sequence) {
          if (individualCoordinate.toString().length > 10) {
            // ---------------------------------------------------------------------------[DECIMAL PLACES NUMBER...ADJUST ACCORDINGLY]

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
    }
    isCorrectDataset == true
        ? ref.read(correctDataSetPath.notifier).state = filePath
        : ref.read(incorrectDataSetPath.notifier).state = filePath;

    // getCSRFToken();
    // getSessionKey().then((value) {
    //   ref.watch(sessionKeyProvider.notifier).state = value;
    // });

    collectDatasetInfo(ref);
  }

  @override
  void initState() {
    super.initState();
    translateCollectedDatatoTxt(widget.correctDataset, true);
    translateCollectedDatatoTxt(widget.incorretcDataset, false);
  }

  @override
  void dispose() {
    print('Process stopped');
    super.dispose();
  }

  Future<void> testLoading() async {
    for (int ctr = 0; ctr < 100; ctr++) {
      print("this is progress --->  $progress");
      setState(() {
        progress = ctr;
      });
      await Future.delayed(
          Duration(milliseconds: 100)); // Add a delay of 100 milliseconds
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    Map<String, double> textSizeModif = ref.watch(textSizeModifier);
    Color mainColor = ref.watch(mainColorState);
    Color secondaryColor = ref.watch(secondaryColorState);
    Color tertiaryColor = ref.watch(tertiaryColorState);
    late Map<String, Color> colorSet;
    colorSet = {
      "mainColor": mainColor,
      "secondaryColor": secondaryColor,
      "tertiaryColor": tertiaryColor,
    };

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: screenHeight,
            width: screenWidth,
            color: ref.watch(mainColorState),
          ),
          Positioned(
            bottom: screenHeight *
                0.05, // Adjust as needed, considering padding/margin
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Container(
                    width: screenWidth * 0.75,
                    child: Text(
                      '${seriousFacts[seriousFactsRandIndex]}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: textSizeModif["smallText2"]! * screenWidth,
                          color: ref.watch(tertiaryColorState)),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                progressT != 1
                    ? Container(
                        width: screenWidth * 0.85,
                        height: screenHeight * 0.05, // Specify a fixed width
                        child: LinearProgressIndicator(
                          minHeight: 20,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                              ref.watch(secondaryColorState)),
                          value: progressT,
                        ))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildElevatedButton(
                            context: context,
                            label: "Next",
                            colorSet: colorSet,
                            textSizeModifierIndividual:
                                textSizeModif['smallText2']!,
                            func: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const collectionDataP2(),
                                  // const collectionDataP2(),
                                ),
                              );
                            },
                          ),
                        ],
                      )
              ],
            ),
          )
        ],
      ),
    );
  }
}
