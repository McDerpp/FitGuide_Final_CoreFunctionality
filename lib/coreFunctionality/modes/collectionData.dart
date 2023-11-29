import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';

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

class collectionData extends StatefulWidget {
  const collectionData({
    super.key,
  });

  @override
  State<collectionData> createState() => _collectionDataState();
}

class _collectionDataState extends State<collectionData> {
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
  double _sliderValue = 0.0;
  int _sliderValue2 = 0;
  double variance = 0;
  int numFrameVariance = 5;
  int collectingCtrDelay = 0;

  // ---------------------collecting data mode variables----------------------------------------------------------
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  // ---------------------countdown variables----------------------------------------------------------

  final CountDownController _controller = CountDownController();
  bool nowPerforming = false;
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
        if (nowPerforming == true) {
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
          // framesCapturedCtr++;

          // framesCapturedCtr = 0;

          if (nowPerforming == true) {
            collectingCtr++;
            if (collectingCtr >= collectingCtrDelay) {
              collectingCtr = 0;

              isDataCollected = true;
              if (inferencingList.isNotEmpty) {
                dynamicCountDownText = 'collected';
                dynamicCountDownColor = secondaryColor;
                coordinatesData.add(inferencingList);
                print(
                    "coordinatesDatatest ---- ${coordinatesData.last.length}");
                execTotalFrames = execTotalFrames + inferencingList.length;

                // inferencingData = {
                //   'coordinatesData': inferencingList,
                //   'token': rootIsolateTokenInferencing,
                // };

                numExec++;

                // queueInferencingData.add(inferencingData);
              }

              inferencingList = [];
            }
          }
        } else if (value == false) {
          if (nowPerforming == true) {
            dynamicCountDownText = 'collecting';
            dynamicCountDownColor = Colors.blue;
            checkFramesCaptured = false;

            // inferencingList.add(temp.elementAt(0));
            if (temp.isNotEmpty) {
              inferencingList.add(temp);
            }
            isDataCollected = false;
            print("collecting coordinates");
            print(
                "collecting--- ${isDataCollected} ------2----- ${nowPerforming}");
            temp = [];
          }
        }

