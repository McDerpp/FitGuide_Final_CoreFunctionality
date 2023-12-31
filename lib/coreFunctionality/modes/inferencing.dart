import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

// Note: heavy imports...may cause lots of load times in between running
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

// UI related imports
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

// file imports
import '../misc/painters/pose_painter.dart';
import 'package:frontend/coreFunctionality/misc/poseWidgets/detector_view.dart';
import '../logicFunction/isolateProcessPDV.dart';
import '../extraWidgets/customWidgetPDV.dart';
import '../mainUISettings.dart';
import '../logicFunction/processLogic.dart';

class inferencing extends StatefulWidget {
  final String model;
  final String nameOfExercise;
  final int numberOfExecution;
  final int setsNeeded;
  final int restDuration;

  const inferencing({
    super.key,
    required this.model,
    required this.numberOfExecution,
    required this.nameOfExercise,
    required this.setsNeeded,
    required this.restDuration,
  });

  @override
  State<inferencing> createState() => _inferencingState();
}

class _inferencingState extends State<inferencing> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String resultAvgFrames = '';

  // ---------------------inferencing mode variables----------------------------------------------------------
  // isolate initialization for heavy process
  RootIsolateToken rootIsolateTokenNormalization = RootIsolateToken.instance!;
  RootIsolateToken rootIsolateTokenNoMovement = RootIsolateToken.instance!;
  RootIsolateToken rootIsolateTokenInferencing = RootIsolateToken.instance!;

  List<double> prevCoordinates = [];
  List<double> currentCoordinates = [];
  List<List<double>> inferencingList = [];
  List<List<double>> tempPrevCurr = [];
  bool checkFramesCaptured = false;
  int framesCapturedCtr = 0;

  String dynamicText = 'no movement \n detected';
  String dynamicCtr = '0';
  int execTotalFrames = 0;
  int numExec = 0;
  double avgFrames = 0.0;

  Map<String, dynamic> inferencingData = {};
  Map<String, dynamic> checkMovementIsolate = {};

  List<Map<String, dynamic>> queueNormalizeData = [];
  List<Map<String, dynamic>> queueMovementData = [];
  List<Map<String, dynamic>> queueInferencingData = [];
  int noMovementCtr = 0;
  // ---------------------inferencing mode variables----------------------------------------------------------
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  // ---------------------countdown variables----------------------------------------------------------
  late int _seconds;
  late Timer _timer;
  // ---------------------countdown variables----------------------------------------------------------
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  // ---------------------collecting data mode variables----------------------------------------------------------
  List<double> temp = [];
  List<dynamic> coordinatesData = [];
  bool isSet = true;
  bool isDataCollected = true;
  int collectingCtr = 0;
  double _progress = 0.0;
  int currentDuration2 = 5;
  List<int> igrnoreCoordinatesList = [];

  // ---------------------collecting data mode variables----------------------------------------------------------
  // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  // ---------------------inferencing data mode variables----------------------------------------------------------
  int inferenceCorrectCtr = 0;
  int setsAchieved = 0;

  // ---------------------inferencing data mode variables----------------------------------------------------------
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  // ---------------------countdown variables----------------------------------------------------------

  final CountDownController _controller = CountDownController();
  final CountDownController _controller2 = CountDownController();

  int nowPerforming = 0;
  bool countDowntoPerform = false;
  bool checkCountDowntoPerform = false;

  String dynamicCountDownText = 'Ready';
  Color dynamicCountDownColor = secondaryColor;

  // ---------------------collecting data mode variables----------------------------------------------------------
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  @override
  void initState() {
    super.initState();
    try {
      paddingInitialize();
      modelInitialize(widget.model);
      int currentDuration2 = 3;
    } catch (error) {
      print("error at initialization of inferencing --> $error");
    }
    // if (widget.isInferencing == false) {}
    _seconds = 60;
  }

