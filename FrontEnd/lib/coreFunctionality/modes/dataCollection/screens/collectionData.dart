// import 'dart:core';
// import 'dart:math';

// import 'package:flutter/material.dart';

// import 'dart:async';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:flutter/foundation.dart';

// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:frontend/coreFunctionality/logicFunction/movementCheck.dart';
// import 'package:frontend/coreFunctionality/logicFunction/normalizeCoordinates.dart';
// import 'package:frontend/services/api.dart';
// import 'package:frontend/coreFunctionality/custom_widgets/cwIgnorePose.dart';
// import 'package:frontend/services/provider_collection.dart';
// import 'package:frontend/coreFunctionality/modes/globalStuff/provider/globalVariables.dart';
// import '../../../custom_widgets/executionAnalysis.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
// import 'package:showcaseview/showcaseview.dart';

// import 'package:circular_countdown_timer/circular_countdown_timer.dart';

// import '../../../misc/painters/pose_painter.dart';
// import 'package:frontend/coreFunctionality/misc/poseWidgets/detector_view.dart';
// import '../../../mainUISettings.dart';

// class collectionData extends ConsumerStatefulWidget {
//   const collectionData({
//     super.key,
//   });

//   @override
//   ConsumerState<collectionData> createState() => _collectionDataState();
// }

// class _collectionDataState extends ConsumerState<collectionData> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   String resultAvgFrames = '';

//   // ---------------------inferencing mode variables----------------------------------------------------------
//   // isolate initialization for heavy process
//   RootIsolateToken rootIsolateTokenNormalization = RootIsolateToken.instance!;
//   RootIsolateToken rootIsolateTokenNoMovement = RootIsolateToken.instance!;
//   RootIsolateToken rootIsolateTokenInferencing = RootIsolateToken.instance!;
//   RootIsolateToken rootIsolateTokenTranslating = RootIsolateToken.instance!;

// // IMPORTANT CONFIGURATIONS---------------------------------------------------------------------------------------
//   double requiredDataNum = 50;

// // IMPORTANT CONFIGURATIONS---------------------------------------------------------------------------------------

//   List<double> prevCoordinates = [];
//   List<double> currentCoordinates = [];
//   List<List<double>> inferencingList = [];
//   List<List<double>> tempPrevCurr = [];
//   bool checkFramesCaptured = false;
//   int framesCapturedCtr = 0;

//   String dynamicText = 'no movement \n detected';
//   String dynamicCtr = '0';
//   int execTotalFrames = 0;
//   int numExec = 0;
//   double avgFrames = 0.0;
//   int minFrame = 0;
//   int maxFrame = 0;

//   Map<String, dynamic> inferencingData = {};
//   Map<String, dynamic> checkMovementIsolate = {};

//   List<Map<String, dynamic>> queueNormalizeData = [];
//   List<Map<String, dynamic>> queueMovementData = [];
//   List<Map<String, dynamic>> queueInferencingData = [];
//   int noMovementCtr = 0;
//   int executionStateResult = 0;

//   late Map<String, Color> colorSet1;
//   late Map<String, Color> colorSet2;

//   bool allCoordinatesPresent = false;

//   int buffer = 0;
//   int bufferCtr = 0;

//   late int _seconds;
//   late Timer _timer;

//   List<double> temp = [];
//   // List<dynamic> coordinatesData = [];
//   List<List<List<double>>> coordinatesData = [];

//   bool isSet = true;
//   bool isDataCollected = true;
//   int collectingCtr = 0;
//   double _progress = 0.0;
//   double _sliderValue = 0.0;
//   int _sliderValue2 = 0;
//   double variance = 0;
//   int numFrameVariance = 5;
//   int collectingCtrDelay = 0;

//   late Map<String, Color> headColor;
//   late Map<String, Color> leftArmColor;
//   late Map<String, Color> rightArmColor;
//   late Map<String, Color> leftLegColor;
//   late Map<String, Color> rightLegColor;
//   late Map<String, Color> bodyColor;

