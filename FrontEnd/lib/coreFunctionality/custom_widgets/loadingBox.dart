import 'package:flutter/material.dart';
import 'package:frontend/coreFunctionality/custom_widgets/dialogBox.dart';
import '../logicFunction/isolateProcessPDV.dart';
import '../mainUISettings.dart';

void loadingBoxTranslating(
  BuildContext context,
  List<dynamic> coordinatesData,
  double progress,
  Function(double) updateProgress,
) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  translateCollectedDatatoTxt(
    coordinatesData,
    updateProgress,
  );

  return showCustomDialog(
    context,
    Container(
      width: 100,
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Please wait...",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
          ),
          SizedBox(
              height:
                  10), // Add some spacing between text and CircularProgressIndicator
          Center(
            child: CircularProgressIndicator(
              value: .5,
              strokeWidth: 8.0,
              color: secondaryColor,
              backgroundColor: mainColor,
              semanticsLabel: 'Loading',
            ),
          ),
          SizedBox(
              height:
                  10), // Add some spacing between CircularProgressIndicator and bottom text
          Text(
            "Processing",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
          ),
        ],
      ),
    ),
  );
}
