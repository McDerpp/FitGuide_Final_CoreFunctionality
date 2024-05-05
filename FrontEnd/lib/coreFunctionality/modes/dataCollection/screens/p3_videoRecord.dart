import 'dart:io';

import 'package:camera/camera.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/coreFunctionality/custom_widgets/customButton.dart';
import 'package:frontend/services/globalVariables.dart';
import 'package:frontend/coreFunctionality/logicFunction/isolateProcessPDV.dart';
import 'package:frontend/coreFunctionality/mainUISettings.dart';
import 'package:frontend/coreFunctionality/misc/painters/pose_painter.dart';
import 'package:frontend/coreFunctionality/misc/poseWidgets/detector_view.dart';
import 'package:frontend/coreFunctionality/custom_widgets/videoPreview.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../../../../services/provider_collection.dart';

class collectionDataP2 extends ConsumerStatefulWidget {
  const collectionDataP2({super.key});

  @override
  ConsumerState<collectionDataP2> createState() => _collectionDataP2State();
}

class _collectionDataP2State extends ConsumerState<collectionDataP2> {
  CustomPaint? _customPaint;
  var _cameraLensDirection = CameraLensDirection.front;
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  String? _text;
  late Map<String, Color> colorSet;
  late Map<String, Color> colorSet2;
  late Map<String, double> textSizeModifierSet;
  late double textSizeModifierSetIndividual;
  String dynamicCountDownText = 'Ready';
  bool isRecording = false;
  bool nowPerforming = false;
  bool nowCountingDown = false;
  bool countDowntoPerform = false;
  bool videoSaved = false;