// final Future<Interpreter> interpreter = Interpreter.fromAsset(
//     'assets/models/wholeModel/otestingtesting(loss_0.063)(acc_0.982).tflite');

  List<List<Pose>> poseQueue = [];
  List<List<double>> queueNormalizedListQueue = [];

  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;

  @override
  void dispose() async {
    _canProcess = false;
    // _poseDetector.close();
    super.dispose();
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_seconds == 0) {
          timer.cancel();
        } else {
          setState(() {
            _seconds--;
          });
        }
      },
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    // createFile();

    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    late final List<Pose> poses;
    // bool noMovement = false;

    setState(() {
      _text = '';
    });

// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // ==================================[isolate function processImage ]==================================
    try {
      poses = await _poseDetector.processImage(inputImage);
      Map<String, dynamic> dataNormalizationIsolate = {
        'inputImage': poses.first.landmarks.values,
        'token': rootIsolateTokenNormalization,
        'coordinatesIgnore' :igrnoreCoordinatesList,

      };
      queueNormalizeData.add(dataNormalizationIsolate);
    } catch (error) {
      print("error at proces image ---> $error");
    }

// // ==================================[isolate function processImage ]==================================
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // ==================================[isolate function forcoordinatesRelativeBoxIsolate ]==================================
    if (queueNormalizeData.isNotEmpty) {
      compute(coordinatesRelativeBoxIsolate, queueNormalizeData.elementAt(0))
          .then((value) {
        queueNormalizeData.removeAt(0);
        tempPrevCurr.add(value);
        // inferencingList.add(value);
        if (nowPerforming == 1) {
          temp = value;
          // temp.add(value);
        }
        if (tempPrevCurr.length > 1) {
          prevCoordinates = tempPrevCurr.elementAt(0);
          currentCoordinates = tempPrevCurr.elementAt(1);

          Map<String, dynamic> checkMovementIsolate = {
            'prevCoordinates': prevCoordinates,
            'currentCoordinates': currentCoordinates,
            'token': rootIsolateTokenNoMovement,
          };
          queueMovementData.add(checkMovementIsolate);
          tempPrevCurr.removeAt(0);
        }
      }).catchError((error) {
        print("Error at coordinate relative ---> $error");
      });
    }

