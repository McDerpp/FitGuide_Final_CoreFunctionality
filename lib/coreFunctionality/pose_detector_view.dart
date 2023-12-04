// import 'dart:async';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:path_provider/path_provider.dart';

// // Note: heavy imports...may cause lots of load times in between running
// import 'package:flutter/services.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

// // UI related imports
// import 'package:circular_countdown_timer/circular_countdown_timer.dart';

// // file imports
// import 'misc/painters/pose_painter.dart';
// import 'package:frontend/coreFunctionality/misc/poseWidgets/detector_view.dart';
// import 'logicFunction/isolateProcessPDV.dart';
// import 'extraWidgets/customWidgetPDV.dart';
// import 'mainUISettings.dart';
// import 'logicFunction/processLogic.dart';

// class PoseDetectorView extends StatefulWidget {
//   final bool isInferencing;
//   final String model;

//   PoseDetectorView({
//     super.key,
//     required this.isInferencing,
//     this.model = '',
//   });

//   @override
//   State<StatefulWidget> createState() => _PoseDetectorViewState();
// }

// // NOTE TO SELF -> improve variable initialization(might take up lots of memory since not all variables will be used in one go(inferencing/collectingData))

// class _PoseDetectorViewState extends State<PoseDetectorView> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   String resultAvgFrames = '';

//   // ---------------------inferencing mode variables----------------------------------------------------------
//   // isolate initialization for heavy process
//   RootIsolateToken rootIsolateTokenNormalization = RootIsolateToken.instance!;
//   RootIsolateToken rootIsolateTokenNoMovement = RootIsolateToken.instance!;
//   RootIsolateToken rootIsolateTokenInferencing = RootIsolateToken.instance!;

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

//   Map<String, dynamic> inferencingData = {};
//   Map<String, dynamic> checkMovementIsolate = {};

//   List<Map<String, dynamic>> queueNormalizeData = [];
//   List<Map<String, dynamic>> queueMovementData = [];
//   List<Map<String, dynamic>> queueInferencingData = [];
//   int noMovementCtr = 0;
//   // ---------------------inferencing mode variables----------------------------------------------------------
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
//   // ---------------------countdown variables----------------------------------------------------------
//   late int _seconds;
//   late Timer _timer;
//   // ---------------------countdown variables----------------------------------------------------------
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
//   // ---------------------collecting data mode variables----------------------------------------------------------
//   List<double> temp = [];
//   List<dynamic> coordinatesData = [];
//   bool isSet = true;
//   bool isDataCollected = true;
//   int collectingCtr = 0;
//   double _progress = 0.0;
//   // ---------------------collecting data mode variables----------------------------------------------------------
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
//   // ---------------------countdown variables----------------------------------------------------------

//   final CountDownController _controller = CountDownController();
//   bool nowPerforming = false;
//   bool countDowntoPerform = false;
//   bool checkCountDowntoPerform = false;

//   String dynamicCountDownText = 'Ready';
//   Color dynamicCountDownColor = secondaryColor;

//   // ---------------------collecting data mode variables----------------------------------------------------------
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
//   @override
//   void initState() {
//     super.initState();
//     try {
//       paddingInitialize();
//       modelInitialize(widget.model);
//     } catch (error) {
//       print("error at initialization of inferencing --> $error");
//     }
//     // if (widget.isInferencing == false) {}
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
//   var _cameraLensDirection = CameraLensDirection.back;

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

// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // // ==================================[isolate function processImage ]==================================
//     try {
//       poses = await _poseDetector.processImage(inputImage);
//       Map<String, dynamic> dataNormalizationIsolate = {
//         'inputImage': poses.first.landmarks.values,
//         'token': rootIsolateTokenNormalization,
//       };
//       print('relative attempt1123231 --> ${poses.first.landmarks.values}');
//       queueNormalizeData.add(dataNormalizationIsolate);
//       print(
//           'relative attempt11 --> ${queueNormalizeData.elementAt(0)['inputImage']}');
//       print(
//           'relative attempt222 --> ${queueNormalizeData.elementAt(0)['token']}');
//     } catch (error) {
//       print("error at proces image ---> $error");
//     }