//   List<int> ignoreCoordinatesInitialized = [];

//   Color sequenceColor = Colors.yellow;
//   Color averageColor = Colors.yellow;
//   Color varianceColor = Colors.yellow;
//   Color minFrameColor = Colors.yellow;
//   Color maxFrameColor = Colors.yellow;

//   GlobalKey tutorial_deletePrev = GlobalKey();
//   GlobalKey tutorial_pause = GlobalKey();
//   GlobalKey tutorial_deleteAll = GlobalKey();
//   GlobalKey tutorial_ignorePose = GlobalKey();

//   GlobalKey tutorial_allMetrics = GlobalKey();
//   GlobalKey tutorial_avgFrame = GlobalKey();
//   GlobalKey tutorial_variance = GlobalKey();
//   GlobalKey tutorial_avgFrame2 = GlobalKey();
//   GlobalKey tutorial_variance2 = GlobalKey();

//   GlobalKey tutorial_lightingError = GlobalKey();
//   GlobalKey tutorial_poseError = GlobalKey();

//   GlobalKey tutorial_progressBar = GlobalKey();
//   GlobalKey tutorial_submit = GlobalKey();

// // [head,leftArm,rightArm,leftLeg,rightLeg,body]
//   List<bool> igrnoreCoordinatesList = [
//     false,
//     false,
//     false,
//     false,
//     false,
//     false
//   ];

//   // ---------------------collecting data mode variables----------------------------------------------------------

//   // ---------------------countdown variables----------------------------------------------------------

//   final CountDownController _controller = CountDownController();
//   bool nowPerforming = false;
//   bool countDowntoPerform = false;
//   bool checkCountDowntoPerform = false;

//   String dynamicCountDownText = 'Ready';
//   Color dynamicCountDownColor = secondaryColor;

//   // ---------------------collecting data mode variables----------------------------------------------------------

//   @override
//   void initState() {
//     super.initState();
//     getSessionKey().then((value) {
//       ref.watch(sessionKeyProvider.notifier).state = value;
//     });
//     _seconds = 60;
//   }

// // final Future<Interpreter> interpreter = Interpreter.fromAsset(
// //     'assets/models/wholeModel/otestingtesting(loss_0.063)(acc_0.982).tflite');

//   List<List<Pose>> poseQueue = [];
//   List<List<double>> queueNormalizedListQueue = [];

//   final PoseDetector _poseDetector =
//       PoseDetector(options: PoseDetectorOptions());
//   bool _canProcess = true;
//   bool _isBusy = false;
//   CustomPaint? _customPaint;
//   String? _text;
//   var _cameraLensDirection = CameraLensDirection.front;

//   @override
//   void dispose() async {
//     _canProcess = false;
//     // _poseDetector.close();
//     super.dispose();
//   }

//   void _startTimer() {
//     const oneSec = const Duration(seconds: 1);
//     _timer = Timer.periodic(
//       oneSec,
//       (Timer timer) {
//         if (_seconds == 0) {
//           timer.cancel();
//         } else {
//           setState(() {
//             _seconds--;
//           });
//         }
//       },
//     );
//   }

//   Future<void> _processImage(InputImage inputImage) async {
//     // createFile();
//     if (!_canProcess) return;
//     if (_isBusy) return;
//     _isBusy = true;
//     late final List<Pose> poses;
//     // bool noMovement = false;

//     setState(() {
//       _text = '';
//     });

// // // ==================================[isolate function processImage ]==================================
//     try {
//       poses = await _poseDetector.processImage(inputImage);

//       Map<String, dynamic> dataNormalizationIsolate = {
//         'inputImage': poses.first.landmarks.values,
//         'token': rootIsolateTokenNormalization,
//         'coordinatesIgnore': ignoreCoordinatesInitialized,
//       };
//       // for (int ctrCheck = 0;
//       //     ctrCheck >= poses.first.landmarks.values.length;
//       //     ctrCheck++) {
//       //   print(
//       //       "ctrCheckLikelihood ---> ${poses.first.landmarks.values.elementAt(ctrCheck).likelihood}");
//       // }
//       queueNormalizeData.add(dataNormalizationIsolate);
//     } catch (error) {
//       print("error at proces image ---> $error");
//     }

