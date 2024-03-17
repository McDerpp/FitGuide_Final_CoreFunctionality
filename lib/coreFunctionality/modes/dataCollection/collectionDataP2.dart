import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/coreFunctionality/globalVariables.dart';
import 'package:frontend/coreFunctionality/logicFunction/isolateProcessPDV.dart';
import 'package:frontend/coreFunctionality/mainUISettings.dart';
import 'package:frontend/coreFunctionality/misc/painters/pose_painter.dart';
import 'package:frontend/coreFunctionality/misc/poseWidgets/detector_view.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class collectionDataP2 extends ConsumerStatefulWidget {
  const collectionDataP2({super.key});

  @override
  ConsumerState<collectionDataP2> createState() => _collectionDataP2State();
}

class _collectionDataP2State extends ConsumerState<collectionDataP2> {
  @override
  CustomPaint? _customPaint;
  var _cameraLensDirection = CameraLensDirection.front;
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  String? _text;
  // double UIbaseCoordinatesX = 0;
  // double UIbaseCoordinatesY = 0;
  // double UIbaseCoordinatesX_prev = 0;
  // double UIbaseCoordinatesY_prev = 0;
  MediaQueryData? _mediaQueryData;

  bool allCoordinatesPresent = true;

  // double boxRelative_X = 0;
  // double boxRelative_Y = 0;

  // double uiCoor_X = 0;
  // double uiCoor_Y = 0;

  double screenWidthValue = 0;
  double screenHeightValue = 0;

  // double UILocationBasedSize = 0;

  double baseUILocationBasedSize = .35;

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

  void testrecord(int value) {
    ref.read(recording.notifier).state = value;
    print("test record!---> $value");
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
    bool isRecording = false;

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

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment(-0.0, -.88), // Align left horizontally
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tertiaryColor,
                      fixedSize: Size(
                        screenWidthValue * 0.42,
                        screenWidthValue * 0.13,
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      children: [
                        Icon(
                          Icons.fiber_manual_record_outlined,
                          color: secondaryColor,
                          size: screenWidthValue * .07,
                        ),
                        Container(
                          height: screenWidth * 0.09,
                          width: screenWidth * 0.005,
                          color: secondaryColor,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Set crossAxisAlignment to start
                          children: [
                            Text(
                              ' Start ',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize:
                                    screenWidth * textSizeModif['smallText2']!,
                                fontWeight: FontWeight.w400,
                                color: secondaryColor,
                              ),
                            ),
                            Text(
                              ' Recording',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize:
                                    screenWidth * textSizeModif['smallText2']!,
                                fontWeight: FontWeight.w400,
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: [
                  //     SizedBox(
                  //       height: screenHeight * 0.0115,
                  //     ),
                  //     SizedBox(
                  //       height: screenHeight * 0.0001,
                  //     ),
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       children: [
                  //         SizedBox(
                  //           height: screenHeight * 0.0001,
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
          // UIControlsManager(),
          Align(
            alignment: Alignment(0.0, 0.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.stop,
                    color: Colors.red,
                    size: screenWidth * .06, //
                  ),
                  onPressed: () => testrecord(3),
                ),
                IconButton(
                  icon: Icon(
                    Icons.start,
                    color: Colors.red,
                    size: screenWidth * .06, //
                  ),
                  onPressed: () => testrecord(1),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