// // ==================================[isolate function forcoordinatesRelativeBoxIsolate ]==================================
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// // ==================================[isolate function checkMovement ]==================================
    if (queueMovementData.isNotEmpty) {
      compute(checkMovement, queueMovementData.elementAt(0))
          .then((value) async {
        queueMovementData.removeAt(0);

        if (value == true && checkFramesCaptured == false) {
          checkFramesCaptured = true;
          framesCapturedCtr++;

          framesCapturedCtr = 0;

          if (nowPerforming == 1) {
            collectingCtr++;
            if (collectingCtr >= collectingCtrDelay) {
              collectingCtr = 0;

              isDataCollected = true;
              if (inferencingList.isNotEmpty) {
                // dynamicCountDownText = 'collected';
                // dynamicCountDownColor = secondaryColor;
                coordinatesData.add(inferencingList);

                execTotalFrames = execTotalFrames + inferencingList.length;

                inferencingData = {
                  'coordinatesData': inferencingList,
                  'token': rootIsolateTokenInferencing,
                };

                numExec++;

                queueInferencingData.add(inferencingData);
              }

              inferencingList = [];
            }
          }
        } else if (value == false) {
          if (nowPerforming == 1) {
            // dynamicCountDownText = 'collecting';
            dynamicCountDownColor = Colors.blue;
            checkFramesCaptured = false;

            // inferencingList.add(temp.elementAt(0));
            if (temp.isNotEmpty) {
              inferencingList.add(temp);
            }
            isDataCollected = false;

            temp = [];
          }
        }

        if (value == true) {
          // -----------------checking for movement before executing for collecting data--------------------------------------
          if (nowPerforming == 0) {
            if (countDowntoPerform == false) {
              _controller.start();
              // _controller.reset();
              countDowntoPerform = true;
              dynamicCountDownText = 'Perform';
            }
          }

          if (_controller.getTime().toString() == "5" && nowPerforming == 0) {
            nowPerforming = 1;
          }
          //---------------after not moving for 3 sec-------------------------

          noMovementCtr = 0;

          setState(() {
            dynamicText = 'no movement detected';
            dynamicCtr = noMovementCtr.toString();
            try {
              avgFrames = execTotalFrames / numExec;
              resultAvgFrames = avgFrames.toStringAsFixed(2);
              avgFrames = double.parse(resultAvgFrames);
            } catch (error) {
              avgFrames = 0;
            }
          });
        } else {
          // -----------------checking for movement before executing for collecting data--------------------------------------

          if (nowPerforming == 0) {
            if (countDowntoPerform == true) {
              _controller.reset();
              countDowntoPerform = false;
            }
          }
          // -----------------------------------------------------------------------------------------------------------

          setState(() {
            dynamicText = 'movement detected';
            dynamicCtr = noMovementCtr.toString();
          });
        }
      }).catchError((error) {
        print("Error at checkMovement ---> $error");
      });
    }

    if (queueInferencingData.isNotEmpty && nowPerforming == 1) {
      inferencingCoordinatesData(
              queueInferencingData.elementAt(0), widget.model)
          .then((value) {
        if (value == true) {
          inferenceCorrectCtr++;
          dynamicCountDownColor = Color.fromARGB(255, 3, 104, 8);
        } else {
          dynamicCountDownColor = Color.fromARGB(255, 255, 0, 0);
        }
        queueInferencingData.removeAt(0);
      }).catchError((error) {
        print("Error at inferencing data ---> $error");
      });
    }

    if (inferenceCorrectCtr == widget.numberOfExecution) {
      setsAchieved = setsAchieved + 1;
      nowPerforming = 3;
      inferenceCorrectCtr = 0;

      setState(() {
        _controller.restart(duration: 30);
      });
      currentDuration2 = 30;
      dynamicCountDownText = "rest";

      _controller2.start();
    }

    if (nowPerforming == 3) {
      String num = _controller.getTime().toString();
      int num2 = int.parse(num);
      currentDuration2 = 30;

      dynamicCountDownColor =
          Color.fromARGB(255, 193, 140 - num2 * 3, 100 - num2 * 5);
      Color.fromARGB(255, 193, 140, 100);

      if (_controller.getTime().toString() == '6') {
        dynamicCountDownText = "ready";
      }

      if (_controller.getTime().toString() == '5') {
        dynamicCountDownText = "ready";
      }

      if (_controller.getTime().toString() == '4') {
        dynamicCountDownText = "ready";
      }

      if (_controller.getTime().toString() == '27') {
        dynamicCountDownText = "27";
      }

      if (_controller.getTime().toString() == '28') {
        dynamicCountDownText = "28";
      }

      if (_controller.getTime().toString() == '29') {
        dynamicCountDownText = "29";
      }

      if (_controller.getTime().toString() == "30") {
        dynamicCountDownText = "Perform";

        nowPerforming = 1;
      }
    }

    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = 'Poses found: ${poses.length}\n\n';

      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  void updateProgress(double progress) {
    setState(() {
      _progress = progress;
    });
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          DetectorView(
            title: 'Pose Detector',
            customPaint: _customPaint,
            text: _text,
            onImage: _processImage,
            initialCameraLensDirection: _cameraLensDirection,
            onCameraLensDirectionChanged: (value) =>
                _cameraLensDirection = value,
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              color: mainColor,
              width: screenWidth,
              height: screenHeight * .13,
            ),
          ),

          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              color: mainColor,
              width: screenWidth,
              height: screenHeight * .13,
            ),
          ),

          Positioned(
            left: (screenWidth * .50) -
                ((MediaQuery.of(context).size.width / 4) +
                        (MediaQuery.of(context).size.width / 12)) /
                    2,
            bottom: (screenHeight * .725),
            child: Container(
              width: (MediaQuery.of(context).size.width / 4) +
                  (MediaQuery.of(context).size.width / 12),
              height: (MediaQuery.of(context).size.height / 4) +
                  (MediaQuery.of(context).size.width / 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mainColor,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: CircularCountDownTimer(
              duration: 5,
              // duration: 5,

              initialDuration: 0,
              controller: _controller,
              // width: MediaQuery.of(context).size.width / 2,
              // height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width / 4,
              height: MediaQuery.of(context).size.height / 4,
              ringColor: Colors.white!,
              ringGradient: null,
              fillColor: Colors.red,
              fillGradient: null,
              backgroundColor: dynamicCountDownColor,
              backgroundGradient: null,
              strokeWidth: 20.0,
              strokeCap: StrokeCap.round,
              textStyle: TextStyle(
                  fontSize:
                      ((screenHeight + screenWidth) * textAdaptModifier) * 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w400),
              textFormat: CountdownTextFormat.S,
              isReverse: false,
              isReverseAnimation: false,
              isTimerTextShown: true,
              autoStart: false,
              onStart: () {},
              onComplete: () {},
              onChange: (String timeStamp) {
                print('Countdown Changed $timeStamp');
              },
              timeFormatterFunction: (defaultFormatterFunction, duration) {
                if (nowPerforming == 1 || nowPerforming == 3) {
                  return dynamicCountDownText;
                } else {
                  return Function.apply(defaultFormatterFunction, [duration]);
                }
              },
            ),
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: FractionallySizedBox(
          //     widthFactor: screenWidth,
          //     heightFactor: 0.15,
          //     child: Container(
          //       color: mainColor,
          //     ),
          //   ),
          Positioned(
            top: screenHeight * 0.04,
            right: screenWidth * 0.05,
            child: Column(
              children: [
                // ),
                Text(
                  "  Execution",
                  style: TextStyle(
                    fontSize:
                        ((screenHeight + screenWidth) * textAdaptModifier) *
                            13.0,
                    fontWeight: FontWeight.w500,
                    color: tertiaryColor,
                  ),
                ),
                Positioned(
                  child: Row(
                    children: [
                      Text(
                        " ${inferenceCorrectCtr.toString()}",
                        style: TextStyle(
                          fontSize: ((screenHeight + screenWidth) *
                                  textAdaptModifier) *
                              35.0,
                          fontWeight: FontWeight.w300,
                          color: tertiaryColor,
                        ),
                      ),
                      Text(
                        " / ${widget.numberOfExecution.toString()}",
                        style: TextStyle(
                          fontSize: ((screenHeight + screenWidth) *
                                  textAdaptModifier) *
                              35.0,
                          fontWeight: FontWeight.w300,
                          color: secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: screenHeight * 0.04,
            left: screenWidth * 0.05,
            child: Column(
              children: [
                // ),
                Text(
                  "  Sets Needed ",
                  style: TextStyle(
                    fontSize:
                        ((screenHeight + screenWidth) * textAdaptModifier) *
                            13.0,
                    fontWeight: FontWeight.w500,
                    color: tertiaryColor,
                  ),
                ),
                Positioned(
                  child: Row(
                    children: [
                      Text(
                        " ${setsAchieved.toString()}",
                        style: TextStyle(
                          fontSize: ((screenHeight + screenWidth) *
                                  textAdaptModifier) *
                              35.0,
                          fontWeight: FontWeight.w300,
                          color: tertiaryColor,
                        ),
                      ),
                      Text(
                        " / ${widget.setsNeeded.toString()}",
                        style: TextStyle(
                          fontSize: ((screenHeight + screenWidth) *
                                  textAdaptModifier) *
                              35.0,
                          fontWeight: FontWeight.w300,
                          color: secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: screenWidth * .05,
            bottom: screenHeight * .03,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Add this line
              children: [
                Text(
                  " Exercise: ",
                  style: TextStyle(
                    fontSize:
                        ((screenHeight + screenWidth) * textAdaptModifier) *
                            16.0,
                    fontWeight: FontWeight.w300,
                    color: secondaryColor,
                  ),
                ),
                Text(
                  "  ${widget.nameOfExercise}",
                  style: TextStyle(
                    fontSize:
                        ((screenHeight + screenWidth) * textAdaptModifier) *
                            25.0,
                    fontWeight: FontWeight.w400,
                    color: tertiaryColor,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: tertiaryColor,
            ),
            onPressed: () {
              // Your custom back button functionality goes here
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