// // // ==================================[isolate function forcoordinatesRelativeBoxIsolate ]==================================
//     bufferCtr++;
//     if (queueNormalizeData.isNotEmpty) {
//       if (bufferCtr >= buffer) {
//         bufferCtr = 0;
//         compute(coordinatesRelativeBoxIsolate, queueNormalizeData.elementAt(0))
//             .then((value) {
//           queueNormalizeData.removeAt(0);
//           tempPrevCurr.add(value['translatedCoordinates']);

//           if (nowPerforming == true) {
//             temp = value['translatedCoordinates'];
//           }

//           setState(() {
//             allCoordinatesPresent = value['allCoordinatesPresent'];
//           });

//           if (tempPrevCurr.length > 1) {
//             prevCoordinates = tempPrevCurr.elementAt(0);
//             currentCoordinates = tempPrevCurr.elementAt(1);

//             Map<String, dynamic> checkMovementIsolate = {
//               'prevCoordinates': prevCoordinates,
//               'currentCoordinates': currentCoordinates,
//               'token': rootIsolateTokenNoMovement,
//             };
//             queueMovementData.add(checkMovementIsolate);
//             tempPrevCurr.removeAt(0);
//           }
//         }).catchError((error) {
//           print("Error at coordinate relative ---> $error");
//         });
//       } else {
//         queueNormalizeData.removeAt(0);
//         print("buffering...");
//       }
//     }

// // // ==================================[isolate function forcoordinatesRelativeBoxIsolate ]==================================

// // // ==================================[isolate function checkMovement ]==================================
//     if (queueMovementData.isNotEmpty) {
//       compute(checkMovement, queueMovementData.elementAt(0))
//           .then((value) async {
//         queueMovementData.removeAt(0);

//         if (value == true && checkFramesCaptured == false) {
//           checkFramesCaptured = true;

//           if (nowPerforming == true) {
//             isDataCollected = true;
//             if (inferencingList.isNotEmpty) {
//               executionStateResult = 2;

//               setState(() {
//                 executionStateResult = 2;
//               });
//               dynamicCountDownText = 'collected';
//               dynamicCountDownColor = secondaryColor;
//               coordinatesData.add(inferencingList);

//               execTotalFrames = execTotalFrames + inferencingList.length;

//               if (minFrame == 0) {
//                 minFrame = inferencingList.length;
//                 ref.read(minFrameState.notifier).state = minFrame;
//               }

//               if (minFrame > inferencingList.length) {
//                 minFrame = inferencingList.length;
//                 ref.read(minFrameState.notifier).state = minFrame;
//                 print("minFrame ---> $minFrame ");
//               }

//               if (maxFrame < inferencingList.length) {
//                 maxFrame = inferencingList.length;
//                 ref.read(maxFrameState.notifier).state = maxFrame;
//                 print("maxFrame ---> $maxFrame ");
//               }

//               numExec++;
//             }

//             inferencingList = [];
//           }
//           // }
//         } else if (value == false) {
//           if (nowPerforming == true) {
//             executionStateResult = 1;

//             setState(() {
//               executionStateResult = 1;
//             });
//             dynamicCountDownText = 'collecting';
//             dynamicCountDownColor = Colors.blue;
//             checkFramesCaptured = false;

//             if (temp.isNotEmpty) {
//               inferencingList.add(temp);
//             }
//             isDataCollected = false;
//             temp = [];
//           }
//         }

//         if (value == true) {
//           // -----------------checking for movement before executing for collecting data--------------------------------------
//           if (nowPerforming == false) {
//             if (countDowntoPerform == false) {
//               _controller.start();
//               countDowntoPerform = true;
//               dynamicCountDownText = 'Perform';
//             }
//           }

//           if (_controller.getTime().toString() == "3" &&
//               nowPerforming == false) {
//             nowPerforming = true;
//           }

