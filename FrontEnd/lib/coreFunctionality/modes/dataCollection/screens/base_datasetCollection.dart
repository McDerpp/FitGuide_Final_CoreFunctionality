import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/coreFunctionality/custom_widgets/errorWidget.dart';
import 'package:frontend/coreFunctionality/logicFunction/movementCheck.dart';
import 'package:frontend/coreFunctionality/logicFunction/normalizeCoordinates.dart';
import 'package:frontend/coreFunctionality/modes/dataCollection/screens/p1_datsetCollection.dart';
import 'package:frontend/coreFunctionality/modes/dataCollection/screens/p6_reviewDataset.dart';
import 'package:frontend/services/api.dart';
import 'package:frontend/coreFunctionality/custom_widgets/cwIgnorePose.dart';
import 'package:frontend/services/provider_collection.dart';
import 'package:frontend/coreFunctionality/modes/globalStuff/provider/globalVariables.dart';
import '../../../custom_widgets/executionAnalysis.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:showcaseview/showcaseview.dart';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import '../../../misc/painters/pose_painter.dart';
import 'package:frontend/coreFunctionality/misc/poseWidgets/detector_view.dart';
import '../../../mainUISettings.dart';

class collectionData extends ConsumerStatefulWidget {
  const collectionData({
    super.key,
  });

  @override
  ConsumerState<collectionData> createState() => _collectionDataState();
}

class _collectionDataState extends ConsumerState<collectionData> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String resultAvgFrames = '';

  // ---------------------inferencing mode variables----------------------------------------------------------
  // isolate initialization for heavy process
  RootIsolateToken rootIsolateTokenNormalization = RootIsolateToken.instance!;
  RootIsolateToken rootIsolateTokenNoMovement = RootIsolateToken.instance!;
  RootIsolateToken rootIsolateTokenInferencing = RootIsolateToken.instance!;
  RootIsolateToken rootIsolateTokenTranslating = RootIsolateToken.instance!;

// IMPORTANT CONFIGURATIONS---------------------------------------------------------------------------------------
  double requiredDataNum = 50;
