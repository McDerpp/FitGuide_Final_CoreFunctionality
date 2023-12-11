import 'package:flutter/material.dart';
import 'package:frontend/coreFunctionality/resultsPage/resultCustomWidget.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../extraWidgets/customWidgetPDV.dart';
import '../mainUISettings.dart';

class inferencingReults extends StatefulWidget {
  final String exerciseNameDescription;
  final int numberOfExecutionDescription;
  final int attemptsDescription;
  final int timeDescription;

  const inferencingReults({
    super.key,
    required this.exerciseNameDescription,
    required this.numberOfExecutionDescription,
    required this.attemptsDescription,
    required this.timeDescription,
  });

  @override
  State<inferencingReults> createState() => _inferencingReultsState();
}

class _inferencingReultsState extends State<inferencingReults> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textSizeModif = (screenHeight + screenWidth) * textAdaptModifier;
    int seconds = 0;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: mainColor,
            width: screenWidth,
            height: screenHeight,
          ),
          Positioned(
            top: screenHeight * .10,
            left: screenWidth * .175,
            child: Column(
              children: [
                Container(
                  color: secondaryColor,
                  width: screenWidth * .65,
                  height: screenWidth * .65,
                ),
                SizedBox(height: screenHeight * 0.035),
                Text(
                  "CONGRATULATIONS!",
                  style: TextStyle(
                    fontSize:
                        ((screenHeight + screenWidth) * textAdaptModifier) *
                            25.0,
                    fontWeight: FontWeight.w400,
                    color: secondaryColor,
                  ),
                ),
                Text(
                  "Exercise completed!",
                  style: TextStyle(
                    fontSize:
                        ((screenHeight + screenWidth) * textAdaptModifier) *
                            25.0,
                    fontWeight: FontWeight.w400,
                    color: tertiaryColor,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  children: [
                    titleDescription(
                      context: context,
                      title: "Attempts",
                      description: "test",
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    titleDescription(
                      context: context,
                      title: "Executions",
                      description: "test",
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                titleDescription(
                  context: context,
                  title: "Time",
                  description: "test",
                ),
                SizedBox(height: screenHeight * 0.08),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    fixedSize: Size(
                      screenWidth * 0.25,
                      screenWidth * 0.11,
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Next ($seconds)",
                    style: TextStyle(
                      fontSize: 15.0 * textSizeModif,
                      fontWeight: FontWeight.w400,
                      color: tertiaryColor,
                    ),
                  ),
                ),
                Countdown(
                  seconds: 5,
                  build: (BuildContext context, double time) {
                    // Update your variable every second
                    seconds = (5 - time)
                        .floor(); // Assuming you want to count down from 5

                    return Text("");
                  },
                  interval: Duration(seconds: 1), // Update every second
                  onFinished: () {
                    print('Timer is done!');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
