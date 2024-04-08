import 'package:flutter/material.dart';
import 'package:frontend/coreFunctionality/modes/dataCollection/screens/collectionDataP2.dart';
import 'package:frontend/coreFunctionality/modes/dataCollection/screens/collectionDataP3.dart';
import 'package:frontend/coreFunctionality/modes/dataCollection/screens/collectionDataP4.dart';
// import 'package:frontend/coreFunctionality/modes/dataCollection/screens/collectionData(cleaning).dart';

import 'package:frontend/coreFunctionality/modes/inferencing/inferencing(seamless).dart';
import 'coreFunctionality/modes/dataCollection/screens/collectionData.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'coreFunctionality/modes/dataCollection/screens/collectionDataP1.dart';
import 'coreFunctionality/modes/inferencing/inferencing.dart';
import 'coreFunctionality/modes/inferencing/inferencingP1.dart';
import 'providers.dart';

// import 'package:frontend/coreFunctionality/modes/dataCollection/screens/collectionDataP1.dart';
// import 'package:frontend/coreFunctionality/modes/dataCollection/screens/collectionDataP3.dart';
// import 'package:frontend/coreFunctionality/modes/dataCollection/collectionDatap2.dart';
// import 'package:showcaseview/showcaseview.dart';
// import 'coreFunctionality/instructionPage/instructionPage.dart';
// import 'coreFunctionality/instructionPage/inferencingInfoPage.dart';
// import 'coreFunctionality/resultsPage/inferencingResults.dart';
// import 'package:frontend/coreFunctionality/modes/inferencing/inferencing.dart';
// import 'coreFunctionality/instructionPage/collecting_data_instruction.dart';
// import 'coreFunctionality/pose_detector_view.dart';
// import 'package:frontend/coreFunctionality/modes/dataCollection/widgets/cwReview.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> exerciseDetail1 = {
      'nameOfExercise': "Oblique Twist",
      'restDuration': 15,
      'setsNeeded': 2,
      'numberOfExecution': 2,
      'modelPath': 'assets/models/wholeModel/obliqueTwistV3.tflite',
      'videoPath': 'FrontEnd/assets/videos/jumpNjacksVid.mp4',
      // still need to implement extraction of ignored coordinates when collecting data!
      'ignoredCoordinates': ["left_arm", "left_leg"],
      'inputNum': 8,
    };

    Map<String, dynamic> exerciseDetail2 = {
      'nameOfExercise': "Jump and Jacks",
      'restDuration': 15,
      'setsNeeded': 2,
      'numberOfExecution': 2,
      'modelPath':
          'assets/models/wholeModel/converted_model_whole_model4782(loss_0.005)(acc_0.999).tflite',
      'videoPath': 'assets/videos/jumpNjacksVid.mp4',
      'ignoredCoordinates': ["left_arm", "left_leg"],
      'inputNum': 9,
    };

    List<Map<String, dynamic>> exerciseProgram1 = [];
    exerciseProgram1.add(exerciseDetail1);
    exerciseProgram1.add(exerciseDetail2);

    return Scaffold(
        body: Table(
      border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => inferencingSeamless(
                              exerciseList: exerciseProgram1,
                            )),
                  );
                },
                child: const Text("Inferencing")),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => collectionData(),
                    ),
                  );
                },
                child: const Text("Collect Data "))
          ],
        ),
      ],
    )

        // body: collectionData(),
        );
  }
}