  GlobalKey recordVideo = GlobalKey();

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    presetMillisecond: StopWatchTimer.getMilliSecFromSecond(0),
    onStopped: () {
      print('onStopped');
    },
    onEnded: () {
      print('onEnded');
    },
  );

  final CountDownController _controller = CountDownController();

  MediaQueryData? _mediaQueryData;

  bool allCoordinatesPresent = true;

  double screenWidthValue = 0;
  double screenHeightValue = 0;

  double baseUILocationBasedSize = .35;

  void changeNowPerformingState() {
    setState(() {
      if (nowPerforming == true) {
        nowPerforming = false;
      } else {
        nowPerforming = true;
      }
    });
  }

  Widget displayErrorPose2(BuildContext context, double opacity) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return IconButton(
      icon: Icon(
        Icons.lightbulb_circle,
        color: ref.watch(secondaryColorState).withOpacity(opacity),
        size: screenWidth * 0.08,
      ),
      onPressed: () {
        setState(() {});
      },
    );
  }

  Widget displayErrorPose(BuildContext context, double opacity) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return IconButton(
      icon: Icon(
        Icons.accessibility_new_sharp,
        color: secondaryColor.withOpacity(opacity),
        size: screenWidth * 0.08,
      ),
      onPressed: () {
        setState(() {});
      },
    );
  }

  @override
  void dispose() async {
    _canProcess = false;
    // _poseDetector.close();
    super.dispose();
  }

  Future<void> _processImage(InputImage inputImage) async {
    setState(() {});
    if (countDowntoPerform == true && nowCountingDown == false) {
      setState(() {
        nowCountingDown = true;
        _controller.start();
      });
    } else {}

    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    late final List<Pose> poses;

    setState(() {
      _text = '';
    });

    poses = await _poseDetector.processImage(inputImage);

    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
        1,
        ref.watch(ignoreCoordinatesProvider),
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = 'Poses found: ${poses.length}\n\n';

      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(
        () {},
      );
    }

    try {
      Map<String, dynamic> dataNormalizationIsolate = {
        'inputImage': poses.first.landmarks.values,
      };

      compute(coordinatesRelativeBoxIsolate, dataNormalizationIsolate)
          .then((value) {
        setState(
          () {
            allCoordinatesPresent = value['allCoordinatesPresent'];
          },
        );
      });
    } catch (e) {
      print(e);
    }
  }

  void testrecord() {
    ref.read(recording.notifier).state = 1;
    setState(() {
      if (isRecording == true) {
        // this is stop
        print("before stop recording --->${ref.watch(recording)}");

        ref.read(recording.notifier).state = 3;
        print("stop recording --->${ref.watch(recording)}");

        isRecording = false;
        videoSaved = true;
      } else {
        print("before now recording --->${ref.watch(recording)}");

        isRecording = true;

        // this is recording
        ref.read(recording.notifier).state = 1;
        print("now recording --->${ref.watch(recording)}");
      }
    });
    print("isRecording --> $isRecording");
    print("videoSaved --> $videoSaved");
  }

  void startStopWatchTimer() {
    print("startStopWatchTimer activated");
    _stopWatchTimer.onStartTimer;
  }

  void resetVarialbes() {
    _stopWatchTimer.onResetTimer();
    setState(() {
      isRecording = false;
      nowPerforming = false;
      nowCountingDown = false;
      countDowntoPerform = false;
      videoSaved = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        _mediaQueryData = MediaQuery.of(context);
        screenWidthValue = _mediaQueryData!.size.width;
        screenHeightValue = _mediaQueryData!.size.height;
      });
    });
  }

  Widget noDisplay() {
    return Container(
      width: 0,
      height: 0,
      color: Colors.transparent,
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
          onStart: () {
            print('Countdown Started');
          },
          onComplete: () {
            print('isRecording 1---> $isRecording');

            setState(() {
              changeNowPerformingState();
              // isRecording = true;
              print('isRecording a---> $isRecording');

              countDowntoPerform = false;
              testrecord();
              _stopWatchTimer.onStartTimer();
            });

            print('isRecording b---> $isRecording');
            print('Countdown Ended B ---> $nowPerforming');

            // setState(() {});
            // print('Countdown Ended A ---> $nowPerforming');
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
        );
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Color mainColor = ref.watch(mainColorState);
    Color secondaryColor = ref.watch(secondaryColorState);
    Color tertiaryColor = ref.watch(tertiaryColorState);
    Map<String, double> textSizeModif = ref.watch(textSizeModifier);
    final luminanceValue = ref.watch(luminanceProvider);
    Widget displayError2;
    Widget displayError1;
    mainColor = ref.watch(mainColorState);
    secondaryColor = ref.watch(secondaryColorState);
    tertiaryColor = ref.watch(tertiaryColorState);
    textSizeModifierSet = ref.watch(textSizeModifier);
    textSizeModifierSetIndividual = textSizeModifierSet["smallText"]!;
    colorSet = ref.watch(ColorSet)["ColorSet1"]!;

    colorSet2 = ref.watch(ColorSet)["ColorSet2"]!;

    if (luminanceValue <= 9) {
      displayError2 = displayErrorPose2(context, 1);
    } else {
      displayError2 = displayErrorPose2(context, 0.0);
    }

    if (allCoordinatesPresent == false) {
      displayError1 = displayErrorPose(context, 1);
    } else {
      displayError1 = displayErrorPose(context, 0.0);
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
                  child: Container(
                    width: screenWidth,
                    height: screenHeight,
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
                nowPerforming == false &&
                        isRecording == false &&
                        videoSaved == true
                    ? noDisplay()
                    : Positioned(
                        top: screenWidth * 0.05,
                        child: Column(
                          children: [
                            SizedBox(
                              width: screenWidth,
                            ),
                            Container(
                              height: screenHeight * 0.06,
                              width: screenHeight * 0.12,
                              decoration: BoxDecoration(
                                color: ref.watch(mainColorState),
                                borderRadius: BorderRadius.circular(
                                    7.0), // Adjust the radius as needed
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  StreamBuilder<int>(
                                    stream: _stopWatchTimer.rawTime,
                                    initialData: _stopWatchTimer.rawTime.value,
                                    builder: (context, snap) {
                                      final value = snap.data;
                                      final displayTime =
                                          StopWatchTimer.getDisplayTime(value!,
                                              minute: true,
                                              hours: false,
                                              milliSecond: false);
                                      return Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              displayTime,
                                              style: TextStyle(
                                                  color: ref.watch(
                                                      tertiaryColorState),
                                                  fontSize: ref.watch(
                                                              textSizeModifier)[
                                                          "mediumText"]! *
                                                      screenWidth,
                                                  fontFamily: 'Helvetica',
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                nowPerforming == false && videoSaved == false
                    ? timerCountDown(context)
                    : noDisplay(),
                Align(
                  alignment: Alignment(-0.0, -.83), // Align left horizontally
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      displayError2,
                      SizedBox(
                        width: screenHeight * 0.005,
                      ),
                      displayError1,
                    ],
                  ),
                ),
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
                      child: Column(
                        children: [
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // make a reset function that resets all to its default value before anything is done or pressed
                              Showcase(
                                key: recordVideo,
                                title: 'Record a video',
                                description:
                                    'Press this to start recording a video. Video is needed to be recorded for reference/tutorial for the exercise.',
                                child: buildElevatedButton(
                                  context: context,
                                  label: nowPerforming == false
                                      ? "Record"
                                      : "Stop",
                                  colorSet: nowPerforming == false
                                      ? colorSet
                                      : colorSet2,
                                  textSizeModifierIndividual:
                                      ref.watch(textSizeModifier)["smallText"]!,
                                  func: () {
                                    isRecording == true ? testrecord() : null;

                                    nowPerforming == false
                                        ? null
                                        : _stopWatchTimer.onStopTimer();
                                    nowPerforming == false
                                        ? null
                                        : changeNowPerformingState();
                                    setState(() {
                                      nowPerforming == false
                                          ? countDowntoPerform = true
                                          : null;
                                      videoSaved == true
                                          ? resetVarialbes()
                                          : null;
                                    });
                                  },
                                ),
                              ),
                              // ref.watch(vidPath) != ""
                              //     ? Stack(
                              //         children: [
                              //           Container(
                              //             height: screenHeight,
                              //             width: screenWidth,
                              //             color:
                              //                 Colors.black87.withOpacity(0.85),
                              //           ),
                              //           VideoPreviewScreen(
                              //             videoPath: ref.watch(vidPath),
                              //             isInferencingPreview: true,
                              //           )
                              //         ],
                              //       )
                              //     : noDisplay()
                            ],
                          ),
                        ],
                      )),
                ),
                // UIControlsManager(),

                Align(
                  alignment: Alignment(1.0, 0.78),
                  child: IconButton(
                    icon: Icon(
                      Icons.question_mark,
                      color: tertiaryColor,
                    ),
                    onPressed: () {
                      ShowCaseWidget.of(context).startShowCase([
                        recordVideo,
                      ]);
                    },
                  ),
                ),

                ref.watch(vidPath) != ""
                    ? Stack(
                        children: [
                          Container(
                            height: screenHeight,
                            width: screenWidth,
                            color: Colors.black87.withOpacity(0.85),
                          ),
                          VideoPreviewScreen(
                            videoPath: ref.watch(vidPath),
                            isInferencingPreview: false,
                          )
                        ],
                      )
                    : noDisplay()
              ],
            ),
          );
        },
      ),
    );
  }
}
