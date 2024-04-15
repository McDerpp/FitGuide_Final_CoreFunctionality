import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/coreFunctionality/custom_widgets/customButton.dart';
import 'package:frontend/coreFunctionality/mainUISettings.dart';
import 'package:frontend/services/provider_collection.dart';
import 'package:frontend/coreFunctionality/modes/globalStuff/provider/globalVariables.dart';

class inferencingP1 extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> exerciseProgram;

  const inferencingP1({
    required this.exerciseProgram,
    super.key,
  });

  @override
  ConsumerState<inferencingP1> createState() => _inferencingP1State();
}

class _inferencingP1State extends ConsumerState<inferencingP1> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Map<String, double> textSize = ref.watch(textSizeModifier);
    return Scaffold(
      backgroundColor: ref.watch(mainColorState),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: screenHeight * 0.075,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'NICE WORK!',
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                color: ref.watch(secondaryColorState),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              'You completed these exercises :',
              style: TextStyle(
                fontSize: 20.0,
                color: ref.watch(tertiaryColorState),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.exerciseProgram.length,
              itemBuilder: (context, index) {
                final exerciseDetail = widget.exerciseProgram[index];
                final String nameOfExercise = exerciseDetail['nameOfExercise'];
                final int setsNeeded = exerciseDetail['setsNeeded'];
                final int numberOfExecution =
                    exerciseDetail['numberOfExecution'];

                return Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: screenWidth * 0.15),
                  child: Container(
                    height: MediaQuery.of(context).size.width * 0.2,
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      color: ref.watch(tertiaryColorState),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Text(
                        nameOfExercise,
                        style: TextStyle(
                          fontSize: (screenWidth * textSize["mediumText"]!),
                          fontWeight: FontWeight.w600,
                          color: ref.read(secondaryColorState),
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Container(
                            width: screenWidth * 0.15,
                            child: Text('Sets: $setsNeeded'),
                          ),
                          Container(
                            width: screenWidth * 0.15,
                            child: Text('Reps: $numberOfExecution'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: screenHeight * 0.01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildElevatedButton(
                context: context,
                label: "Home",
                colorSet: ref.watch(ColorSet)["ColorSet1"]!,
                textSizeModifierIndividual:
                    ref.watch(textSizeModifier)["smallText2"]!,
                func: () {
                  // ==============================================================<CHANGE TO HOME>
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const collectionDataP4(),
                  //     // const collectionDataP2(),
                  //   ),
                  // );
                },
              ),
            ],
          ),
          SizedBox(
            height: screenHeight * 0.075,
          ),
        ],
      ),
    );
  }
}