        if (value == true) {
          // -----------------checking for movement before executing for collecting data--------------------------------------
          if (nowPerforming == false) {
            if (countDowntoPerform == false) {
              _controller.start();
              countDowntoPerform = true;
              dynamicCountDownText = 'Perform';
            }
          }

          if (_controller.getTime().toString() == "3" &&
              nowPerforming == false) {
            nowPerforming = true;
          }

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
          print("outside nowperforming--->, $nowPerforming");

          // noMovementCtr++;
          // -----------------checking for movement before executing for collecting data--------------------------------------

          if (nowPerforming == false) {
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

    calculateVariance(numFrameVariance);
  }

  void updateProgress(double progress) {
    print("UPDATING PROGRESS ---> , $progress");
    setState(() {
      _progress = progress;
    });
  }

  // void updateCollectingCtrDelay(int value) {
  //   collectingCtrDelay = value;
  //   setState(() {
  //     _progress = progress;
  //   });
  // }

  void undoExecution(int undoTimes) {
    int temp = 0;
    int tempexecTotalFrames = execTotalFrames;
    for (int ctr = 0; ctr < undoTimes; ctr++) {
      if (coordinatesData.isNotEmpty) {
        tempexecTotalFrames =
            (tempexecTotalFrames - coordinatesData.last.length).toInt();
        coordinatesData.removeLast();
        numExec--;
      }
    }
    setState(() {
      nowPerforming = false;

      execTotalFrames = tempexecTotalFrames;
      avgFrames = execTotalFrames / numExec;
      resultAvgFrames = avgFrames.toStringAsFixed(2);
      avgFrames = double.parse(resultAvgFrames);
    });
  }

  void calculateVariance(int numFrameGroup) {
    if (coordinatesData.length % numFrameGroup == 0) {
      variance = 0;
      for (int ctr = 0; ctr <= numFrameGroup; ctr++) {
        double squaredDifferences = pow(
                (coordinatesData.elementAt(coordinatesData.length - ctr) -
                    avgFrames),
                2)
            .toDouble();
        variance = variance + squaredDifferences;
      }

      setState(() {
        variance = variance / numFrameGroup;
      });
    }
  }

  @override
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
          Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              widthFactor: screenWidth,
              heightFactor: 0.15,
              child: Container(
                color: mainColor,
                // You can also add other properties to the Container widget
              ),
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
                duration: currentDuration,
                initialDuration: 0,
                controller: _controller,
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
                    fontSize: 20.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                textFormat: CountdownTextFormat.S,
                isReverse: false,
                isReverseAnimation: false,
                isTimerTextShown: true,
                autoStart: false,
                onStart: () {
                  print('Countdown Started');
                },
                onComplete: () {
                  print('Countdown Ended');
                },
                onChange: (String timeStamp) {
                  print('Countdown Changed $timeStamp');
                },
                timeFormatterFunction: (defaultFormatterFunction, duration) {
                  if (nowPerforming == true) {
                    return dynamicCountDownText;
                  } else {
                    return Function.apply(defaultFormatterFunction, [duration]);
                  }
                },
              )
              // countdownTimer(context, dynamicCountDownText,
              //     dynamicCountDownColor, _controller)
              ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: screenWidth,
              heightFactor: 0.15,
              child: Container(
                color: mainColor,
              ),
            ),
          ),
          // Positioned(
          //   bottom: screenHeight * .02,
          //   left: screenWidth * .59,
          //   child: description1(
          //     DescTitle: " average",
          //     Desc: "  ${avgFrames.toString()}",
          //   ),
          // ),
          Positioned(
            top: screenHeight * .075,
            right: screenWidth * .075,
            child: Row(children: [
              Text(
                numExec.toString(),
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: tertiaryColor,
                ),
              ),
              Text(
                " / 100",
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
            ]),
          ),

          // Positioned(
          //   top: screenHeight * .08,
          //   left: screenWidth * .02,
          //   child: Text(
          //     "Collecting data",
          //     style: TextStyle(
          //       fontSize: 18.0,
          //       fontWeight: FontWeight.bold,
          //       color: tertiaryColor,
          //     ),
          //   ),
          // ),

          Positioned(
            top: screenHeight * .05,
            left: screenWidth * .03,
            child: description1(
              DescTitle: " average",
              Desc: "  ${avgFrames.toString()}",
            ),
          ),
          Positioned(
            top: screenHeight * .05,
            left: screenWidth * .2,
            child: description1(
              DescTitle: " Variance",
              Desc: "  ${variance.toString()}",
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: tertiaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Positioned(
            bottom: screenHeight * 0.025,
            left: screenWidth * 0.05,
            child: IconButton(
              icon: Icon(
                Icons.delete_forever,
                color: secondaryColor,
                size: screenWidth * .08, //
              ),
              onPressed: () {
                undoExecution(coordinatesData.length);
              },
            ),
          ),

          Positioned(
              bottom: screenHeight * 0.043,
              left: screenWidth * 0.23,
              child: Text(
                "1",
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              )),

          Positioned(
            bottom: screenHeight * 0.025,
            left: screenWidth * 0.18,
            child: IconButton(
              icon: Icon(
                Icons.restart_alt,
                color: secondaryColor,
                size: screenWidth * .08, //
              ),
              onPressed: () {
                undoExecution(1);
              },
            ),
          ),
          Positioned(
              bottom: screenHeight * 0.043,
              left: screenWidth * 0.36,
              child: Text(
                "5",
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              )),
          Positioned(
            bottom: screenHeight * 0.025,
            left: screenWidth * 0.31,
            child: IconButton(
              icon: Icon(
                Icons.restart_alt,
                color: secondaryColor,
                size: screenWidth * .08, //
              ),
              onPressed: () {
                undoExecution(5);
              },
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.025,
            left: screenWidth * 0.44,
            child: IconButton(
              icon: Icon(
                Icons.pause,
                color: secondaryColor,
                size: screenWidth * .08, //
              ),
              onPressed: () {
                setState(() {
                  nowPerforming = false;
                });
              },
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.08,
            left: screenWidth * 0.02,
            child: Slider(
              value: _sliderValue,
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                  _sliderValue2 = _sliderValue.toInt();
                  collectingCtrDelay = _sliderValue2;
                  print("changed itttttttt ----> $collectingCtrDelay ");
                });
              },
              min: 0.0,
              max: 5.0,
              activeColor: secondaryColor,
              inactiveColor: tertiaryColor,
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.095,
            left: screenWidth * 0.45,
            child: Container(
              width: screenWidth * 0.06,
              height: screenWidth * 0.06,
              decoration: BoxDecoration(
                color: tertiaryColor,
                borderRadius:
                    BorderRadius.circular(4.0), // Adjust the radius as needed
              ),
              child: Center(
                child: Text(
                  '${_sliderValue2.toString()}',
                  style: TextStyle(color: secondaryColor),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.08,
            right: screenWidth * 0.35,
            child: IconButton(
              icon: Icon(
                Icons.accessibility_sharp,
                color: secondaryColor,
                size: screenWidth * .18, //
              ),
              onPressed: () {
                undoExecution(coordinatesData.length);
              },
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.02,
            right: screenWidth * 0.02,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                fixedSize: Size(
                  screenHeight * 0.11,
                  screenHeight * 0.11,
                ),
              ),
              onPressed: () {
                executionAnalysis(
                  context,
                  numExec,
                  avgFrames,
                  coordinatesData,
                  updateProgress,
                  _progress,
                );
              },
              child: Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
