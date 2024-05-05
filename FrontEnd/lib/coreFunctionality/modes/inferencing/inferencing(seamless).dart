import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

// Note: heavy imports...may cause lots of load times in between running
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/coreFunctionality/custom_widgets/customButton.dart';
import 'package:frontend/coreFunctionality/custom_widgets/dialogBox.dart';
import 'package:frontend/coreFunctionality/custom_widgets/dialogBoxNotif.dart';
import 'package:frontend/coreFunctionality/custom_widgets/videoPreview.dart';
import 'package:frontend/services/provider_collection.dart';
import 'package:frontend/services/globalVariables.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

// UI related imports
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

// file imports
import '../../misc/painters/pose_painter.dart';
import 'package:frontend/coreFunctionality/misc/poseWidgets/detector_view.dart';
import '../../logicFunction/isolateProcessPDV.dart';
// import '../../extraWidgets/customWidgetPDV.dart';
import '../../mainUISettings.dart';
import 'inferencingP1.dart';
// import '../../logicFunction/processLogic.dart';

class inferencingSeamless extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> exerciseList;

  const inferencingSeamless({
    super.key,
    required this.exerciseList,
  });

  @override
  ConsumerState<inferencingSeamless> createState() =>
      _inferencingSeamlessState();
}

class _inferencingSeamlessState extends ConsumerState<inferencingSeamless> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

// ADJUSTABLE VARIABLES
  int showPreviewCtrMax = 250;

// THIS IS TEMPORARY FOR DEBUGGING ONLY! CHANGE THIS TO ACTUAL INPUT REQUIRED
  int tensorInputNeeded = 9;

