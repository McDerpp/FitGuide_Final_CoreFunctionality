import 'package:flutter/material.dart';

import '../modes/inferencing.dart';
import '../pose_detector_view.dart';
import 'package:frontend/coreFunctionality/extraWidgets/customWidgetPDV.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mainUISettings.dart';

class inferenceInfoPage extends StatefulWidget {
  final String imagePreviewPath;
  final String inferencingModelPath;
  final String exerciseName;
  final String numberOfExecution;
  final String bodyPartTarget;
  final String perspective;
  final String userMade;

  final String exerciseNameDescription;
  final int numberOfExecutionDescription;
  final String bodyPartTargetDescription;
  final String perspectiveDescription;
  final String userMadeDescription;

  final String longDescriptionTitle;
  final String longDescription;

  const inferenceInfoPage(
      {super.key,
      required this.imagePreviewPath,
      required this.inferencingModelPath,
      required this.exerciseName,
      required this.numberOfExecution,
      required this.bodyPartTarget,
      required this.perspective,
      required this.userMade,
      required this.exerciseNameDescription,
      required this.numberOfExecutionDescription,
      required this.bodyPartTargetDescription,
      required this.perspectiveDescription,
      required this.userMadeDescription,
      required this.longDescriptionTitle,
      required this.longDescription});

  @override
  State<inferenceInfoPage> createState() => _inferenceInfoPageState();
}

class _inferenceInfoPageState extends State<inferenceInfoPage> {
  void nextPageFunc(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => inferencing(
          model: widget.inferencingModelPath,
          nameOfExercise: widget.exerciseName,
          numberOfExecution: widget.numberOfExecutionDescription,
        ),
      ),
    );
  }

  void help(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PoseDetectorView(
          isInferencing: true,
          model: widget.inferencingModelPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        color: mainColor,
        child: Stack(
          children: [
            Positioned(
              top: screenHeight * 0.02,
              left: screenWidth * 0.02,
              child: buildBackIcon(context),
            ),
            Positioned(
              top: screenHeight * 0.02,
              right: screenWidth * 0.02,
              child: buildHelpIcon(context),
            ),
            Positioned(
              top: screenHeight * 0.08,
              right: screenWidth * 0.05,
              child: Container(
                height: screenHeight * 0.45,
                width: screenWidth * 0.40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      offset:
                          Offset(4.0, 4.0), // Specify the offset of the shadow
                      blurRadius: 5.0, // Specify the blur radius
                      spreadRadius: 1.0, // Specify the spread radius
                    ),
                  ],
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(
                      20.0), // Adjust the radius as needed
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.08,
              left: screenWidth * 0.05,
              child: Container(
                width: 200, // specify the width of your container,
                child: Column(
                  children: [
                    description1(
                      DescTitle: widget.exerciseName,
                      Desc: widget.exerciseNameDescription,
                    ),
                    description1(
                      DescTitle: widget.numberOfExecution,
                      Desc: widget.numberOfExecutionDescription.toString(),
                    ),
                    description1(
                      DescTitle: widget.bodyPartTarget,
                      Desc: widget.bodyPartTargetDescription,
                    ),
                    description1(
                      DescTitle: widget.perspective,
                      Desc: widget.perspectiveDescription,
                    ),
                    description1(
                      DescTitle: widget.userMade,
                      Desc: widget.userMadeDescription,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.55,
              left: screenWidth * 0.05,
              child: longDescription(
                context: context,
                DescTitle: widget.longDescriptionTitle,
                longDesc: widget.longDescription,
              ),
            ),
            Positioned(
              left: screenWidth * .37,
              bottom: screenHeight * .03,
              child: nextPageButton(
                "Get started",
                Colors.red,
                nextPageFunc,
                context,
              ),
            ),
          ],
        ),
      ),
    );
  }
}