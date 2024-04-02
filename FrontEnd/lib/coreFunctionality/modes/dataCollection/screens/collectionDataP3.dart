import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/coreFunctionality/extraWidgets/customWidgetPDV.dart';
import 'package:frontend/coreFunctionality/modes/globalStuff/provider/globalVariables.dart';
import 'package:frontend/coreFunctionality/modes/dataCollection/services/api.dart';
import 'package:showcaseview/showcaseview.dart';

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

  Widget customTextField(
      {required String label,
      required String hintText,
      required double width,
      required String variable
      // required double height,
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

    return ShowCaseWidget(
      builder: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Container(
                height: screenHeight,
                width: screenWidth,
                color: ref.watch(mainColorState),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: screenHeight * 0.1,
                    ),
                    SizedBox(
                      width: screenWidth,
                    ),
                    customTextField(
                        label: "Exercise Name",
                        hintText: "Push-Up",
                        width: screenWidth * .9,
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
                          variable: "executionNum",
                        ),
                        SizedBox(
                          width: screenWidth * 0.02,
                        ),
                        customTextField(
                          label: "Sets",
                          hintText: "Push-Up",
                          width: screenWidth * .44,
                          variable: "setsNum",
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenWidth * 0.02,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: ref.watch(tertiaryColorState),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          width: 1.0,
                        ),
                      ),
                      width: screenWidth * .9,
                      child: DropdownButton<String>(
                        value: partsAffected,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        isExpanded: true,
                        onChanged: (String? value) {
                          print("dropdown value ---> $value");
                          setState(() {
                            partsAffected = value!;
                            ref.read(partsAffectedProvider.notifier).state =
                                partsAffected;
              
                          });
                        },
                        items:
                            parts.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: screenWidth * 0.02,
                    ),
                    customLargeTextField(
                        label: "Description(OPTIONAL)",
                        hintText: "What this exercise is about.",
                        width: screenWidth * 0.9,
                        variable: "description"),
                    SizedBox(
                      height: screenWidth * 0.02,
                    ),
                    customLargeTextField(
                      label: "Extra Notes(OPTIONAL)",
                      hintText: "What this exercise is about.",
                      width: screenWidth * 0.9,
                      variable: "extraNote",
                    ),
                    buildElevatedButton(
                      context: context,
                      label: "Submit",
                      colorSet: ref.watch(ColorSet)["ColorSet1"]!,
                      textSizeModifierIndividual:
                          ref.watch(textSizeModifier)["smallText"]!,
                      func: () {
                        setState(() {});
                        collectDatasetInfo(ref);
                        // Update the AlertDialog content
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