// // // ==================================[isolate function processImage ]==================================
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // // ==================================[isolate function forcoordinatesRelativeBoxIsolate ]==================================
//     if (queueNormalizeData.isNotEmpty) {
//       compute(coordinatesRelativeBoxIsolate, queueNormalizeData.elementAt(0))
//           .then((value) {
//         queueNormalizeData.removeAt(0);
//         tempPrevCurr.add(value);
//         // inferencingList.add(value);
//         if (nowPerforming == true) {
//           temp = value;
//           // temp.add(value);
//         }
//         if (tempPrevCurr.length > 1) {
//           prevCoordinates = tempPrevCurr.elementAt(0);
//           currentCoordinates = tempPrevCurr.elementAt(1);

//           Map<String, dynamic> checkMovementIsolate = {
//             'prevCoordinates': prevCoordinates,
//             'currentCoordinates': currentCoordinates,
//             'token': rootIsolateTokenNoMovement,
//           };
//           queueMovementData.add(checkMovementIsolate);
//           tempPrevCurr.removeAt(0);
//         }
//       }).catchError((error) {
//         print("Error at coordinate relative ---> $error");
//       });
//     }
//     // relativeBoxIsolateFunction(
//     //   queueNormalizeData: queueNormalizeData,
//     //   tempPrevCurr: tempPrevCurr,
//     //   nowPerforming: nowPerforming,
//     //   prevCoordinates: prevCoordinates,
//     //   temp: temp,
//     //   currentCoordinates: currentCoordinates,
//     //   rootIsolateTokenNoMovement: rootIsolateTokenNoMovement,
//     //   queueMovementData: queueNormalizeData,
//     //   checkMovementIsolate: checkMovementIsolate,
//     // );
// // // ==================================[isolate function forcoordinatesRelativeBoxIsolate ]==================================
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // // ==================================[isolate function checkMovement ]==================================
//     if (queueMovementData.isNotEmpty) {
//       compute(checkMovement, queueMovementData.elementAt(0))
//           .then((value) async {
//         queueMovementData.removeAt(0);
//         print("isolateNoMovementResult ---> $value");

//         if (value == true && checkFramesCaptured == false) {
//           checkFramesCaptured = true;
//           framesCapturedCtr++;
//           print("frames captured --> $framesCapturedCtr");
//           // execTotalFrames = execTotalFrames + framesCapturedCtr;
//           framesCapturedCtr = 0;

//           if (nowPerforming == true) {
//             collectingCtr++;
//             if (collectingCtr >= collectingCtrDelay) {
//               collectingCtr = 0;
//               print("stopping");
//               isDataCollected = true;
//               if (inferencingList.isNotEmpty) {
//                 dynamicCountDownText = 'collected';
//                 dynamicCountDownColor = secondaryColor;
//                 coordinatesData.add(inferencingList);
//                 print(
//                     "INFERENCING LIST CHECKING LEN --> ${inferencingList.length}");
//                 execTotalFrames = execTotalFrames + inferencingList.length;
//                 print("execTotalFrames --> $execTotalFrames");

//                 inferencingData = {
//                   'coordinatesData': inferencingList,
//                   'token': rootIsolateTokenInferencing,
//                 };

//                 numExec++;

//                 queueInferencingData.add(inferencingData);

//                 print(
//                     "queueInferencingData.length --> $queueInferencingData.length");
//               }
//               print("current count---> ${coordinatesData.length}");
//               inferencingList = [];
//               print(
//                   "collecting--- ${isDataCollected} -------1---- ${nowPerforming}");
//             }
//           }
//         } else if (value == false) {
//           if (nowPerforming == true) {
//             dynamicCountDownText = 'collecting';
//             dynamicCountDownColor = Colors.blue;
//             checkFramesCaptured = false;