//           noMovementCtr = 0;

//           setState(
//             () {
//               dynamicText = 'no movement detected';
//               try {} catch (error) {
//                 minFrame = 0;
//               }

//               dynamicCtr = noMovementCtr.toString();
//               try {
//                 avgFrames = execTotalFrames / numExec;
//                 resultAvgFrames = avgFrames.toStringAsFixed(2);
//                 avgFrames = double.parse(resultAvgFrames);
//                 ref.read(averageFrameState.notifier).state = avgFrames;

//                 if (avgFrames <= ref.watch(averageThresholdBad)) {
//                   averageColor = Colors.red;
//                 } else if (avgFrames >= ref.watch(averageThresholdBad) &&
//                     avgFrames <= ref.watch(averageThresholdIdeal)) {
//                   averageColor = Colors.orange;
//                 } else if (avgFrames >= ref.watch(averageThresholdIdeal)) {
//                   averageColor = Colors.green;
//                 }
//                 ref.read(averageColorState.notifier).state = averageColor;
//               } catch (error) {
//                 avgFrames = 0;
//               }

//               try {
//                 if (minFrame <= ref.watch(minFrameThresholdBad)) {
//                   minFrameColor = Colors.red;
//                 } else if (minFrame >= ref.watch(minFrameThresholdBad) &&
//                     minFrame <= ref.watch(minFrameThresholdIdeal)) {
//                   minFrameColor = Colors.orange;
//                 } else if (minFrame >= ref.watch(minFrameThresholdIdeal)) {
//                   minFrameColor = Colors.green;
//                 }
//                 ref.read(minFrameColorState.notifier).state = minFrameColor;
//               } catch (error) {
//                 minFrame = 0;
//               }

//               try {
//                 if (maxFrame <= ref.watch(maxFrameThresholdBad)) {
//                   maxFrameColor = Colors.red;
//                 } else if (maxFrame >= ref.watch(maxFrameThresholdBad) &&
//                     maxFrame <= ref.watch(maxFrameThresholdIdeal)) {
//                   maxFrameColor = Colors.orange;
//                 } else if (maxFrame >= ref.watch(maxFrameThresholdIdeal)) {
//                   maxFrameColor = Colors.green;
//                 }
//                 ref.read(maxFrameColorState.notifier).state = maxFrameColor;
//               } catch (error) {
//                 maxFrame = 0;
//               }
//             },
//           );
//         } else {
//           // -----------------checking for movement before executing for collecting data--------------------------------------

//           if (nowPerforming == false) {
//             if (countDowntoPerform == true) {
//               _controller.reset();
//               countDowntoPerform = false;
//             }
//           }
//           // -----------------------------------------------------------------------------------------------------------

//           setState(() {
//             dynamicText = 'movement detected';
//             dynamicCtr = noMovementCtr.toString();
//           });
//         }
//       }).catchError((error) {
//         print("Error at checkMovement ---> $error");
//       });
//     }

//     if (inputImage.metadata?.size != null &&
//         inputImage.metadata?.rotation != null) {
//       final painter = PosePainter(
//         poses,
//         inputImage.metadata!.size,
//         inputImage.metadata!.rotation,
//         _cameraLensDirection,
//         executionStateResult,
//       );
//       _customPaint = CustomPaint(painter: painter);
//     } else {
//       _text = 'Poses found: ${poses.length}\n\n';