// exercise detials
  String nameOfExercise = "";
  String model = "";
  String video = "";
  List<String> ignoredCoordinates = [];
  int numberOfExecution = 0;
  int setsNeeded = 0;
  int restDuration = 0;

  // isolate initialization for heavy process
  RootIsolateToken rootIsolateTokenNormalization = RootIsolateToken.instance!;
  RootIsolateToken rootIsolateTokenNoMovement = RootIsolateToken.instance!;
  RootIsolateToken rootIsolateTokenInferencing = RootIsolateToken.instance!;

  List<double> prevCoordinates = [];
  List<double> currentCoordinates = [];
  List<List<double>> inferencingList = [];
  List<List<double>> tempPrevCurr = [];
  int framesCapturedCtr = 0;

  String resultAvgFrames = '';
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

  int showPreviewCtr = 0;
  bool showPreviewPass = false;

  // List<Map<String, dynamic>> itemsContainer = [];

  // ---------------------countdown variables----------------------------------------------------------
  late int _seconds;
  late Timer _timer;

  List<double> translatedCoordinates = [];
  List<dynamic> coordinatesData = [];
  bool isSet = true;
  int collectingCtr = 0;
  double _progress = 0.0;
  int currentDuration2 = 5;
  List<int> igrnoreCoordinatesList = [];
  int executionStateResult = 0;
  bool allCoordinatesPresent = false;
  bool restState = false;
  bool restingInitialized = false;

  int buffer = 0;
  int bufferCtr = 0;

  List<bool> inferenceBuffer = [];

  late int inferencingBuffer;
  // ---------------------inferencing data mode variables----------------------------------------------------------
  int inferenceCorrectCtr = 0;
  int setsAchieved = 0;
  int exerciseListCtr = 0;

  late int maxExerciseList;
  late List<Map<String, dynamic>> tempExerciseList;

  // ---------------------countdown variables----------------------------------------------------------
  final CountDownController _controller = CountDownController();
  final CountDownController _controller2 = CountDownController();

  bool nowPerforming = false;
  bool countDowntoPerform = false;
  bool checkCountDowntoPerform = false;

  String dynamicCountDownText = 'Ready';
  Color dynamicCountDownColor = secondaryColor;

  late int inputSequenceNeeded;

  @override
  void initState() {
    super.initState();
    try {
      paddingInitialize();
      modelInitialize(widget.exerciseList[0]['modelPath']);
      int currentDuration2 = 3;
    } catch (error) {
      print("error at initialization of inferencing --> $error");
    }
    _seconds = 60;
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
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    late final List<Pose> poses;
    // bool noMovement = false;

    setState(() {
      _text = '';
    });

// [ISOLATE FUNCTION] PROCESSING IMAGE ==========================================================================================================================
    try {
      poses = await _poseDetector.processImage(inputImage);
      Map<String, dynamic> dataNormalizationIsolate = {
        'inputImage': poses.first.landmarks.values,
        'token': rootIsolateTokenNormalization,
        'coordinatesIgnore': igrnoreCoordinatesList,
      };
      queueNormalizeData.add(dataNormalizationIsolate);
    } catch (error) {
      print("error at proces image ---> $error");
    }

// buffering code
    bufferCtr++;

// [ISOLATE FUNCTION] INFERENCING ==========================================================================================================================
    if (queueNormalizeData.isNotEmpty) {
      print("normalizing data");
// buffering code
      if (bufferCtr >= buffer) {
        bufferCtr = 0;

        compute(coordinatesRelativeBoxIsolate, queueNormalizeData.elementAt(0))
            .then((value) {
          queueNormalizeData.removeAt(0);
// this is a list that stores coordinates for checking of movement
          tempPrevCurr.add(value['translatedCoordinates']);

// if its performing(after countdown) then collect translated coordinates to be compiled later on
// later on... the checkmovement it will be checked if previous present coordinates has gone beyond the threshold
// if yes then this coordinate is compiled
          if (nowPerforming == true) {
            translatedCoordinates = value['translatedCoordinates'];
          }

//checking for all relevant coordinates are present
          setState(() {
            allCoordinatesPresent = value['allCoordinatesPresent'];
          });

// if the list is above 1 length then get 2 set of translated sequences
// this will be in queue and be processed in the check movement isolate function
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
      } else {
        queueNormalizeData.removeAt(0);
        print("buffering...");
      }
    }

// =====================================================================================================================================================

    try {
      if (restState == true && restingInitialized == false) {
        restingInitialized = true;
        _controller.restart(duration: 10);
        print("initializingRest ----? $restingInitialized");

        nowPerforming = false;
      }
    } catch (error) {
      print("ERROR AT NEW IMPLEMENTATION ---> $error");
      CountDownController _controller = CountDownController();
      _controller.restart(duration: 10);
    }

// [ISOLATE FUNCTION] MOVEMENT CHECK ==========================================================================================================================
    if (queueMovementData.isNotEmpty) {
      // false = movement
      // true = no movement
      compute(checkMovement, queueMovementData.elementAt(0))
          .then((value) async {
        queueMovementData.removeAt(0);

// if rest state is true but it has not started yet then initialize or start it--------------------------------------------------------------------------
        // nowPerforming = true;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxXXXXXXXXXXXXXXXXXXXXXXXXXXX
        if (value == true) {
// this is checking for at the start of the exercise if movement is detected or not
// if detected then it will start countdown otherwise it will restart
          if (nowPerforming == false && restState == false) {
            if (countDowntoPerform == false) {
              _controller.start();
              countDowntoPerform = true;
            }
          }

          // reststate countdown is done and resetting
          if (_controller.getTime().toString() == "10" &&
              nowPerforming == false &&
              restState == true) {
            print("ENTERING REST STATE");
            nowPerforming = true;
            restState = false;
            restingInitialized = false;
          }

          if (_controller.getTime().toString() == "3" &&
              nowPerforming == false &&
              restState == false) {
            nowPerforming = true;
          }

//for recording metrics
          setState(() {
            try {
              avgFrames = execTotalFrames / numExec;
              resultAvgFrames = avgFrames.toStringAsFixed(2);
              avgFrames = double.parse(resultAvgFrames);
            } catch (error) {
              avgFrames = 0;
            }
          });
        } else {
          setState(() {
            dynamicText = 'movement detected';
            dynamicCtr = noMovementCtr.toString();
          });
        }
      }).catchError((error) {
        print("Error at checkMovement ---> $error");
      });
    }
// =====================================================================================================================================================

// checking if number of execution is achieved
// if yes proceed to rest state
// rest state will then count down to proceed with another set
    if (inferenceCorrectCtr == numberOfExecution) {
      setsAchieved = setsAchieved + 1;
      nowPerforming = false;
      inferenceCorrectCtr = 0;
      restState = true;

// if all the sets have been performed
      if (setsAchieved == setsNeeded) {
        dialogBoxNotif(context, 3, "aasetsdaf");
        ref.watch(showPreviewProvider.notifier).state = true;
        setState(() {
          if (exerciseListCtr <= maxExerciseList) {
            exerciseListCtr++;
          }
          setsAchieved = 0;
        });
      }
    }

// checks if performing state is available(after countdown)--------------------------------------------------------------------------
    try {
      if (nowPerforming == true) {
        if (inferencingList.isNotEmpty &&
            inferencingList.length >= tensorInputNeeded) {
          setState(() {
            executionStateResult = 2;
          });
          dynamicCountDownText = 'collected';
          dynamicCountDownColor = secondaryColor;
          // coordinatesData.add(inferencingList);

          inferencingData = {
            'coordinatesData': inferencingList,
            'token': rootIsolateTokenInferencing,
          };
          numExec++;
          queueInferencingData.add(inferencingData);

          if (inferencingList.length == tensorInputNeeded) {
            inferencingList.removeAt(0);
          }
        } else {
          // inferencingList.removeAt(0);
          // inferencingList = [];
//
        }
      }
    } catch (error) {
      print("error at new implemented ---> ${error}");
    }

// if its is performing(after countdown)----------------------------------------------------------------------------------------------------------------------
    if (nowPerforming == true && translatedCoordinates.isNotEmpty) {
      inferencingList.add(translatedCoordinates);
      translatedCoordinates = [];
    }

// [ISOLATE FUNCTION] INFERENCING ==========================================================================================================================
    if (queueInferencingData.isNotEmpty && nowPerforming == true) {
      inferencingCoordinatesData(queueInferencingData.elementAt(0), model,
              widget.exerciseList[exerciseListCtr]['inputNum'])
          .then((value) {
        if (inferenceBuffer.length == 2) {
          inferenceBuffer.removeAt(0);
          inferenceBuffer.add(value);
        } else {
          inferenceBuffer.add(value);
        }

        if (value == true) {
          if (ref.watch(showPreviewProvider) == false) {
            if (inferenceBuffer.elementAt(0) == false &&
                inferenceBuffer.elementAt(1) == true &&
                nowPerforming == true) {
              inferenceCorrectCtr++;

              showPreviewCtr = 0;
            }
          }
          if (ref.watch(showPreviewProvider) == true) {
            setState(() {
              ref.watch(showPreviewProvider.notifier).state = false;
              // showPreviewPass = true;
              dialogBoxNotif(context, 2, "aasetsdaf");
            });
            showPreviewCtr = 0;
          }
          dynamicCountDownColor = Color.fromARGB(255, 3, 104, 8);
        } else {
          dynamicCountDownColor = Color.fromARGB(255, 255, 0, 0);
          if (ref.watch(showPreviewProvider) == false) {
            showPreviewCtr++;
          }

          if (showPreviewCtr == showPreviewCtrMax &&
              ref.watch(showPreviewProvider) == false) {
            dialogBoxNotif(context, 1, "aasetsdaf");

            setState(
              () {
                ref.watch(showPreviewProvider.notifier).state = true;
              },
            );
          }
        }
        if (queueInferencingData.isNotEmpty) {
          queueInferencingData.removeAt(0);
        }
      }).catchError((error) {
        print("Error at inferencing data ---> $error");
      });
    }

// =====================================================================================================================================================

    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
        executionStateResult,
        //=========================================================================> NEEDS TO BE INITIALIZED FIRST FOR INFERENCING TO CHECK THE IGNORE COORDINATES
        ref.watch(ignoreCoordinatesProvider)
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

  void generateItemsContainer(int numOfExercise) {}

  Widget noDisplay() {
    return Container(
      width: 0,
      height: 0,
      color: Colors.transparent,
    );
  }

  Widget displayErrorPose(BuildContext context, double opacity) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Icon(
      Icons.accessibility_new_sharp,
      color: secondaryColor.withOpacity(opacity),
      size: screenWidth * 0.07,
    );
  }

  Widget displayErrorPose2(BuildContext context, double opacity) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Icon(
      Icons.lightbulb_circle,
      color: secondaryColor.withOpacity(opacity),
      size: screenWidth * 0.07,
    );
  }

  Widget buildContainerList(
    int numofContainer,
    int numofCompleted,
    BuildContext context, {
    double spaceModifier = .8,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    List<Widget> containers = [];
    int ctr = 0;

    for (int i = 0; i < numofContainer; i++) {
      ctr++;
      if (ctr <= numofCompleted) {
        containers.add(
          Row(
            children: [
              containers.isNotEmpty
                  ? SizedBox(
                      width: ((screenWidth * spaceModifier) / numofContainer) *
                          .10,
                    )
                  : Container(),
              Container(
                width: ((screenWidth * spaceModifier) / numofContainer) * .90,
                height: (screenHeight * .010),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.07),
                  color: secondaryColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        );
      } else {
        containers.add(
          Row(
            children: [
              containers.isNotEmpty
                  ? SizedBox(
                      width: ((screenWidth * spaceModifier) / numofContainer) *
                          .10,
                    )
                  : SizedBox(
                      width: 0,
                    ),
              Container(
                width: ((screenWidth * spaceModifier) / numofContainer) * .90,
                height: (screenHeight * .015),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.07),
                  color: tertiaryColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        );
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: containers,
    );
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
          onStart: () {},
          onComplete: () {},
          onChange: (String timeStamp) {},
          timeFormatterFunction: (defaultFormatterFunction, duration) {
            print("duration --> $duration");
            return Function.apply(defaultFormatterFunction, [duration]);

            // if (nowPerforming == true) {
            //   return dynamicCountDownText;
            // } else {
            //   return Function.apply(defaultFormatterFunction, [duration]);
            // }
          },
        )
        // countdownTimer(context, dynamicCountDownText,
        //     dynamicCountDownColor, _controller)
        );
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

    // exercise details------------------------------------------------------------
    maxExerciseList = widget.exerciseList.length;
    buffer = ref.watch(bufferProvider);

    try {
      if (exerciseListCtr <= maxExerciseList) {
        ref.read(inputNumProvider.notifier).state =
            widget.exerciseList[exerciseListCtr]['inputNum'];
        nameOfExercise = widget.exerciseList[exerciseListCtr]['nameOfExercise'];
        model = widget.exerciseList[exerciseListCtr]['modelPath'];
        // video = widget.exerciseList[exerciseListCtr]['videoPath'];
        ref.watch(videoPreviewProvider.notifier).state =
            widget.exerciseList[exerciseListCtr]['videoPath'];

        ignoredCoordinates =
            widget.exerciseList[exerciseListCtr]['ignoredCoordinates'];
        restDuration = widget.exerciseList[exerciseListCtr]['restDuration'];
        setsNeeded = widget.exerciseList[exerciseListCtr]['setsNeeded'];
        numberOfExecution =
            widget.exerciseList[exerciseListCtr]['numberOfExecution'];
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => inferencingP1(
              exerciseProgram: widget.exerciseList,
            ),
          ),
        );
      }
    } catch (error) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => inferencingP1(
            exerciseProgram: widget.exerciseList,
          ),
        ),
      );
    }

    inferencingBuffer = (tensorInputNeeded * 0.5).toInt();

    final luminanceValue = ref.watch(luminanceProvider);

    if (nowPerforming == true) {
      displayCountdownTimer = noDisplay();
    } else {
      displayCountdownTimer = timerCountDown(context);
    }

    if (allCoordinatesPresent == false) {
      displayError1 = displayErrorPose(context, 1);
    } else {
      displayError1 = displayErrorPose(context, 0.0);
    }

    if (luminanceValue <= 50.0) {
      displayError2 = displayErrorPose2(context, 1);
    } else {
      displayError2 = displayErrorPose2(context, 0.0);
    }

    final colorSetState = ref.watch(ColorSet);
    final colorSet1 = colorSetState["ColorSet1"]!;

    var textSizeModifierSet = ref.watch(textSizeModifier);
    var textSizeModifierSetIndividual = textSizeModifierSet["smallText"]!;

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              color: Colors.amber,
              width: screenWidth,
              height: screenHeight * 1.5,
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: screenWidth, // Set a specific width
              height: screenHeight, // Set a specific height or use constraints
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

// -----------------------------------------------------------------------------------------------------------[Current Exercise Description]

          displayCountdownTimer,

          // Positioned(
          //   bottom: screenHeight * .025,
          //   left: screenWidth * .07,
          //   child:
          // ),
          Positioned(
            bottom: screenHeight * 0.15,
            child: Container(
              width: screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildContainerList(
                      widget.exerciseList.length, exerciseListCtr, context,
                      spaceModifier: 0.8),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment(0, .98),
            child: Container(
              width: screenWidth * 0.95,
              height: screenHeight * 0.13,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
              ),
              child: Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  child: LinearProgressIndicator(
                    minHeight: screenHeight * 0.5,
                    value: inferenceCorrectCtr / numberOfExecution,
                    backgroundColor: mainColor.withOpacity(0.9),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        secondaryColor.withOpacity(0.5)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0), // Adjust the padding as needed
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "${nameOfExercise}",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 28.0 * textSizeModif,
                              fontWeight: FontWeight.w800,
                              color: tertiaryColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Reps:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19.0 * textSizeModif,
                              fontWeight: FontWeight.w300,
                              color: tertiaryColor,
                            ),
                          ),
                          Text(
                            "  ${inferenceCorrectCtr} / ${numberOfExecution}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19.0 * textSizeModif,
                              fontWeight: FontWeight.w300,
                              color: tertiaryColor,
                            ),
                          ),
                          SizedBox(
                            width: screenWidth * 0.1,
                          ),
                          Text(
                            "Sets:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19.0 * textSizeModif,
                              fontWeight: FontWeight.w300,
                              color: tertiaryColor,
                            ),
                          ),
                          Text(
                            "  ${setsAchieved} / ${setsNeeded}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19.0 * textSizeModif,
                              fontWeight: FontWeight.w300,
                              color: tertiaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),

          Align(
            alignment: Alignment(-1.0, 0.7),
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
          Align(
            alignment: Alignment(1.0, 0.7),
            child: IconButton(
              icon: Icon(
                Icons.question_mark,
                color: tertiaryColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

// -----------------------------------------------------------------------------------------------------------[Error Indicator Pose]
          Positioned(
            top: screenWidth * 0.1,
            child: Container(
              width: screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  displayError2,
                  displayError1,
                ],
              ),
            ),
          ),

// -----------------------------------------------------------------------------------------------------------[Progress Container]
        ],
      ),
    );
  }
}