//             // inferencingList.add(temp.elementAt(0));
//             if (temp.isNotEmpty) {
//               inferencingList.add(temp);
//             }
//             isDataCollected = false;
//             print("collecting coordinates");
//             print(
//                 "collecting--- ${isDataCollected} ------2----- ${nowPerforming}");
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
//           //---------------after not moving for 3 sec-------------------------

//           // execTotalFrames = execTotalFrames + noMovementCtr;

//           // Map<String, dynamic> inferencingData = {
//           //   'inferencingData': inferencingList.sublist(0, noMovementCtr),
//           //   'token': rootIsolateTokenInferencing,
//           // };
//           noMovementCtr = 0;

//           setState(() {
//             dynamicText = 'no movement detected';
//             dynamicCtr = noMovementCtr.toString();
//             try {
//               avgFrames = execTotalFrames / numExec;
//               resultAvgFrames = avgFrames.toStringAsFixed(2);
//               avgFrames = double.parse(resultAvgFrames);
//             } catch (error) {
//               avgFrames = 0;
//             }
//           });
//         } else {
//           print("outside nowperforming--->, $nowPerforming");

//           // noMovementCtr++;
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


//     if (queueInferencingData.isNotEmpty) {
//       inferencingCoordinatesData(queueInferencingData.elementAt(0))
//           .then((value) {
//         queueInferencingData.removeAt(0);
//         print('test');
//       }).catchError((error) {
//         print("Error at inferencing data ---> $error");
//       });
//     }

//     if (inputImage.metadata?.size != null &&
//         inputImage.metadata?.rotation != null) {
//       final painter = PosePainter(
//         poses,
//         inputImage.metadata!.size,
//         inputImage.metadata!.rotation,
//         _cameraLensDirection,
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