//       _customPaint = null;
//     }
//     _isBusy = false;
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   void undoExecution(int undoTimes) {
//     int temp = 0;
//     int tempexecTotalFrames = execTotalFrames;
//     for (int ctr = 0; ctr < undoTimes; ctr++) {
//       if (coordinatesData.isNotEmpty) {
//         tempexecTotalFrames =
//             (tempexecTotalFrames - coordinatesData.last.length).toInt();
//         coordinatesData.removeLast();
//         numExec--;
//       }
//     }

//     setState(() {
//       nowPerforming = false;

//       execTotalFrames = tempexecTotalFrames;
//       avgFrames = execTotalFrames / numExec;
//       resultAvgFrames = avgFrames.toStringAsFixed(2);
//       avgFrames = double.parse(resultAvgFrames);
//     });
//   }

//   void simulateCollectData() {
//     print("simulating collection of data");
//     for (int ctr = 0; ctr <= 5; ctr++) {
//       inferencingList = [];
//       for (int ctr1 = 0; ctr1 <= 10; ctr1++) {
//         temp = [];
//         for (int ctr2 = 0; ctr2 <= 66; ctr2++) {
//           temp.add(0.1111111111);
//         }
//         inferencingList.add(temp);
//       }
//       print("adding --> $numExec");
//       coordinatesData.add(inferencingList);
//       setState(() {
//         numExec++;
//       });
//     }
//     print("translating to txt");
//     Map<String, dynamic> translatingIsolate = {
//       'coordinates': coordinatesData,
//       'token': rootIsolateTokenTranslating,
//     };

//     // compute(translateCollectedDatatoTxt2, translatingIsolate);
//     print("translated");
//   }

//   bool isChecked = false;

//   Future openDialog(BuildContext context, Widget content) => showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('setState in Dialog?'),
//           content: content,
//           actions: [
//             TextButton(
//               child: const Text('SUBMIT'),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ],
//         ),
//       );

//   Map<String, Color>? coordinatesIgnoreState(int index) {
//     undoExecution(coordinatesData.length);

//     if (igrnoreCoordinatesList.elementAt(index) == false) {
//       igrnoreCoordinatesList[index] = true;
//       return colorSet1;
//     } else {
//       igrnoreCoordinatesList[index] = false;
//       return colorSet2;
//     }
//   }

//   Widget timerCountDown(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     double textSizeModif = (screenHeight + screenWidth) * textAdaptModifier;
//     return Align(
//         alignment: Alignment(0.0, -0.2),
//         child: CircularCountDownTimer(
//           duration: currentDuration,
//           initialDuration: 0,
//           controller: _controller,
//           width: MediaQuery.of(context).size.width / 1.5,
//           height: MediaQuery.of(context).size.height / 1.5,
//           ringColor: Colors.transparent,
//           ringGradient: null,
//           fillColor: Colors.white,
//           fillGradient: null,
//           backgroundColor: Colors.transparent,
//           backgroundGradient: null,
//           strokeWidth: screenWidth * .10,
//           strokeCap: StrokeCap.round,
//           textStyle: TextStyle(
//               fontSize: 50.0 * textSizeModif,
//               color: Colors.white,
//               fontWeight: FontWeight.bold),
//           textFormat: CountdownTextFormat.S,
//           isReverse: false,
//           isReverseAnimation: true,
//           isTimerTextShown: true,
//           autoStart: false,
//           onStart: () {
//             print('Countdown Started');
//           },
//           onComplete: () {
//             print('Countdown Ended');
//           },
//           onChange: (String timeStamp) {
//             print('Countdown Changed $timeStamp');
//           },
//           timeFormatterFunction: (defaultFormatterFunction, duration) {
//             if (nowPerforming == true) {
//               return dynamicCountDownText;
//             } else {
//               return Function.apply(defaultFormatterFunction, [duration]);
//             }
//           },
//         )
//         // countdownTimer(context, dynamicCountDownText,
//         //     dynamicCountDownColor, _controller)
//         );
//   }

//   Widget noDisplay() {
//     return Container(
//       width: 0,
//       height: 0,
//       color: Colors.transparent,
//     );
//   }

//   Widget displayErrorPose(BuildContext context, double opacity) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return IconButton(
//       icon: Icon(
//         Icons.accessibility_new_sharp,
//         color: secondaryColor.withOpacity(opacity),
//         size: screenWidth * 0.08,
//       ),
//       onPressed: () {
//         setState(() {
//           nowPerforming = false;
//         });
//       },
//     );
//   }

//   Widget displayErrorPose2(BuildContext context, double opacity) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return IconButton(
//       icon: Icon(
//         Icons.lightbulb_circle,
//         color: ref.watch(secondaryColorState).withOpacity(opacity),
//         size: screenWidth * 0.08,
//       ),
//       onPressed: () {
//         setState(() {
//           // nowPerforming = false;
//         });
//       },
//     );
//   }

//   void testrecord(int value) {
//     ref.read(recording.notifier).state = value;
//     print("test record!---> $value");
//   }

//   @override
//   Widget build(
//     BuildContext context,
//   ) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     double textSizeModif = (screenHeight + screenWidth) * textAdaptModifier;
//     Widget displayCountdownTimer;
//     Widget displayError1;
//     Widget displayError2;
//     buffer = ref.watch(bufferProvider);

//     Color color1 = ref.watch(mainColorState);
//     Color color2 = ref.watch(secondaryColorState);
//     Color color3 = ref.watch(tertiaryColorState);

//     var textSizeModifierSet = ref.watch(textSizeModifier);
//     var textSizeModifierSetIndividual = textSizeModifierSet["smallText"]!;

//     // colorSet1 = {
//     //   "mainColor": color1,
//     //   "secondaryColor": color2,
//     //   "tertiaryColor": color3,
//     // };

//     // colorSet2 = {
//     //   "mainColor": color1,
//     //   "secondaryColor": color3,
//     //   "tertiaryColor": color2,
//     // };

//     // headColor = colorSet1;
//     // leftArmColor = colorSet1;
//     // rightArmColor = colorSet1;
//     // leftLegColor = colorSet1;
//     // rightLegColor = colorSet1;
//     // bodyColor = colorSet1;

//     final luminanceValue = ref.watch(luminanceProvider);

//     if (nowPerforming == true) {
//       displayCountdownTimer = noDisplay();
//     } else {
//       displayCountdownTimer = timerCountDown(context);
//     }

//     if (allCoordinatesPresent == false) {
//       displayError1 = displayErrorPose(context, 1);
//     } else {
//       displayError1 = displayErrorPose(context, 0.0);
//     }

//     if (luminanceValue <= 50.0) {
//       displayError2 = displayErrorPose2(context, 1);
//     } else {
//       displayError2 = displayErrorPose2(context, 0.0);
//     }
//     return ShowCaseWidget(
//       builder: Builder(
//         builder: (BuildContext context) {
//           return Scaffold(
//             body: Stack(
//               children: [
//                 // Container(
//                 //   color: Colors.amber,
//                 //   width: screenWidth,
//                 //   height: screenHeight,
//                 // ),

//                 Align(
//                   alignment: Alignment.topCenter,
//                   // Set top to 0 to cover the entire screen from the top
//                   child: Container(
//                     width: screenWidth, // Set a specific width
//                     height:
//                         screenHeight, // Set a specific height or use constraints
//                     child: DetectorView(
//                       title: 'Pose Detector',
//                       customPaint: _customPaint,
//                       text: _text,
//                       onImage: _processImage,
//                       initialCameraLensDirection: _cameraLensDirection,
//                       onCameraLensDirectionChanged: (value) =>
//                           _cameraLensDirection = value,
//                     ),
//                   ),
//                 ),

//                 // Positioned(
//                 //   bottom: screenHeight * 0.17,
//                 //   child: Container(
//                 //     color: Colors.amber,
//                 //     width: screenWidth,
//                 //     height: screenHeight,
//                 //   ),
//                 // ),
//                 displayCountdownTimer,
//                 // Positioned(
//                 //   bottom: screenHeight * .025,
//                 //   left: screenWidth * .07,
//                 //   child:
//                 // ),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Container(
//                     height: screenHeight * 0.11,
//                     width: screenWidth,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(screenHeight * .02),
//                         topRight: Radius.circular(screenHeight * .02),
//                       ),
//                       color: mainColor,
//                     ),
//                   ),
//                 ),

// // --------------------------------------------------------------------------[BACK ARROW]
//                 Align(
//                   alignment: Alignment(-1.0, 0.78),
//                   child: IconButton(
//                     icon: Icon(
//                       Icons.arrow_back,
//                       color: tertiaryColor,
//                     ),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ),
// // --------------------------------------------------------------------------[HELP BUTTON]
//                 // Align(
//                 //   alignment: Alignment(1.0, 0.78),
//                 //   child: const instructionPage(
//                 //     isInferencing: false,
//                 //   ),
//                 // ),

//                 Align(
//                   alignment: Alignment(1.0, 0.78),
//                   child: IconButton(
//                     icon: Icon(
//                       Icons.question_mark,
//                       color: tertiaryColor,
//                     ),
//                     onPressed: () {
//                       ShowCaseWidget.of(context).startShowCase([
//                         tutorial_deletePrev,
//                         tutorial_pause,
//                         tutorial_deleteAll,
//                         tutorial_ignorePose,
//                         tutorial_avgFrame,
//                         tutorial_variance,
//                         tutorial_avgFrame2,
//                         tutorial_variance2,
//                         tutorial_lightingError,
//                         tutorial_poseError,
//                         tutorial_progressBar,
//                         tutorial_submit
//                       ]);
//                     },
//                   ),
//                 ),

// // --------------------------------------------------------------------------[COUNTER]

//                 Align(
//                   alignment: Alignment(0.0, -0.94),
//                   child: Container(
//                     width: screenWidth * 0.83,
//                     height: screenHeight * 0.05,
//                     decoration: BoxDecoration(
//                       color: mainColor.withOpacity(0.75),
//                       borderRadius: BorderRadius.circular(screenWidth * 0.03),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           width: screenWidth * 0.80,
//                           height: screenHeight * 0.017,
//                           decoration: BoxDecoration(
//                             color: tertiaryColor,
//                             borderRadius:
//                                 BorderRadius.circular(screenWidth * 0.07),
//                           ),
//                           child: Showcase(
//                             key: tutorial_progressBar,
//                             title: 'Progress Bar',
//                             description:
//                                 'This indicates whether you whole body is present directly at the camera(Exceptions on parts of the body you ignored).',
//                             child: ClipRRect(
//                               borderRadius:
//                                   BorderRadius.circular(screenWidth * 0.07),
//                               child: LinearProgressIndicator(
//                                 value: numExec > requiredDataNum
//                                     ? requiredDataNum
//                                     : numExec / requiredDataNum,
//                                 backgroundColor: tertiaryColor.withOpacity(0.5),
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                     secondaryColor.withOpacity(0.5)),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

