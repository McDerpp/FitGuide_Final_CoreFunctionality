import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/coreFunctionality/custom_widgets/customWidgetPDV.dart';
import 'package:frontend/services/globalVariables.dart';

import '../../services/provider_collection.dart';
import 'customButton.dart';

class customDialogEA extends ConsumerStatefulWidget {
  final List<bool> igrnoreCoordinatesList;
  final double widthMultiplier;
  final double heightMultiplier;
  final double iconSize;
  // final Function(int poseIndex) coordinatesIgnoreState;
  // final Function() initiateIgnoreCoordinates;

  const customDialogEA({
    // required this.coordinatesIgnoreState,
    // required this.initiateIgnoreCoordinates,
    required this.iconSize,
    required this.igrnoreCoordinatesList,
    this.widthMultiplier = 1,
    this.heightMultiplier = 0.35,
    super.key,
  });

  @override
  ConsumerState<customDialogEA> createState() => _customDialogEAState();
}

class _customDialogEAState extends ConsumerState<customDialogEA> {
  late Map<String, Color> headColor;
  late Map<String, Color> leftArmColor;
  late Map<String, Color> rightArmColor;
  late Map<String, Color> leftLegColor;
  late Map<String, Color> rightLegColor;
  late Map<String, Color> bodyColor;

  late Map<String, Color> colorSet;
  late Map<String, Color> colorSet2;

  List<int> ignoreCoordinatesInitialized = [];

  Color? coordinatesIgnoreState(int index) {
    if (ref.watch(ignoreCoordinatesList).elementAt(index) == false) {
      ref.read(ignoreCoordinatesList.notifier).state[index] = true;
      return Colors.purple[900];
    } else {
      ref.read(ignoreCoordinatesList.notifier).state[index] = false;
      return ref.watch(secondaryColorState);
    }
  }

  void initiateIgnoreCoordinates() {
    ignoreCoordinatesInitialized.clear();
    List<int> head = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    List<int> body = [];
    List<int> leftArm = [11, 13, 25, 21, 17, 19];
    List<int> rightArm = [12, 14, 16, 18, 20, 22];
    List<int> leftLeg = [23, 25, 27, 29, 31];
    List<int> rightLeg = [24, 26, 28, 32, 30];
    List<int> tempCoord = [];

    if (ref.read(ignoreCoordinatesList.notifier).state.elementAt(0) == true) {
      tempCoord.addAll(head);
    }

    if (ref.read(ignoreCoordinatesList.notifier).state.elementAt(1) == true) {
      tempCoord.addAll(body);
    }

    if (ref.read(ignoreCoordinatesList.notifier).state.elementAt(2) == true) {
      tempCoord.addAll(leftArm);
    }

    if (ref.read(ignoreCoordinatesList.notifier).state.elementAt(3) == true) {
      tempCoord.addAll(rightArm);
    }

    if (ref.read(ignoreCoordinatesList.notifier).state.elementAt(4) == true) {
      tempCoord.addAll(leftLeg);
    }

    if (ref.read(ignoreCoordinatesList.notifier).state.elementAt(5) == true) {
      tempCoord.addAll(rightLeg);
    }

    //     if (igrnoreCoordinatesList.elementAt(0) == true) {
    //   ignoreCoordinatesInitialized.addAll(head);
    // }
    // if (igrnoreCoordinatesList.elementAt(1) == true) {
    //   ignoreCoordinatesInitialized.addAll(leftArm);
    // }
    // if (igrnoreCoordinatesList.elementAt(2) == true) {
    //   ignoreCoordinatesInitialized.addAll(rightArm);
    // }
    // if (igrnoreCoordinatesList.elementAt(3) == true) {
    //   ignoreCoordinatesInitialized.addAll(leftLeg);
    // }
    // if (igrnoreCoordinatesList.elementAt(4) == true) {
    //   ignoreCoordinatesInitialized.addAll(rightLeg);
    // }
  }

  void updateColorSet(String whatColor) {
    if (whatColor == "headColor") {
      print("updating headColor");
      setState(() {
        headColor = colorSet2;
      });
    }
    if (whatColor == "leftArmColor") {
      setState(() {
        leftArmColor = colorSet2;
      });
    }
    if (whatColor == "rightArmColor") {
      setState(() {
        rightArmColor = colorSet2;
      });
    }
    if (whatColor == "leftLegColor") {
      setState(() {
        leftLegColor = colorSet2;
      });
    }
    if (whatColor == "rightLegColor") {
      setState(() {
        rightLegColor = colorSet2;
      });
    }
    if (whatColor == "bodyColor") {
      setState(() {
        bodyColor = colorSet2;
      });
    }
    // setState(() {
    //   // Toggle the value of leftUpperArm
    //   leftUpperArm = !leftUpperArm;

    //   // Update the colorSet based on the new value of leftUpperArm
    //   colorSet = leftUpperArm ? colorSet1 : colorSet2;
    // });
  }