// IMPORTANT CONFIGURATIONS---------------------------------------------------------------------------------------
  List<List<Pose>> tempPose = [];
  late Size sizeTemp;
  late InputImageRotation rotationTemp;
  late CameraLensDirection cameraLensDirectionTemp;

  List<double> prevCoordinates = [];
  List<double> currentCoordinates = [];
  List<List<double>> inferencingList = [];
  List<List<double>> tempPrevCurr = [];
  List<List<List<double>>> coordinatesData = [];

  int noMovementBufferThreshold = 10;
  int noMovementBufferCtr = 0;
  int framesCapturedCtr = 0;
  int execTotalFrames = 0;
  double avgFrames = 0.0;
  int minFrame = 0;
  int maxFrame = 0;

  List<Map<String, dynamic>> queueNormalizeData = [];
  List<Map<String, dynamic>> queueMovementData = [];
  List<Map<String, dynamic>> queueInferencingData = [];
  int executionStateResult = 0;

  List<double> temp = [];
  bool executionCaptured = false;

  late Map<String, Color> colorSet1;
  late Map<String, Color> colorSet2;

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

  // ---------------------countdown variables----------------------------------------------------------

  final CountDownController _controller = CountDownController();
  // bool nowPerforming = false;
  bool countDowntoPerform = false;
  bool checkCountDowntoPerform = false;

  String dynamicCountDownText = 'Ready';
  Color dynamicCountDownColor = secondaryColor;

  // ---------------------collecting data mode variables----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    getSessionKey().then((value) {
      ref.watch(sessionKeyProvider.notifier).state = value;
    });
    // _seconds = 60;
  }

  List<List<Pose>> poseQueue = [];
  List<List<double>> queueNormalizedListQueue = [];

  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  @override
  void dispose() async {
    _canProcess = false;
    // _poseDetector.close();
    super.dispose();
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

// // ==================================[isolate function processImage ]==================================
    try {
      poses = await _poseDetector.processImage(inputImage);
      print("tempPoseLen ---> ${tempPose.length}");
      Map<String, dynamic> dataNormalizationIsolate = {
        'inputImage': poses.first.landmarks.values,
        'token': rootIsolateTokenNormalization,
        'coordinatesIgnore': ignoreCoordinatesInitialized,
      };

      queueNormalizeData.add(dataNormalizationIsolate);
    } catch (error) {
      print("error at proces image ---> $error");
    }

// // ==================================[isolate function forcoordinatesRelativeBoxIsolate ]==================================
    if (queueNormalizeData.isNotEmpty) {
      compute(coordinatesRelativeBoxIsolate, queueNormalizeData.elementAt(0))
          .then((value) {
        queueNormalizeData.removeAt(0);
        tempPrevCurr.add(value['translatedCoordinates']);

        if (ref.watch(isPerforming) == true) {
          temp = value['translatedCoordinates'];
        }

        setState(() {
          ref.watch(isAllCoordinatesPresent.notifier).state =
              value['allCoordinatesPresent'];
        });

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

// // ==================================[isolate function checkMovement ]==================================
    if (queueMovementData.isNotEmpty) {
      compute(checkMovement, queueMovementData.elementAt(0))
          .then((value) async {
        queueMovementData.removeAt(0);

        if (ref.watch(isPerforming) == true) {
          if (executionCaptured != false) {
            executionStateResult = 1;
          }
          if (temp.isNotEmpty) {
            inferencingList.add(temp);

            temp = [];
          }

          if (value == false) {
            executionCaptured = false;
          }

          if (value == true && executionCaptured == false) {
            noMovementBufferCtr++;
            print("noMovementBufferCtr ---> $noMovementBufferCtr");
            if (inferencingList.isNotEmpty &&
                noMovementBufferCtr == noMovementBufferThreshold) {
              noMovementBufferCtr = 0;
              executionStateResult = 2;

              for (int ctr = 0; ctr != noMovementBufferCtr; ctr++) {
                inferencingList.removeLast();
              }

              ref.read(isCollectingCorrect) == true
                  ? ref.read(coordinatesDataProvider).addItem(inferencingList)
                  : ref
                      .read(incorrectCoordinatesDataProvider)
                      .addItem(inferencingList);

              execTotalFrames = execTotalFrames + inferencingList.length;

              ref.read(numExec.notifier).state++;

              executionCaptured = true;
              print("collected");

              if (minFrame == 0) {
                minFrame = inferencingList.length;
                ref.read(minFrameState.notifier).state = minFrame;
              }

              if (minFrame > inferencingList.length) {
                minFrame = inferencingList.length;
                ref.read(minFrameState.notifier).state = minFrame;
                print("minFrame ---> $minFrame ");
              }

              if (maxFrame < inferencingList.length) {
                maxFrame = inferencingList.length;
                ref.read(maxFrameState.notifier).state = maxFrame;
                print("maxFrame ---> $maxFrame ");
              }

              inferencingList = [];
            }
          }


          avgFrames = execTotalFrames / ref.watch(numExec);
          resultAvgFrames = avgFrames.toStringAsFixed(2);
          avgFrames = double.parse(resultAvgFrames);
          ref.read(averageFrameState.notifier).state = avgFrames;
        }

        if (value == true && ref.watch(isPerforming) == false) {
          if (countDowntoPerform == false) {
            _controller.start();
            countDowntoPerform = true;
            dynamicCountDownText = 'Perform';
          }

          if (_controller.getTime().toString() == "3" &&
              ref.watch(isPerforming) == false) {
            ref.watch(isPerforming.notifier).state = true;
          }
        }
        // -----------------checking for movement before executing for collecting data--------------------------------------

        if (ref.watch(isPerforming) == false &&
            countDowntoPerform == true &&
            value == false) {
          _controller.reset();
          countDowntoPerform = false;
        }
        // -----------------------------------------------------------------------------------------------------------
      }).catchError((error) {
        print("Error at checkMovement ---> $error");
      });
    }

    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      setState(() {
        sizeTemp = inputImage.metadata!.size;
        rotationTemp = inputImage.metadata!.rotation;
        cameraLensDirectionTemp = _cameraLensDirection;
      });

      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
        executionStateResult,
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

  void undoExecution(int undoTimes) {
    int temp = 0;
    int tempexecTotalFrames = execTotalFrames;
    for (int ctr = 0; ctr < undoTimes; ctr++) {
      if (ref.read(coordinatesDataProvider).state.isNotEmpty) {
        tempexecTotalFrames = (tempexecTotalFrames -
                ref.read(coordinatesDataProvider).state.last.length)
            .toInt();
        ref.read(coordinatesDataProvider).state.removeLast();
        ref.read(numExec.notifier).state--;
      }
    }

    setState(() {
      ref.watch(isPerforming.notifier).state = false;

      execTotalFrames = tempexecTotalFrames;
      avgFrames = execTotalFrames / ref.watch(numExec);

      resultAvgFrames = avgFrames.toStringAsFixed(2);
      avgFrames = double.parse(resultAvgFrames);
    });
  }

  void simulateCollectData() {
    print("simulating collection of data");
    for (int ctr = 0; ctr <= 5; ctr++) {
      inferencingList = [];
      for (int ctr1 = 0; ctr1 <= 10; ctr1++) {
        temp = [];
        for (int ctr2 = 0; ctr2 <= 66; ctr2++) {
          temp.add(0.1111111111);
        }
        inferencingList.add(temp);
      }
      print("adding --> $numExec");
      ref.read(coordinatesDataProvider).state.add(inferencingList);
      setState(() {
        ref.read(numExec.notifier).state++;
        ;
      });
    }
    print("translating to txt");
    Map<String, dynamic> translatingIsolate = {
      // 'coordinates': coordinatesData,
      'coordinates': ref.read(coordinatesDataProvider).state,

      'token': rootIsolateTokenTranslating,
    };
  }

  Widget timerCountDown(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textSizeModif = (screenHeight + screenWidth) * textAdaptModifier;
    return Align(
        alignment: Alignment(0.0, -0.2),
        child: CircularCountDownTimer(
          duration: currentDuration,
          initialDuration: 0,
          controller: _controller,
          width: MediaQuery.of(context).size.width / 1.5,
          height: MediaQuery.of(context).size.height / 1.5,
          ringColor: Colors.transparent,
          ringGradient: null,
          fillColor: Colors.white,
          fillGradient: null,
          backgroundColor: Colors.transparent,
          backgroundGradient: null,
          strokeWidth: screenWidth * .10,
          strokeCap: StrokeCap.round,
          textStyle: TextStyle(
              fontSize: 50.0 * textSizeModif,
              color: Colors.white,
              fontWeight: FontWeight.bold),
          textFormat: CountdownTextFormat.S,
          isReverse: false,
          isReverseAnimation: true,
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
            // if (nowPerforming == true) {
            if (ref.watch(isPerforming) == true) {
              return dynamicCountDownText;
            } else {
              return Function.apply(defaultFormatterFunction, [duration]);
            }
          },
        )
        // countdownTimer(context, dynamicCountDownText,
        //     dynamicCountDownColor, _controller)
        );
  }

  void testrecord(int value) {
    ref.read(recording.notifier).state = value;
    print("test record!---> $value");
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textSizeModif = (screenHeight + screenWidth) * textAdaptModifier;
    Widget displayCountdownTimer;
    Widget displayError1;
    Widget displayError2;

    Color color1 = ref.watch(mainColorState);
    Color color2 = ref.watch(secondaryColorState);
    Color color3 = ref.watch(tertiaryColorState);

    var textSizeModifierSet = ref.watch(textSizeModifier);
    var textSizeModifierSetIndividual = textSizeModifierSet["smallText"]!;

    final luminanceValue = ref.watch(luminanceProvider);

    if (ref.watch(isPerforming) == true) {
      displayCountdownTimer = noDisplay();
    } else {
      displayCountdownTimer = timerCountDown(context);
    }

    if (ref.watch(isAllCoordinatesPresent) == false) {
      displayError1 = poseError(
        opacity: 1,
      );
    } else {
      displayError1 = poseError(opacity: 0.0);
    }

    if (luminanceValue <= 50.0) {
      displayError2 = luminanceError(opacity: 1);
    } else {
      displayError2 = luminanceError(opacity: 0.0);
    }
    return ShowCaseWidget(
      builder: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            body: Stack(
              children: [
                Container(
                  color: Colors.amber,
                  width: screenWidth,
                  height: screenHeight,
                ),

                Align(
                  alignment: Alignment.topCenter,
                  // Set top to 0 to cover the entire screen from the top
                  child: Container(
                    width: screenWidth, // Set a specific width
                    height:
                        screenHeight, // Set a specific height or use constraints
                    child: DetectorView(
                      title: 'Pose Detector',
                      customPaint: _customPaint,
                      text: _text,
                      onImage: _processImage,
                      initialCameraLensDirection: _cameraLensDirection,
                      onCameraLensDirectionChanged: (value) =>
                          _cameraLensDirection = value,
                    ),
                  ),
                ),

                displayCountdownTimer,
// -------------------------------------------------------------------[main black thing below :)]
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: screenHeight * 0.11,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(screenHeight * .02),
                        topRight: Radius.circular(screenHeight * .02),
                      ),
                      color: mainColor,
                    ),
                  ),
                ),

// --------------------------------------------------------------------------[BACK ARROW]
                Align(
                  alignment: Alignment(-1.0, 0.78),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: tertiaryColor,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
// --------------------------------------------------------------------------[HELP BUTTON]
                collectionDataTraining(),

//
              ],
            ),
          );
        },
      ),
    );
  }
}