// // --------------------------------------------------------------------------[ERROR NOTIFICATION]


//                 Positioned(
//                   bottom: screenHeight * 0.12,
//                   child: Container(
//                     width: screenWidth,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Showcase(
//                           key: tutorial_avgFrame,
//                           title: 'Average Frame Indicator',
//                           description:
//                               'This indicates the average frames collected',
//                           child: Container(
//                             height: screenWidth * 0.035,
//                             width: screenWidth * 0.09,
//                             decoration: BoxDecoration(
//                               color: averageColor,
//                               borderRadius: BorderRadius.circular(30.0),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           width: screenWidth * 0.015,
//                         ),
//                         Showcase(
//                           key: tutorial_variance,
//                           title: 'Variance Frame Indicator',
//                           description:
//                               'This indicates how different each executions you have done.',
//                           child: Container(
//                             height: screenWidth * 0.035,
//                             width: screenWidth * 0.09,
//                             decoration: BoxDecoration(
//                               color: varianceColor,
//                               borderRadius: BorderRadius.circular(30.0),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           width: screenWidth * 0.015,
//                         ),
//                         Showcase(
//                           key: tutorial_avgFrame2,
//                           title: 'Minimum Frame Indicator',
//                           description:
//                               'This indicates your lowest frame out of all executions which means your fastest execution.',
//                           child: Container(
//                             height: screenWidth * 0.035,
//                             width: screenWidth * 0.09,
//                             decoration: BoxDecoration(
//                               color: minFrameColor,
//                               borderRadius: BorderRadius.circular(30.0),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           width: screenWidth * 0.015,
//                         ),
//                         Showcase(
//                           key: tutorial_variance2,
//                           title: 'Maximum Frame Indicator',
//                           description:
//                               'This indicates your highest frame out of all executions which means your slowest execution.',
//                           child: Container(
//                             height: screenWidth * 0.035,
//                             width: screenWidth * 0.09,
//                             decoration: BoxDecoration(
//                               color: maxFrameColor,
//                               borderRadius: BorderRadius.circular(30.0),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