  void showCustomDialogEA(
    BuildContext context,
    Widget content, {
    int alphaValue = 240,
  }) {
    Color mainColor = ref.watch(mainColorState);
    Color secondaryColor = ref.watch(secondaryColorState);
    Color tertiaryColor = ref.watch(tertiaryColorState);

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
                  width: screenWidth * widget.widthMultiplier,
                  height: screenHeight * widget.heightMultiplier,
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

  // Color? coordinatesIgnoreState(int index) {
  //   widget.igrnoreCoordinatesList[index] = false;
  //   return ref.watch(secondaryColorState);
  // }

  // void initiateIgnoreCoordinates() {
  //   ignoreCoordinatesInitialized.clear();
  //   List<int> head = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  //   List<int> body = [];
  //   List<int> leftArm = [11, 13, 25, 21, 17, 19];
  //   List<int> rightArm = [12, 14, 16, 18, 20, 22];
  //   List<int> leftLeg = [23, 25, 27, 29, 31];
  //   List<int> rightLeg = [24, 26, 28, 32, 30];

  //   if (widget.igrnoreCoordinatesList.elementAt(0) == true) {
  //     ignoreCoordinatesInitialized.addAll(head);
  //   }
  //   if (widget.igrnoreCoordinatesList.elementAt(1) == true) {
  //     ignoreCoordinatesInitialized.addAll(leftArm);
  //   }
  //   if (widget.igrnoreCoordinatesList.elementAt(2) == true) {
  //     ignoreCoordinatesInitialized.addAll(rightArm);
  //   }
  //   if (widget.igrnoreCoordinatesList.elementAt(3) == true) {
  //     ignoreCoordinatesInitialized.addAll(leftLeg);
  //   }
  //   if (widget.igrnoreCoordinatesList.elementAt(4) == true) {
  //     ignoreCoordinatesInitialized.addAll(rightLeg);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    Color mainColor = ref.watch(mainColorState);
    Color secondaryColor = ref.watch(secondaryColorState);
    Color tertiaryColor = ref.watch(tertiaryColorState);
    late Map<String, double> textSizeModifierSet = ref.watch(textSizeModifier);

    colorSet = {
      "mainColor": mainColor,
      "secondaryColor": secondaryColor,
      "tertiaryColor": tertiaryColor,
    };

    colorSet2 = {
      "mainColor": Colors.amberAccent,
      "secondaryColor": Colors.amberAccent,
      "tertiaryColor": Colors.amberAccent,
    };

    headColor = colorSet;
    leftArmColor = colorSet;
    rightArmColor = colorSet;
    leftLegColor = colorSet;
    rightLegColor = colorSet;
    bodyColor = colorSet;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool leftUpperArm = true;

    bool? head = ref.watch(ignorePoseList.select((value) => value['head']));
    // bool? leftUpperArm =
    //     ref.watch(ignorePoseList.select((value) => value['leftUpperArm']));
    bool? leftLowerArm =
        ref.watch(ignorePoseList.select((value) => value['leftLowerArm']));

    bool? rightUpperArm =
        ref.watch(ignorePoseList.select((value) => value['rightUpperArm']));
    bool? rightLowerArm =
        ref.watch(ignorePoseList.select((value) => value['rightLowerArm']));

    bool? leftUpperLeg =
        ref.watch(ignorePoseList.select((value) => value['leftUpperLeg']));
    bool? leftLowerLeg =
        ref.watch(ignorePoseList.select((value) => value['leftLowerLeg']));

    bool? rightLowerLeg =
        ref.watch(ignorePoseList.select((value) => value['rightLowerLeg']));
    bool? rightUpperLeg =
        ref.watch(ignorePoseList.select((value) => value['rightUpperLeg']));

    return Container(
      child: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: Icon(
              Icons.accessibility_new_sharp,
              color: tertiaryColor,
              size: widget.iconSize,
            ),
            onPressed: () {
              showCustomDialogEA(
                context,
                Column(
                  children: [
                    Row(
                      children: [
                        buildElevatedButton(
                          context: context,
                          label: "Head",
                          colorSet: head == true ? colorSet : colorSet2,
                          textSizeModifierIndividual:
                              textSizeModifierSet['smallText2']!,
                          // func:  poseChangeState(poseName: "head",poseState: true),
                          func: () {
                            ref.read(ignorePoseList.notifier).state["head"] =
                                false;
                            print("head value----> $head");
                            setState(() {
                              head = ref.watch(ignorePoseList
                                  .select((value) => value['head']));
                            });

                            updateColorSet("headColor");
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        buildElevatedButton(
                          context: context,
                          label: "Head",
                          colorSet: head == true ? colorSet : colorSet2,
                          textSizeModifierIndividual:
                              textSizeModifierSet['smallText2']!,
                          // func:  poseChangeState(poseName: "head",poseState: true),
                          func: () {
                            ref.read(ignorePoseList.notifier).state["head"] =
                                false;
                            print("head value----> $head");
                            setState(() {
                              head = ref.watch(ignorePoseList
                                  .select((value) => value['head']));
                            });

                            updateColorSet("headColor");
                          },
                        ),
                        buildElevatedButton(
                          context: context,
                          label: "leftUpperArm",
                          colorSet: leftUpperArm == true ? colorSet : colorSet2,
                          textSizeModifierIndividual:
                              textSizeModifierSet['smallText2']!,
                          // func:  poseChangeState(poseName: "head",poseState: true),
                          func: () {
                            setState(() {});
                            ref
                                .read(ignorePoseList.notifier)
                                .state["leftUpperArm"] = false;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
