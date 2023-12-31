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
  RootIsolateToken rootIsolateTokenTranslating = RootIsolateToken.instance!;

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

  Color headColor = secondaryColor;
  Color leftArmColor = secondaryColor;
  Color rightArmColor = secondaryColor;
  Color leftLegColor = secondaryColor;
  Color rightLegColor = secondaryColor;
  Color bodyColor = secondaryColor;
  List<int> ignoreCoordinatesInitialized = [];

// [head,leftArm,rightArm,leftLeg,rightLeg,body]
  List<bool> igrnoreCoordinatesList = [
    false,
    false,
    false,
    false,
    false,
    false
  ];

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
        'coordinatesIgnore': ignoreCoordinatesInitialized,
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
          print(
              '------------------------------------movementTest[$numExec]--------------------------------------');

          print(
              "movementTest--prevCoordinates --> ${prevCoordinates.elementAt(0)}");
          print(
              "movementTest--currentCoordinates --> ${currentCoordinates.elementAt(0)}");
          if (prevCoordinates.elementAt(0) - currentCoordinates.elementAt(0) ==
              0) {
            print("movementTest--duplicate coordinates");
          }
          print(
              '---------------------------------movementTest[$numExec]-----------------------------------------');

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
            // collectingCtr++;
            // if (collectingCtr >= collectingCtrDelay) {
            //   collectingCtr = 0;

            isDataCollected = true;
            if (inferencingList.isNotEmpty) {
              dynamicCountDownText = 'collected';
              dynamicCountDownColor = secondaryColor;
              coordinatesData.add(inferencingList);
              print(
                  'dataInHere =================================================[exec:$numExec]=======================================================================================');
              // print(
              //     'dataInHere ========================================================================================================================================');

              // for (List dataInHere in coordinatesData) {
              //   print(
              //       "dataInHere ----> ${dataInHere.elementAt(0).elementAt(0)} --> ${dataInHere.elementAt(1).elementAt(0)} -- ${dataInHere.elementAt(2).elementAt(0)} -- ${dataInHere.elementAt(3).elementAt(0)}");
              // }
              // print("${coordinatesData.last.elementAt(0)}");

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
          // }
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

  void initiateIgnoreCoordinates() {
    ignoreCoordinatesInitialized.clear();
    List<int> head = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    List<int> body = [];
    List<int> leftArm = [11, 13, 25, 21, 17, 19];
    List<int> rightArm = [12, 14, 16, 18, 20, 22];
    List<int> leftLeg = [23, 25, 27, 29, 31];
    List<int> rightLeg = [24, 26, 28, 32, 30];

    if (igrnoreCoordinatesList.elementAt(0) == true) {
      ignoreCoordinatesInitialized.addAll(head);
    }
    if (igrnoreCoordinatesList.elementAt(1) == true) {
      ignoreCoordinatesInitialized.addAll(leftArm);
    }
    if (igrnoreCoordinatesList.elementAt(2) == true) {
      ignoreCoordinatesInitialized.addAll(rightArm);
    }
    if (igrnoreCoordinatesList.elementAt(3) == true) {
      ignoreCoordinatesInitialized.addAll(leftLeg);
    }
    if (igrnoreCoordinatesList.elementAt(4) == true) {
      ignoreCoordinatesInitialized.addAll(rightLeg);
    }
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

  void simulateCollectData() {
    print("simulating collection of data");
    for (int ctr = 0; ctr <= 75; ctr++) {
      inferencingList = [];
      for (int ctr1 = 0; ctr1 <= 10; ctr1++) {
        temp = [];
        for (int ctr2 = 0; ctr2 <= 66; ctr2++) {
          temp.add(0.1111111111);
        }
        inferencingList.add(temp);
      }
      print("adding --> $numExec");
      coordinatesData.add(inferencingList);
      setState(() {
        numExec++;
      });
    }
    print("translating to txt");
    Map<String, dynamic> translatingIsolate = {
      'coordinates': coordinatesData,
      'token': rootIsolateTokenTranslating,
    };

    // compute(translateCollectedDatatoTxt2, translatingIsolate);
    print("translated");
  }

  bool isChecked = false;

  Future openDialog(BuildContext context, Widget content) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('setState in Dialog?'),
          content: content,
          actions: [
            TextButton(
              child: Text('SUBMIT'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

  Color? coordinatesIgnoreState(int index) {
    undoExecution(coordinatesData.length);

    if (igrnoreCoordinatesList.elementAt(index) == false) {
      igrnoreCoordinatesList[index] = true;
      return Colors.purple[900];
    } else {
      igrnoreCoordinatesList[index] = false;
      return secondaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textSizeModif = (screenHeight + screenWidth) * textAdaptModifier;

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
                    fontSize: 20.0 * textSizeModif,
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
            top: screenHeight * 0.06,
            right: screenWidth * 0.02,
            child: Row(
              children: [
                Text(
                  numExec.toString(),
                  style: TextStyle(
                    fontSize: 35.0 * textSizeModif,
                    fontWeight: FontWeight.w400,
                    color: tertiaryColor,
                  ),
                ),
                Text(
                  "/100",
                  style: TextStyle(
                    fontSize: 35.0 * textSizeModif,
                    fontWeight: FontWeight.w400,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: screenHeight * .05,
            left: screenWidth * .02,
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      "Average",
                      style: TextStyle(
                        fontSize: 15.0 * textSizeModif,
                        fontWeight: FontWeight.w400,
                        color: secondaryColor,
                      ),
                    ),
                    SizedBox(height: 10.0), // Add a vertical space
                    Text(
                      "$avgFrames",
                      style: TextStyle(
                        fontSize: 23.0 * textSizeModif,
                        fontWeight: FontWeight.w400,
                        color: tertiaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20.0), // Add a horizontal space
                Column(
                  children: [
                    Text(
                      "Variance",
                      style: TextStyle(
                        fontSize: 15.0 * textSizeModif,
                        fontWeight: FontWeight.w400,
                        color: secondaryColor,
                      ),
                    ),
                    SizedBox(height: 10.0), // Add a vertical space
                    Text(
                      "$variance",
                      style: TextStyle(
                        fontSize: 23.0 * textSizeModif,
                        fontWeight: FontWeight.w400,
                        color: tertiaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Positioned(
          //   top: screenHeight * .05,
          //   left: screenWidth * .2,
          //   child: description1(
          //     DescTitle: " Variance",
          //     Desc: "  ${variance.toString()}",
          //     context: context,
          //   ),
          // ),
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
                  fontSize: 13.0 * textSizeModif,
                  fontWeight: FontWeight.w400,
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
                  fontSize: 13.0 * textSizeModif,
                  fontWeight: FontWeight.w400,
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
            left: screenWidth * 0.04,
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
                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          // content: Text(contentText),
                          actions: <Widget>[
                            Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: screenHeight * .05,
                                  color: secondaryColor,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Container(
                              width: screenWidth * 0.80,
                              height: screenHeight * 0.5,
                              child: Stack(
                                children: [
                                  // ---------------------------------------------[head]
                                  Positioned(
                                    left: screenWidth * .25,
                                    top: screenHeight * 0.0,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: headColor,
                                        fixedSize: Size(
                                          screenHeight * 0.15,
                                          screenHeight * 0.05,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          headColor =
                                              coordinatesIgnoreState(0)!;
                                          initiateIgnoreCoordinates();
                                        });
                                      },
                                      child: Text('Head'),
                                    ),
                                  ),
                                  // ---------------------------------------------[body]

                                  Positioned(
                                    left: screenWidth * 0.02,
                                    top: screenHeight * 0.2,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: bodyColor,
                                        fixedSize: Size(
                                          screenHeight * 0.15,
                                          screenHeight * 0.05,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          bodyColor =
                                              coordinatesIgnoreState(5)!;
                                          initiateIgnoreCoordinates();
                                        });
                                      },
                                      child: Text('body'),
                                    ),
                                  ),
                                  // ---------------------------------------------[right arm]

                                  Positioned(
                                    left: screenWidth * 0.02,
                                    top: screenHeight * 0.08,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: rightArmColor,
                                        fixedSize: Size(
                                          screenHeight * 0.15,
                                          screenHeight * 0.05,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          rightArmColor =
                                              coordinatesIgnoreState(2)!;
                                          initiateIgnoreCoordinates();
                                        });
                                      },
                                      child: Text('Right Arm'),
                                    ),
                                  ),
                                  // ---------------------------------------------[left arm]

                                  Positioned(
                                    right: screenWidth * 0.02,
                                    top: screenHeight * 0.08,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: leftArmColor,
                                        fixedSize: Size(
                                          screenHeight * 0.15,
                                          screenHeight * 0.05,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          leftArmColor =
                                              coordinatesIgnoreState(1)!;
                                          initiateIgnoreCoordinates();
                                        });
                                      },
                                      child: Text('Left Arm'),
                                    ),
                                  ),
                                  // ---------------------------------------------[right leg]

                                  Positioned(
                                    left: screenWidth * 0.02,
                                    bottom: screenHeight * 0.08,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: rightLegColor,
                                        fixedSize: Size(
                                          screenHeight * 0.15,
                                          screenHeight * 0.05,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          rightLegColor =
                                              coordinatesIgnoreState(4)!;
                                          initiateIgnoreCoordinates();
                                        });
                                      },
                                      child: Text('Right Leg'),
                                    ),
                                  ),
                                  // ---------------------------------------------[left leg]

                                  Positioned(
                                    right: screenWidth * 0.02,
                                    bottom: screenHeight * 0.08,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: leftLegColor,
                                        fixedSize: Size(
                                          screenHeight * 0.15,
                                          screenHeight * 0.05,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          leftLegColor =
                                              coordinatesIgnoreState(3)!;
                                          initiateIgnoreCoordinates();
                                        });
                                      },
                                      child: Text('Left Leg'),
                                    ),
                                  ),
                                  // ---------------------------------------------[----]

                                  Positioned(
                                    left: screenWidth * .1,
                                    bottom: screenHeight * 0.35,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.accessibility_sharp,
                                        color: secondaryColor,
                                        size: screenWidth * .50, //
                                      ),
                                      onPressed: () {},
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          Positioned(
            bottom: screenHeight * 0.5,
            right: screenWidth * 0.5,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                fixedSize: Size(
                  screenHeight * 0.11,
                  screenHeight * 0.11,
                ),
              ),
              onPressed: () {
                simulateCollectData();
              },
              child: Text('Simulate'),
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
