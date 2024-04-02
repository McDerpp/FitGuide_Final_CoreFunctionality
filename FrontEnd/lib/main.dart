import 'package:flutter/material.dart';

import 'package:frontend/coreFunctionality/modes/inferencing/inferencing(seamless).dart';
import 'coreFunctionality/modes/dataCollection/screens/collectionData.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// THIS IS WORKING!
// 'assets/models/wholeModel/converted_model_whole_model3637(loss_0.148)(acc_0.947).tflite',

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
      'nameOfExercise': "Exercise 1",
      'restDuration': 30,
      'setsNeeded': 1,
      'numberOfExecution': 3,
      'modelPath':
          'assets/models/wholeModel/converted_model_whole_model3637(loss_0.148)(acc_0.947).tflite',
      'videoPath': 'plachonder.mp4',
      // still need to implement extraction of ignored coordinates when collecting data!
      'ignoredCoordinates': ["left_arm", "left_leg"]
    };

    Map<String, dynamic> exerciseDetail2 = {
      'nameOfExercise': "Exercise 2",
      'restDuration': 30,
      'setsNeeded': 4,
      'numberOfExecution': 3,
      'modelPath':
          'assets/models/wholeModel/converted_model_whole_model5530(loss_0.171)(acc_0.945).tflite',
      'videoPath': 'plachonder.mp4',
      'ignoredCoordinates': ["left_arm", "left_leg"]
    };

    Map<String, dynamic> exerciseDetail3 = {
      'nameOfExercise': "Exercise 3",
      'restDuration': 30,
      'setsNeeded': 2,
      'numberOfExecution': 2,
      'modelPath':
          'assets/models/wholeModel/jumpNjacks(4-2-24).tflite',
      'videoPath': 'plachonder.mp4',
      'ignoredCoordinates': ["left_arm", "left_leg"]
    };

    List<Map<String, dynamic>> exerciseProgram1 = [];
    exerciseProgram1.add(exerciseDetail3);

    exerciseProgram1.add(exerciseDetail2);

    exerciseProgram1.add(exerciseDetail1);

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
                      ),
                      // const collectionDataP2(),
                    ),
                  );
                },
                child: const Text("Collect data")),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => collectionData(),
                    ),
                  );
                },
                child: const Text("inferencing"))
          ],
        ),
      ],
    )

        // body: collectionData(),
        );
  }
}



// DONT MIND THIS
      // body:inferencing(
      //   restDuration: 30,
      //   setsNeeded: 3,
      //   model:
      //       'assets/models/wholeModel/converted_model_whole_model3637(loss_0.148)(acc_0.947).tflite',
      //   nameOfExercise: "TESTING",
      //   numberOfExecution: 2,
      // ),

      // body: inferencingSeamless(
      //   restDuration: 30,
      //   setsNeeded: 3,
      //   model:
      //       'assets/models/wholeModel/converted_model_whole_model3637(loss_0.148)(acc_0.947).tflite',
      //   nameOfExercise: "TESTING",
      //   numberOfExecution: 2,
      // ),

      // body: VideoPreviewScreen(
      //     videoPath:
      //         "/data/user/0/com.example.fitguidef/cache/REC63460379465949808.mp4")