// // --------------------------------------------------------------------------[FRAME DETAIL CONTAINER 2]
//                 Positioned(
//                   bottom: screenHeight * 0.03,
//                   left: screenWidth * 0.05,
//                   height: screenHeight * 0.05,
//                   child: Row(
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           color: tertiaryColor.withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(
//                               30.0), // Adjust the radius as needed
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Showcase(
//                               key: tutorial_deletePrev,
//                               title: 'Delete Previous',
//                               description:
//                                   'Press this to delete recent collected data',
//                               child: IconButton(
//                                 icon: Icon(
//                                   Icons.restart_alt,
//                                   color: tertiaryColor,
//                                   size: screenWidth * .06, //
//                                 ),
//                                 onPressed: () {
//                                   undoExecution(1);
//                                 },
//                               ),
//                             ),
//                             Showcase(
//                               key: tutorial_pause,
//                               title: 'Pause',
//                               description:
//                                   'Press this to pause the collection of data',
//                               child: IconButton(
//                                 icon: Icon(
//                                   Icons.pause,
//                                   color: tertiaryColor,
//                                   size: screenWidth * .06, //
//                                 ),
//                                 onPressed: () {
//                                   simulateCollectData();
//                                   // setState(() {
//                                   //   nowPerforming = false;
//                                   // });
//                                 },
//                               ),
//                             ),
//                             Showcase(
//                               key: tutorial_deleteAll,
//                               title: 'Delete All',
//                               description:
//                                   'Press this to delete all data collected',
//                               child: IconButton(
//                                 icon: Icon(
//                                   Icons.delete_forever,
//                                   color: tertiaryColor,
//                                   size: screenWidth * .06, //
//                                 ),
//                                 onPressed: () {
//                                   undoExecution(coordinatesData.length);
//                                 },
//                               ),
//                             ),
//                             Showcase(
//                               key: tutorial_ignorePose,
//                               title: 'Ignore Pose',
//                               description:
//                                   'Press this to have the option to ignore certain parts of your body from being collected or being detected. This is usually used if a part of your body is behind something or not directly at the camera',
//                               // child: customDialogEA(
//                               //   iconSize: screenWidth * .06,
//                               //   igrnoreCoordinatesList: igrnoreCoordinatesList,
//                               // ),
//                               child: cwIgnorePose(),
//                               //
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 Positioned(
//                   bottom: screenHeight * 0.015,
//                   right: screenWidth * 0.05,
//                   child: Showcase(
//                     key: tutorial_submit,
//                     title: 'Submit',
//                     description:
//                         'After collecting data submit it to get a data analysis and proceed to the next part',
//                     child: Container(
//                       child: cwDataAnalysis(
//                         execCount: numExec,
//                         data: coordinatesData,
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Align(
//                 //   alignment: Alignment(0.0, 0.0),
//                 //   child: Row(
//                 //     crossAxisAlignment: CrossAxisAlignment.center,
//                 //     children: [
//                 //       IconButton(
//                 //         icon: Icon(
//                 //           Icons.stop,
//                 //           color: Colors.red,
//                 //           size: screenWidth * .06, //
//                 //         ),
//                 //         onPressed: () => testrecord(3),
//                 //       ),
//                 //       IconButton(
//                 //         icon: Icon(
//                 //           Icons.start,
//                 //           color: Colors.red,
//                 //           size: screenWidth * .06, //
//                 //         ),
//                 //         onPressed: () => testrecord(1),
//                 //       ),
//                 //     ],
//                 //   ),
//                 // )
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
