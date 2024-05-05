import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/coreFunctionality/custom_widgets/customWidgetPDV.dart';
import 'package:frontend/coreFunctionality/modes/dataCollection/screens/p2_txtConversion.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import '../../services/provider_collection.dart';
import 'customButton.dart';
import 'txtConversion.dart';

import 'package:frontend/services/globalVariables.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logicFunction/isolateProcessPDV.dart';
import '../modes/dataCollection/widgets/cwReview.dart';
import 'halfCircleProgressBar.dart';

class cwDataAnalysis extends ConsumerStatefulWidget {
  final double widthMultiplier;
  final double heightMultiplier;
  final int alphaValue;
  final int execCount;
  final List<List<List<double>>> data;
  final List<List<List<double>>> data2;
  final bool isRetraining;

  const cwDataAnalysis({
    super.key,
    required this.execCount,
    required this.data,
    required this.data2,
    this.widthMultiplier = 0.7,
    this.heightMultiplier = 0.25,
    this.alphaValue = 235,
    this.isRetraining = false,

  });

  @override
  ConsumerState<cwDataAnalysis> createState() => _cwDataAnalysisState();
}

class _cwDataAnalysisState extends ConsumerState<cwDataAnalysis> {
  late Color mainColor;
  late Color secondaryColor;
  late Color tertiaryColor;
  late Map<String, double> textSizeModifierSet;
  late double textSizeModifierSetIndividual;
  late Map<String, Color> colorSet;
  bool boolLoading2 = false;
  bool review = false;

