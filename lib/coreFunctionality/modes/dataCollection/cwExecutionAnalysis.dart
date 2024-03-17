import 'package:flutter/material.dart';
import 'package:frontend/coreFunctionality/extraWidgets/customWidgetPDV.dart';
import 'package:frontend/coreFunctionality/modes/dataCollection/collectionDataP1.dart';
import 'cwProcessingToTxt.dart';
import 'package:frontend/coreFunctionality/globalVariables.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logicFunction/isolateProcessPDV.dart';
import 'halfCircleProgressBar.dart';

class cwDataAnalysis extends ConsumerStatefulWidget {
  final double widthMultiplier;
  final double heightMultiplier;
  final int alphaValue;
  final int execCount;
  final List<List<List<double>>> data;

  const cwDataAnalysis({
    super.key,
    required this.execCount,
    required this.data,
    this.widthMultiplier = 0.7,
    this.heightMultiplier = 0.25,
    this.alphaValue = 235,
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
    BuildContext context,
    Widget content, {
    double widthMultiplier = 1,
    double heightMultiplier = 0.35,
    int alphaValue = 240,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Color transparentColor = mainColor.withOpacity(alphaValue / 255.0);

    void cancelfunc() {
      Navigator.pop(context);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            AlertDialog(
              backgroundColor: transparentColor,
              content: Container(
                  width: screenWidth * widthMultiplier,
                  height: screenHeight * heightMultiplier,
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.arrow_back,
                              color: tertiaryColor,
                              size: screenWidth * .08,
                            ),
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              cancelfunc();
                            },
                          ),
                          Expanded(
                            child: SizedBox(
                              height: screenHeight * 0.005,
                            ),
                          ),
                          IconButton(
                            alignment: Alignment.topRight,
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.help,
                              color: tertiaryColor,
                              size: screenWidth * .08,
                            ),
                            highlightColor: Colors.transparent,
                            onPressed: () {},
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          content,
                        ],
                      ),
                    ],
                  )),
            )
          ],
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
                                    color: colorResult,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: screenWidth * 0.02,
                                height: screenWidth * 0.02,
                                decoration: BoxDecoration(
                                  color: colorResult,
                                  borderRadius: BorderRadius.circular(10),
                                ))
                          ],
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

  void executionAnalysis({
    required Map<String, double> textSizeModifier,
    required Map<String, Color> colorSet,
    required BuildContext context,
    required int numExec,
    required double avgFrames,
    required List<dynamic> coordinatesData,
    required double progress,
    required bool boolLoading,
    
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return showCustomDialogEA(
      widthMultiplier: 1.4,
      heightMultiplier: 0.5,
      context,
      boolLoading == false
          ? Column(
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
                            backgroundColor: colorSet['tertiaryColor']!,
                            valueColor: colorSet['secondaryColor']!,
                            strokeWidth: screenWidth * 0.06,
                            executionCount: numExec,
                            maxExecution: 100, // 50% progress
                            // 50% progress
                            sizeOfCircle:
                                Size(screenWidth * 0.5, screenWidth * 0.5),
                          ),
                        ),
                        Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height: screenHeight * 0.015,
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
                                "Executions :  ${widget.execCount}", // Text to display
                                style: TextStyle(
                                  fontSize: screenWidth *
                                      textSizeModifier['smallText2']!,
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
                              height: screenHeight * 0.16,
                            ),
                            Row(
                              children: [
                                executionResults(
                                    fontSize: screenWidth *
                                        textSizeModifier['smallText']!,
                                    screenWidth: screenWidth,
                                    label: "Average",
                                    value: ref.watch(averageFrameState),
                                    icon: Icons.auto_awesome_motion_rounded,
                                    modif: 0.5,
                                    colorResult: ref.watch(averageColorState)),
                                Expanded(
                                  child: SizedBox(
                                    height: 0.02,
                                  ),
                                ),
                                executionResults(
                                    fontSize: screenWidth *
                                        textSizeModifier['smallText']!,
                                    screenWidth: screenWidth,
                                    label: "Vairance",
                                    value: ref.watch(varianceFrameState),
                                    icon: Icons.more_horiz,
                                    modif: 0.5,
                                    colorResult: ref.watch(varianceColorState)),
                              ],
                            ),
                            Row(
                              children: [
                                executionResults(
                                    fontSize: screenWidth *
                                        textSizeModifier['smallText']!,
                                    screenWidth: screenWidth,
                                    label: "Min",
                                    value: ref.watch(minFrameState),
                                    icon: Icons.playlist_play,
                                    modif: 0.5,
                                    colorResult: ref.watch(minFrameColorState)),
                                SizedBox(
                                  width: screenHeight * 0.02,
                                ),
                                executionResults(
                                    fontSize: screenWidth *
                                        textSizeModifier['smallText']!,
                                    screenWidth: screenWidth,
                                    label: "Max",
                                    value: ref.watch(maxFrameState),
                                    icon: Icons.more_horiz,
                                    modif: 0.5,
                                    colorResult: ref.watch(maxFrameColorState)),
                              ],
                            ),
                            Container(
                              width: screenWidth *
                                  0.8, // Specify the width of the circle
                              height: screenWidth *
                                  0.005, // Specify the height of the circle
                              decoration: BoxDecoration(
                                // Make the container circular
                                color: colorSet[
                                    'tertiaryColor'], // Specify the color of the circle
                              ),
                            ),
                            Text(
                              "Data quality : Good", // Text to display
                              style: TextStyle(
                                fontSize: screenWidth *
                                    textSizeModifier['mediumText']!,
                                fontWeight: FontWeight.bold,
                                color: colorSet['tertiaryColor'],
                                decoration: TextDecoration.none,
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildElevatedButton(
                            context: context,
                            label: "Review",
                            colorSet: colorSet,
                            textSizeModifierIndividual:
                                textSizeModifier['smallText2']!,
                            func: () {
                              // translateCollectedDatatoTxt(
                              //   coordinatesData,
                              //   updateProgress,
                              // );
                            },
                          ),
                          buildElevatedButton(
                            context: context,
                            label: "Submit",
                            colorSet: colorSet,
                            textSizeModifierIndividual:
                                textSizeModifier['smallText2']!,
                            func: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      collectionDataP1(input: widget.data),
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
          : Column(
              children: [Text("eareraesraeraeraeraeraser")],
            ),
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
        executionAnalysis(
          boolLoading: false,
          avgFrames: 0,
          colorSet: colorSet,
          textSizeModifier: textSizeModifierSet,
          context: context,
          numExec: widget.execCount,
          coordinatesData: widget.data,
          progress: 0,
        );
      },
    ));
  }
}
