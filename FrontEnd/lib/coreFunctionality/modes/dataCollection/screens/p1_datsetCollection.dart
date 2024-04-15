import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:circular_countdown_timer/countdown_text_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/coreFunctionality/custom_widgets/customButton.dart';

import 'dart:core';

import 'package:frontend/coreFunctionality/custom_widgets/cwIgnorePose.dart';
import 'package:frontend/coreFunctionality/custom_widgets/errorWidget.dart';
import 'package:frontend/coreFunctionality/modes/dataCollection/screens/p6_reviewDataset.dart';
import 'package:frontend/coreFunctionality/modes/globalStuff/provider/globalVariables.dart';
import 'package:frontend/services/provider_collection.dart';
import '../../../custom_widgets/executionAnalysis.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../mainUISettings.dart';

class collectionDataTraining extends ConsumerStatefulWidget {
  // final Widget exerciseList;

  const collectionDataTraining({super.key});

  @override
  ConsumerState<collectionDataTraining> createState() =>
      _collectionDataTrainingState();
}

class _collectionDataTrainingState
    extends ConsumerState<collectionDataTraining> {
  double requiredDataNum = 50;

  GlobalKey tutorial_deletePrev = GlobalKey();
  GlobalKey tutorial_pause = GlobalKey();
  GlobalKey tutorial_deleteAll = GlobalKey();
  GlobalKey tutorial_ignorePose = GlobalKey();

  GlobalKey tutorial_allMetrics = GlobalKey();
  GlobalKey tutorial_avgFrame = GlobalKey();
  GlobalKey tutorial_variance = GlobalKey();
  GlobalKey tutorial_avgFrame2 = GlobalKey();
  GlobalKey tutorial_variance2 = GlobalKey();

  GlobalKey tutorial_lightingError = GlobalKey();
  GlobalKey tutorial_poseError = GlobalKey();

  GlobalKey tutorial_progressBar = GlobalKey();
  GlobalKey tutorial_submit = GlobalKey();

  Color sequenceColor = Colors.yellow;
  Color averageColor = Colors.yellow;
  Color varianceColor = Colors.yellow;
  Color minFrameColor = Colors.yellow;
  Color maxFrameColor = Colors.yellow;
  late Map<String, double> textSizeModifierSet;

  double avgFrames = 0.0;
  int minFrame = 0;
  int maxFrame = 0;
  String resultAvgFrames = '';
  int execTotalFrames = 0;

  late Map<String, Color> colorSet;

  void undoExecution(int undoTimes) {
    int temp = 0;
    int tempexecTotalFrames = execTotalFrames;
    for (int ctr = 0; ctr < undoTimes; ctr++) {
      if (ref.read(coordinatesDataProvider).state.isNotEmpty) {
        tempexecTotalFrames = (tempexecTotalFrames -
                ref.read(coordinatesDataProvider).state.last.length)
            .toInt();
        ref.read(coordinatesDataProvider).state.removeLast();
        ref.read(numExec.notifier).state--;
      }
    }

    setState(() {
      // nowPerforming = false;
      ref.watch(isPerforming.notifier).state = false;

      execTotalFrames = tempexecTotalFrames;
      avgFrames = execTotalFrames / ref.watch(numExec);
      ;
      resultAvgFrames = avgFrames.toStringAsFixed(2);
      avgFrames = double.parse(resultAvgFrames);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textSizeModif = (screenHeight + screenWidth) * textAdaptModifier;

    textSizeModifierSet = ref.watch(textSizeModifier);

    Widget displayCountdownTimer;
    Widget displayError1;
    Widget displayError2;

    colorSet = {
      "mainColor": ref.watch(mainColorState),
      "secondaryColor": ref.watch(secondaryColorState),
      "tertiaryColor": ref.watch(tertiaryColorState),
    };

    final luminanceValue = ref.watch(luminanceProvider);

    if (ref.watch(isAllCoordinatesPresent) == false) {
      displayError1 = poseError(
        opacity: 1,
      );
    } else {
      displayError1 = poseError(opacity: 0.0);
    }

    if (luminanceValue <= 50.0) {
      displayError2 = luminanceError(opacity: 1);
    } else {
      displayError2 = luminanceError(opacity: 0.0);
    }

    try {
      avgFrames = execTotalFrames / ref.watch(numExec);
      resultAvgFrames = avgFrames.toStringAsFixed(2);
      avgFrames = double.parse(resultAvgFrames);
      ref.read(averageFrameState.notifier).state = avgFrames;

      if (avgFrames <= ref.watch(averageThresholdBad)) {
        averageColor = Colors.red;
      } else if (avgFrames >= ref.watch(averageThresholdBad) &&
          avgFrames <= ref.watch(averageThresholdIdeal)) {
        averageColor = Colors.orange;
      } else if (avgFrames >= ref.watch(averageThresholdIdeal)) {
        averageColor = Colors.green;
      }
      ref.read(averageColorState.notifier).state = averageColor;
    } catch (error) {
      avgFrames = 0;
    }

    try {
      if (minFrame <= ref.watch(minFrameThresholdBad)) {
        minFrameColor = Colors.red;
      } else if (minFrame >= ref.watch(minFrameThresholdBad) &&
          minFrame <= ref.watch(minFrameThresholdIdeal)) {
        minFrameColor = Colors.orange;
      } else if (minFrame >= ref.watch(minFrameThresholdIdeal)) {
        minFrameColor = Colors.green;
      }
      ref.read(minFrameColorState.notifier).state = minFrameColor;
    } catch (error) {
      minFrame = 0;
    }

    try {
      if (maxFrame <= ref.watch(maxFrameThresholdBad)) {
        maxFrameColor = Colors.red;
      } else if (maxFrame >= ref.watch(maxFrameThresholdBad) &&
          maxFrame <= ref.watch(maxFrameThresholdIdeal)) {
        maxFrameColor = Colors.orange;
      } else if (maxFrame >= ref.watch(maxFrameThresholdIdeal)) {
        maxFrameColor = Colors.green;
      }
      ref.read(maxFrameColorState.notifier).state = maxFrameColor;
    } catch (error) {
      maxFrame = 0;
    }

    return Stack(
      children: [
        // --------------------------------------------------------------------------[HELP BUTTON]

        Align(
          alignment: Alignment(1.0, 0.78),
          child: IconButton(
            icon: Icon(
              Icons.question_mark,
              color: tertiaryColor,
            ),
            onPressed: () {
              ShowCaseWidget.of(context).startShowCase([
                tutorial_deletePrev,
                tutorial_pause,
                tutorial_deleteAll,
                tutorial_ignorePose,
                // tutorial_avgFrame,
                // tutorial_variance,
                // tutorial_avgFrame2,
                // tutorial_variance2,
                tutorial_lightingError,
                tutorial_poseError,
                tutorial_progressBar,
                tutorial_submit
              ]);
            },
          ),
        ),

// --------------------------------------------------------------------------[COUNTER]

        Align(
          alignment: Alignment(0.0, -0.94),
          child: Container(
            width: screenWidth * 0.83,
            height: screenHeight * 0.05,
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.75),
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth * 0.80,
                  height: screenHeight * 0.017,
                  decoration: BoxDecoration(
                    color: tertiaryColor,
                    borderRadius: BorderRadius.circular(screenWidth * 0.07),
                  ),
                  child: Showcase(
                    key: tutorial_progressBar,
                    title: 'Progress Bar',
                    description:
                        'This indicates whether you whole body is present directly at the camera(Exceptions on parts of the body you ignored).',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(screenWidth * 0.07),
                      child: LinearProgressIndicator(
                        value: ref.watch(numExec) > requiredDataNum
                            ? requiredDataNum
                            : ref.watch(numExec) / requiredDataNum,
                        backgroundColor: tertiaryColor.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            secondaryColor.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: screenHeight * 0.12,
          child: Container(
            width: screenWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildElevatedButton(
                    context: context,
                    label: ref.watch(isCollectingCorrect.notifier).state == true
                        ? "Correct"
                        : "Incorrect",
                    colorSet: colorSet,
                    textSizeModifierIndividual:
                        textSizeModifierSet['smallText2']!,
                    func: () {
                      ref.watch(isCollectingCorrect.notifier).state == true
                          ? ref.watch(isCollectingCorrect.notifier).state =
                              false
                          : ref.watch(isCollectingCorrect.notifier).state =
                              true;
                    }),
              ],
            ),
          ),
        ),

// --------------------------------------------------------------------------[FRAME DETAIL CONTAINER 2]
        Positioned(
          bottom: screenHeight * 0.03,
          left: screenWidth * 0.05,
          height: screenHeight * 0.05,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: tertiaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(
                      30.0), // Adjust the radius as needed
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Showcase(
                      key: tutorial_deletePrev,
                      title: 'Delete Previous',
                      description: 'Press this to delete recent collected data',
                      child: IconButton(
                        icon: Icon(
                          Icons.restart_alt,
                          color: tertiaryColor,
                          size: screenWidth * .06, //
                        ),
                        onPressed: () {
                          undoExecution(1);
                        },
                      ),
                    ),
                    Showcase(
                      key: tutorial_pause,
                      title: 'Pause',
                      description: 'Press this to pause the collection of data',
                      child: IconButton(
                        icon: Icon(
                          Icons.pause,
                          color: tertiaryColor,
                          size: screenWidth * .06, //
                        ),
                        onPressed: () {
                          // simulateCollectData();
                          setState(() {
                            ref.watch(isPerforming.notifier).state = false;
                          });
                        },
                      ),
                    ),
                    Showcase(
                      key: tutorial_deleteAll,
                      title: 'Delete All',
                      description: 'Press this to delete all data collected',
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_forever,
                          color: tertiaryColor,
                          size: screenWidth * .06, //
                        ),
                        onPressed: () {
                          undoExecution(
                              ref.read(coordinatesDataProvider).state.length);
                        },
                      ),
                    ),
                    Showcase(
                      key: tutorial_ignorePose,
                      title: 'Ignore Pose',
                      description:
                          'Press this to have the option to ignore certain parts of your body from being collected or being detected. This is usually used if a part of your body is behind something or not directly at the camera',
                      // child: customDialogEA(
                      //   iconSize: screenWidth * .06,
                      //   igrnoreCoordinatesList: igrnoreCoordinatesList,
                      // ),
                      child: cwIgnorePose(),
                      //
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Positioned(
          bottom: screenHeight * 0.015,
          right: screenWidth * 0.05,
          child: Showcase(
            key: tutorial_submit,
            title: 'Submit',
            description:
                'After collecting data submit it to get a data analysis and proceed to the next part',
            child: Container(
              child: cwDataAnalysis(
                execCount: ref.watch(numExec),
                data: ref.watch(coordinatesDataProvider).state,
                data2: ref.watch(incorrectCoordinatesDataProvider).state,
              ),
            ),
          ),
        ),

        Positioned(
          top: screenWidth * 0.16,
          child: Container(
            width: screenWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Showcase(
                  key: tutorial_poseError,
                  title: 'Pose Error',
                  description:
                      'This indicates whether you whole body is present directly at the camera(Exceptions on parts of the body you ignored).',
                  child: displayError1,
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Showcase(
                  key: tutorial_lightingError,
                  title: 'Lighting Error',
                  description:
                      'This indicates the lighting conditions. This could affect the accuracy of the model',
                  child: displayError2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