//   void updateProgress(double progress) {
//     print("UPDATING PROGRESS ---> , $progress");
//     setState(() {
//       // Update your state variables based on the progress
//       // For example, assign the progress to a variable to display it in the UI
//       _progress = progress;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       body: Stack(
//         children: [
//           Align(
//             alignment: Alignment.topCenter,
//             child: Transform.translate(
//               offset: Offset(0.0, -150.0), // Adjust the y-value to move it up
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Text(
//                     "Now performing:",
//                     style: TextStyle(
//                       fontSize: 24.0,
//                       fontWeight: FontWeight.bold,
//                       color: tertiaryColor,
//                     ),
//                   ),
//                   Text(
//                     "Exercise name here",
//                     style: TextStyle(
//                       fontSize: 24.0,
//                       fontWeight: FontWeight.bold,
//                       color: tertiaryColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           DetectorView(
//             title: 'Pose Detector',
//             customPaint: _customPaint,
//             text: _text,
//             onImage: _processImage,
//             initialCameraLensDirection: _cameraLensDirection,
//             onCameraLensDirectionChanged: (value) =>
//                 _cameraLensDirection = value,
//           ),
//           Align(
//             alignment: Alignment.topCenter,
//             child: FractionallySizedBox(
//               widthFactor: screenWidth,
//               heightFactor: 0.15,
//               child: Container(
//                 color: mainColor,
//                 // You can also add other properties to the Container widget
//               ),
//             ),
//           ),
//           Positioned(
//             left: (screenWidth * .50) -
//                 ((MediaQuery.of(context).size.width / 4) +
//                         (MediaQuery.of(context).size.width / 12)) /
//                     2,
//             bottom: (screenHeight * .725),
//             child: Container(
//               width: (MediaQuery.of(context).size.width / 4) +
//                   (MediaQuery.of(context).size.width / 12),
//               height: (MediaQuery.of(context).size.height / 4) +
//                   (MediaQuery.of(context).size.width / 12),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: mainColor,
//               ),
//             ),
//           ),
//           Align(
//               alignment: Alignment.topCenter,
//               child: CircularCountDownTimer(
//                 duration: currentDuration,
//                 initialDuration: 0,
//                 controller: _controller,
//                 // width: MediaQuery.of(context).size.width / 2,
//                 // height: MediaQuery.of(context).size.height / 2,
//                 width: MediaQuery.of(context).size.width / 4,
//                 height: MediaQuery.of(context).size.height / 4,
//                 ringColor: Colors.white!,
//                 ringGradient: null,
//                 fillColor: Colors.red,
//                 fillGradient: null,
//                 backgroundColor: dynamicCountDownColor,
//                 backgroundGradient: null,
//                 strokeWidth: 20.0,
//                 strokeCap: StrokeCap.round,
//                 textStyle: TextStyle(
//                     fontSize: 20.0,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold),
//                 textFormat: CountdownTextFormat.S,
//                 isReverse: false,
//                 isReverseAnimation: false,
//                 isTimerTextShown: true,
//                 autoStart: false,
//                 onStart: () {
//                   print('Countdown Started');
//                 },
//                 onComplete: () {
//                   print('Countdown Ended');
//                 },
//                 onChange: (String timeStamp) {
//                   print('Countdown Changed $timeStamp');
//                 },
//                 timeFormatterFunction: (defaultFormatterFunction, duration) {
//                   if (nowPerforming == true) {
//                     return dynamicCountDownText;
//                   } else {
//                     return Function.apply(defaultFormatterFunction, [duration]);
//                   }
//                 },
//               )
//               // countdownTimer(context, dynamicCountDownText,
//               //     dynamicCountDownColor, _controller)
//               ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: FractionallySizedBox(
//               widthFactor: screenWidth,
//               heightFactor: 0.15,
//               child: Container(
//                 color: mainColor,
//               ),
//             ),
//           ),
//           Positioned(
//               top: screenHeight * .05,
//               right: screenWidth * .1,
//               child: Column(
//                 children: [
//                   Text(
//                     // dynamicText,
//                     "avg frame",
//                     style: TextStyle(
//                       fontSize: 18.0,
//                       fontWeight: FontWeight.w200,
//                       color: tertiaryColor,
//                     ),
//                   ),
//                   Text(
//                     // dynamicText,
//                     avgFrames.toString(),
//                     style: TextStyle(
//                       fontSize: 18.0,
//                       fontWeight: FontWeight.w200,
//                       color: tertiaryColor,
//                     ),
//                   ),
//                 ],
//               )),
//           Positioned(
//             top: screenHeight * .05,
//             left: screenWidth * .1,
//             child: Text(
//               // dynamicText,
//               "collecting\n   data",
//               style: TextStyle(
//                 fontSize: 21.0,
//                 fontWeight: FontWeight.w200,
//                 color: tertiaryColor,
//               ),
//             ),
//           ),
//           IconButton(
//             icon: Icon(
//               Icons.arrow_back,
//               color: tertiaryColor,
//             ),
//             onPressed: () {
//               // Your custom back button functionality goes here
//               Navigator.pop(context);
//             },
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Transform.translate(
//               offset: Offset(0.0, -20.0), // Adjust the y-value to move it up
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Text(
//                     numExec.toString(),
//                     style: TextStyle(
//                       fontSize: 30.0,
//                       fontWeight: FontWeight.w600,
//                       color: tertiaryColor,
//                     ),
//                   ),
//                   Align(
//                     alignment: Alignment.bottomCenter,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             secondaryColor, // Set the background color here
//                       ),
//                       onPressed: () {
//                         executionAnalysis(
//                           context,
//                           numExec,
//                           avgFrames,
//                           coordinatesData,
//                           updateProgress,
//                           _progress,
//                         );
//                       },
//                       child: Text('Done'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