  List<int> data = [];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 30; i++) {
      data.add(Random().nextInt(100) + 1);
    }
    // uncomment this after testing
    // ref.read(numExec.notifier).state = widget.execCount;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mainColor = ref.watch(mainColorState);
    secondaryColor = ref.watch(secondaryColorState);
    tertiaryColor = ref.watch(tertiaryColorState);
    textSizeModifierSet = ref.watch(textSizeModifier);
    textSizeModifierSetIndividual = textSizeModifierSet["smallText"]!;
    colorSet = {
      "mainColor": mainColor,
      "secondaryColor": secondaryColor,
      "tertiaryColor": tertiaryColor,
    };
  }

  void showCustomDialogEA(
    BuildContext context, {
    double widthMultiplier = 1.4,
    double heightMultiplier = 0.58,
    int alphaValue = 240,
  }) {
    ref.watch(isPerforming.notifier).state = false;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Color transparentColor = mainColor.withOpacity(alphaValue / 255.0);
    textSizeModifierSet = ref.watch(textSizeModifier);
    textSizeModifierSetIndividual = textSizeModifierSet["smallText"]!;

    int totalFramesPositive = 0;
    int totalFramesNegative = 0;

    List<List<List<double>>> negativeData =
        ref.watch(coordinatesDataProvider).state;
    List<List<List<double>>> positiveData =
        ref.watch(incorrectCoordinatesDataProvider).state;

    for (List<List<double>> execution in positiveData) {
      totalFramesPositive = totalFramesPositive + execution.length;

      if (ref.read(maxFrameState.notifier).state < execution.length) {
        ref.read(maxFrameState.notifier).state = execution.length;
      }

      if (ref.read(minFrameState.notifier).state == 0) {
        ref.read(minFrameState.notifier).state = execution.length;
      }

      if (ref.read(minFrameState.notifier).state > execution.length) {
        ref.read(minFrameState.notifier).state = execution.length;
      }
    }

    for (List<List<double>> execution in negativeData) {
      totalFramesNegative = totalFramesNegative + execution.length;

      if (ref.read(minFrameNegativeState.notifier).state == 0) {
        ref.read(minFrameNegativeState.notifier).state = execution.length;
      }

      if (ref.read(maxFrameNegativeState.notifier).state < execution.length) {
        ref.read(maxFrameNegativeState.notifier).state = execution.length;
      }

      if (ref.read(minFrameNegativeState.notifier).state > execution.length) {
        ref.read(minFrameNegativeState.notifier).state = execution.length;
      }
    }

    ref.read(averageFrameState.notifier).state =
        totalFramesPositive / positiveData.length;
    ref.read(averageFrameNegativeState.notifier).state =
        totalFramesNegative / negativeData.length;

    ref.read(numExec.notifier).state = positiveData.length;
    ref.read(numExecNegative.notifier).state = negativeData.length;

    void cancelfunc() {
      Navigator.pop(context);
    }

    List<dynamic> content = [
      [
        [Icons.bar_chart, "Average", ref.read(averageFrameState)],
        [Icons.bar_chart, "Average", ref.read(averageFrameNegativeState)],
      ],
      [
        [Icons.arrow_downward, "Min", ref.read(minFrameState)],
        [Icons.arrow_downward, "Min", ref.read(minFrameNegativeState)],
      ],
      [
        [Icons.arrow_upward, "Max", ref.read(maxFrameState)],
        [Icons.arrow_upward, "Max", ref.read(maxFrameNegativeState)],
      ],
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: transparentColor,
              content: Container(
                width: screenWidth * widthMultiplier,
                height: screenHeight * heightMultiplier,
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: screenHeight * 0.005,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // SizedBox(
                                //   height: screenHeight * 0.005,
                                // ),
                                Stack(
                                  children: [
                                    Center(
                                      child: HalfCircleProgressBar(
                                        backgroundColor:
                                            colorSet['tertiaryColor']!,

                                        strokeWidth: screenWidth * 0.06,
                                        executionCount: ref
                                            .watch(coordinatesDataProvider)
                                            .state
                                            .length,

                                        maxExecution: 100, // 50% progress
                                        // 50% progress
                                        sizeOfCircle: Size(screenWidth * 0.5,
                                            screenWidth * 0.5),
                                        incorrectExecutionCount: ref
                                            .watch(
                                                incorrectCoordinatesDataProvider)
                                            .state
                                            .length,
                                      ),
                                    ),
                                    Center(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: screenHeight * 0.04,
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.directions_walk,
                                              color: tertiaryColor,
                                              size: screenWidth * .15,
                                            ),
                                            onPressed: () {},
                                          ),
                                          Text(
                                            "Positive:${ref.watch(coordinatesDataProvider).state.length} | Negative:${ref.watch(incorrectCoordinatesDataProvider).state.length}", // Text to display
                                            style: TextStyle(
                                              fontSize: screenWidth *
                                                  textSizeModifierSet[
                                                      'mediumText']!,
                                              fontWeight: FontWeight.bold,
                                              color: colorSet['tertiaryColor'],
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: screenHeight * 0.18,
                                        ),
                                        Column(
                                          children: List.generate(
                                            3,
                                            (index) => Row(
                                              children: [
                                                executionResults(
                                                    fontSize: screenWidth *
                                                        textSizeModifierSet[
                                                            'smallText']!,
                                                    screenWidth: screenWidth,
                                                    label: content[index][0][1],
                                                    value: content[index][0][2],
                                                    icon: content[index][0][0],
                                                    modif: 0.5,
                                                    colorResult: ref.watch(
                                                        averageColorState)),
                                                Expanded(
                                                  child: SizedBox(
                                                    height: 0.18,
                                                  ),
                                                ),
                                                executionResults(
                                                    fontSize: screenWidth *
                                                        textSizeModifierSet[
                                                            'smallText']!,
                                                    screenWidth: screenWidth,
                                                    label: content[index][1][1],
                                                    value: content[index][1][2],
                                                    icon: content[index][1][0],
                                                    modif: 0.5,
                                                    colorResult: ref.watch(
                                                        varianceColorState)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height: screenHeight * 0.01,
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      buildElevatedButton(
                                        context: context,
                                        label: "Submit",
                                        colorSet: colorSet,
                                        textSizeModifierIndividual:
                                            textSizeModifierSet['smallText2']!,
                                        func: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  collectionDataP1(
                                                correctDataset: widget.data,
                                                incorretcDataset: widget.data2,
                                                isRetraining: widget.isRetraining,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                            //
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget executionResults({
    required double screenWidth,
    required double fontSize,
    required String label,
    required dynamic value,
    required dynamic icon,
    required Color colorResult,
    dynamic modif = 1,
  }) {
    return Stack(
      children: [
        SizedBox(height: screenWidth * 0.2),
        // ========================================================================
        Positioned(
          child: Row(
            children: [
              SizedBox(
                width: screenWidth * 0.05,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: screenWidth * 0.01,
                  ),
                  Container(
                    width: screenWidth * 0.5 * modif,
                    height: screenWidth * 0.15,
                    decoration: BoxDecoration(
                      color: colorSet['tertiaryColor'],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // ====================================================================
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          // Ensure the label text expands to fill the available space
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: screenWidth * 0.015,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "  $label", // Text to display
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: colorSet['mainColor'],
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(width: screenWidth * 0.11),
                                ],
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "  $value", // Text to display
                                  style: TextStyle(
                                    fontSize: fontSize + fontSize * 0.50,
                                    fontWeight: FontWeight.normal,
                                    color: colorSet['mainColor'],
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.018,
                        ),
                      ],
                    ),
                    // ====================================================================
                  ),
                ],
              )
            ],
          ),
        ),
        // ========================================================================

        Container(
          width: screenWidth * 0.09, // Specify the width of the circle
          height: screenWidth * 0.09, // Specify the height of the circle
          decoration: BoxDecoration(
            shape: BoxShape.circle, // Make the container circular
            color: colorSet['secondaryColor'],
            // Specify the color of the circle
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: mainColor,
              size: screenWidth * .05,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  void _updateValues() {
    mainColor = ref.watch(mainColorState);
    secondaryColor = ref.watch(secondaryColorState);
    tertiaryColor = ref.watch(tertiaryColorState);
    textSizeModifierSet = ref.watch(textSizeModifier);
    textSizeModifierSetIndividual = textSizeModifierSet["smallText"]!;
    setState(() {}); // Trigger a rebuild to reflect the updated values
  }

  Widget processingToTxtScreen() {
    return Scaffold();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: buildElevatedButton(
      context: context,
      label: "Submit",
      colorSet: colorSet,
      textSizeModifierIndividual: textSizeModifierSetIndividual,
      func: () {
        showCustomDialogEA(context);
      },
    ));
  }
}
