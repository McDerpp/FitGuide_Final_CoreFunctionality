import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/coreFunctionality/custom_widgets/customButton.dart';
import 'package:frontend/coreFunctionality/custom_widgets/customWidgetPDV.dart';
import 'package:frontend/coreFunctionality/modes/dataCollection/screens/p5_modelTraining.dart';
import 'package:frontend/services/globalVariables.dart';
import 'package:frontend/services/api.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../services/provider_collection.dart';

class collectionDataP3 extends ConsumerStatefulWidget {
  const collectionDataP3({super.key});

  @override
  ConsumerState<collectionDataP3> createState() => _collectionDataP3State();
}

// change this later..
const List<String> parts = <String>[
  'placeholder_1',
  'placeholder_2',
  'placeholder_3',
  'placeholder_4'
];

class _collectionDataP3State extends ConsumerState<collectionDataP3> {
  String partsAffected = parts.first;
  String exerciseName = "";
  int executionNum = 0;
  int setsNum = 0;
  String description = "";
  String extraNote = "";

  Widget customLargeTextField({
    required String label,
    required String hintText,
    required double width,
    required String variable,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: ref.watch(tertiaryColorState),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          width: 1.0,
        ),
      ),
      child: TextField(
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(16.0),
        ),
        onChanged: (value) {
          setState(() {
            String enteredText = value.replaceAll('\n', '');

            if (variable == "description") {
              description = enteredText;
              ref.read(descriptionProvider.notifier).state = description;
            }

            if (variable == "extraNote") {
              extraNote = enteredText;
              ref.read(additionalNotesProvider.notifier).state = extraNote;
              print(
                  "additionalNotes ---> ${ref.watch(additionalNotesProvider)}");
            }
          });
        },
      ),
    );
  }

  Widget customText({
    required screenWidth,
    required textSizeModif,
    required value,
    required text1,
    required text2,
    bool isMain = false,
    sizeModif = 1,
  }) {
    double letterSpacing = -0.5;
    return Container(
      child: Row(
        mainAxisAlignment:
            isMain == true ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              letterSpacing: letterSpacing - .10,
              color: ref.watch(tertiaryColorState),
              fontSize:
                  screenWidth * 3 * textSizeModif["largeText"]! * sizeModif,
            ),
          ),
          // -------------------------------------------------[executions performed]
          Column(
            children: [
              Text(
                text1,
                style: TextStyle(
                  letterSpacing: letterSpacing,
                  color: ref.watch(tertiaryColorState),
                  fontSize:
                      screenWidth * textSizeModif["smallText"]! * sizeModif,
                ),
              ),
              Text(
                text2,
                style: TextStyle(
                  letterSpacing: letterSpacing,
                  color: ref.watch(tertiaryColorState),
                  fontSize:
                      screenWidth * textSizeModif["smallText"]! * sizeModif,
                ),
              ),
              Text(
                "",
                style: TextStyle(
                  letterSpacing: letterSpacing,
                  color: ref.watch(tertiaryColorState),
                  fontSize:
                      screenWidth * textSizeModif["smallText"]! * sizeModif,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Color darkenColor(Color color, double factor) {
    assert(factor >= 0 && factor <= 1, 'Factor must be between 0 and 1');
    int red = (color.red * (1 - factor)).round().clamp(0, 255);
    int green = (color.green * (1 - factor)).round().clamp(0, 255);
    int blue = (color.blue * (1 - factor)).round().clamp(0, 255);
    return Color.fromRGBO(red, green, blue, 1);
  }

  Widget customCheckBox({
    required bool value,
    required String label,
    required double width,
    required double height,
    required double spacing,
  }) {
    return Column(
      children: [
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: darkenColor(ref.watch(tertiaryColorState), 0.2),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                fillColor:
                    MaterialStateProperty.all(ref.watch(secondaryColorState)),
                checkColor: ref.watch(tertiaryColorState),
                value: value,
                onChanged: (bool? value) {},
              ),
              Text(label)
            ],
          ),
        ),
        SizedBox(
          height: spacing,
        ),
      ],
    );
  }

  Widget customTextField(
      {required String label,
      required String hintText,
      required double width,
      required double height,
      required String variable
      // required double height,
      }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: ref.watch(tertiaryColorState),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          width: 1.0,
        ),
      ),
      child: TextField(
        keyboardType: variable == "exerciseName"
            ? TextInputType.name
            : TextInputType.number,
        maxLength: variable == "exerciseName" ? 20 : 2,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        onChanged: (String value) {
          setState(() {
            if (variable == "exerciseName") {
              exerciseName = value;
              ref.read(exerciseNameProvider.notifier).state = exerciseName;
            }
            if (variable == "executionNum") {
              value.isNotEmpty
                  ? executionNum = int.parse(value)
                  : executionNum = 0;
              ref.read(exerciseNumExecutionProvider.notifier).state =
                  executionNum;
            }
            if (variable == "setsNum") {
              value.isNotEmpty ? setsNum = int.parse(value) : setsNum = 0;
              ref.read(exerciseNumSetProvider.notifier).state = setsNum;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Map<String, double> textSizeModif = ref.watch(textSizeModifier);

    return ShowCaseWidget(
      builder: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            body: SingleChildScrollView(
                child: Stack(
              children: [
                SizedBox(
                  height: screenHeight * 0.4,
                ),
                Container(
                  color: ref.watch(mainColorState),
                  height: screenHeight,
                  width: screenWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.27,
                      ),
                      Text(
                        "Exercise Details",
                        style: TextStyle(
                            color: ref.watch(tertiaryColorState),
                            fontSize:
                                screenWidth * textSizeModif["largeText"]!),
                      ),
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      customTextField(
                          label: "Exercise Name",
                          hintText: "Push-Up",
                          width: screenWidth * .9,
                          height: screenWidth * .25,
                          variable: "exerciseName"),
                      SizedBox(
                        height: screenWidth * 0.02,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          customTextField(
                            label: "Execution",
                            hintText: "Push-Up",
                            width: screenWidth * .44,
                            height: screenWidth * .25,
                            variable: "executionNum",
                          ),
                          SizedBox(
                            width: screenWidth * 0.02,
                          ),
                          customTextField(
                            label: "Sets",
                            hintText: "Push-Up",
                            width: screenWidth * .44,
                            height: screenWidth * .25,
                            variable: "setsNum",
                          ),
                        ],
                      ),
                      SizedBox(
                        height: screenWidth * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              customCheckBox(
                                value: ref.watch(headBoolState),
                                label: 'Head',
                                width: screenWidth * .44,
                                height: screenWidth * .10,
                                spacing: screenWidth * 0.02,
                              ),
                              customCheckBox(
                                value: ref.watch(leftLegBoolState),
                                label: 'Left Leg',
                                width: screenWidth * .44,
                                height: screenWidth * .10,
                                spacing: screenWidth * 0.02,
                              ),
                              customCheckBox(
                                value: ref.watch(leftArmBoolState),
                                label: 'Left Arm',
                                width: screenWidth * .44,
                                height: screenWidth * .10,
                                spacing: screenWidth * 0.02,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: screenWidth * 0.02,
                          ),
                          Column(
                            children: [
                              customCheckBox(
                                value: ref.watch(bodyBoolState),
                                label: 'Body',
                                width: screenWidth * .44,
                                height: screenWidth * .10,
                                spacing: screenWidth * 0.02,
                              ),
                              customCheckBox(
                                value: ref.watch(rightArmBoolState),
                                label: 'Right Arm',
                                width: screenWidth * .44,
                                height: screenWidth * .10,
                                spacing: screenWidth * 0.02,
                              ),
                              customCheckBox(
                                value: ref.watch(rightArmBoolState),
                                label: 'Right Leg',
                                width: screenWidth * .44,
                                height: screenWidth * .10,
                                spacing: screenWidth * 0.02,
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: screenHeight * 0.12,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildElevatedButton(
                              context: context,
                              label: "Submit",
                              colorSet: ref.watch(ColorSet)["ColorSet1"]!,
                              textSizeModifierIndividual:
                                  ref.watch(textSizeModifier)["smallText2"]!,
                              func: () {
                                setState(() {});

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const collectionDataP4(),
                                  ),
                                );
                              },
                            ),
                          ])
                    ],
                  ),
                ),
                Container(
                  height: screenHeight * 0.25,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    color: ref.watch(secondaryColorState),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Align children at the start
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          customText(
                              screenWidth: screenWidth,
                              textSizeModif: textSizeModif,
                              value: ref.watch(numExec),
                              text1: "Executions",
                              text2: "Performed",
                              sizeModif: 1,
                              isMain: true),
                          // SizedBox(
                          //   width: screenWidth * 0.05,
                          // ),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment
                          //       .start, // Align children at the start
                          //   children: [
                          //     customText(
                          //       screenWidth: screenWidth,
                          //       textSizeModif: textSizeModif,
                          //       value: ref.watch(maxFrameState),
                          //       text1: "Max",
                          //       text2: "Frame",
                          //       sizeModif: 0.5,
                          //       isMain: false,
                          //     ),
                          //     customText(
                          //       screenWidth: screenWidth,
                          //       textSizeModif: textSizeModif,
                          //       value: ref.watch(minFrameColorState),
                          //       text1: "Min",
                          //       text2: "Frame",
                          //       sizeModif: 0.5,
                          //       isMain: false,
                          //     ),
                          //     customText(
                          //       screenWidth: screenWidth,
                          //       textSizeModif: textSizeModif,
                          //       value: ref.watch(averageFrameState),
                          //       text1: "Average",
                          //       text2: "Frame",
                          //       sizeModif: 0.5,
                          //       isMain: false,
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            )),
          );
        },
      ),
    );
  }
}
