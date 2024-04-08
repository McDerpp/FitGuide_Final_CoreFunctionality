import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/coreFunctionality/custom_widgets/customButton.dart';

import '../../globalStuff/provider/globalVariables.dart';
import '../services/provider_collection.dart';

class collectionDataP4 extends ConsumerStatefulWidget {
  const collectionDataP4({super.key});

  @override
  ConsumerState<collectionDataP4> createState() => _collectionDataP4State();
}

class _collectionDataP4State extends ConsumerState<collectionDataP4> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Map<String, double> textSizeModif = ref.watch(textSizeModifier);
    Color iconColor = ref.watch(mainColorState);
    return Material(
      color: ref.watch(mainColorState),
      child: Container(
        child: Center(
            child: Container(
          height: screenHeight * .8,
          width: screenWidth * .8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.fitness_center,
                  size: screenWidth * .3,
                  color: iconColor,
                ),
                highlightColor: Colors.transparent,
                onPressed: null,
              ),
              Text(
                "Thank you for contributing!",
                style: TextStyle(
                  color: ref.watch(tertiaryColorState),
                  fontSize: screenWidth * textSizeModif["smallText2"]!,
                ),
              ),
              Text(
                "Next step will take a while, we will just notify you, whenever it's done",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ref.watch(tertiaryColorState),
                  fontSize: screenWidth * textSizeModif["smallText2"]!,
                ),
              ),
              SizedBox(
                height: screenHeight * 0.1,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildElevatedButton(
                    context: context,
                    label: "Done",
                    colorSet: ref.watch(ColorSet)["ColorSet1"]!,
                    textSizeModifierIndividual:
                        ref.watch(textSizeModifier)["smallText2"]!,
                    func: () {
                      // ======================================================================================<CHANGE HERE TO HOME>
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const collectionDataP2(),
                      //     // const collectionDataP2(),
                      //   ),
                      // );
                    },
                  ),
                ],
              ),
            ],
          ),
        )),
      ),
    );
  }
}
