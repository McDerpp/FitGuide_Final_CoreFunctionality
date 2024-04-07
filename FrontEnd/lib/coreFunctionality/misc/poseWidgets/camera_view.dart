import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/coreFunctionality/modes/globalStuff/provider/globalVariables.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../modes/dataCollection/services/provider_collection.dart';

class CameraView extends ConsumerStatefulWidget {
  CameraView(
      {Key? key,
      required this.customPaint,
      required this.onImage,
      this.onCameraFeedReady,
      this.onDetectorViewModeChanged,
      this.onCameraLensDirectionChanged,
      this.initialCameraLensDirection = CameraLensDirection.front})
      : super(key: key);

  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  ConsumerState<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends ConsumerState<CameraView> {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  int _cameraIndex = -1;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  double _currentExposureOffset = 0.0;
  bool _changingCameraLens = false;

  XFile? imageFile;
  XFile? videoFile;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

// ============================================================================================[]
//  IconButton(
//           icon: const Icon(Icons.stop),
//           color: Colors.red,
//           onPressed: _controller != null &&
//                   _controller!.value.isInitialized &&
//                   _controller!.value.isRecordingVideo
//               ? onStopButtonPressed
//               : null,
//         )

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = _controller;
    print("stopVideoRecording3");

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      print("stopVideoRecording2");

      return null;
    }

    try {
      print("stopVideoRecording1");
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _startVideoPlayer() async {
    print("recording");
    if (videoFile == null) {
      return;
    }

    final VideoPlayerController vController = kIsWeb
        ? VideoPlayerController.networkUrl(Uri.parse(videoFile!.path))
        : VideoPlayerController.file(File(videoFile!.path));

    videoPlayerListener = () {
      if (videoController != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) {
          setState(() {});
        }
        videoController!.removeListener(videoPlayerListener!);
      }
    };
    vController.addListener(videoPlayerListener!);
    await vController.setLooping(true);
    await vController.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imageFile = null;
        videoController = vController;
      });
    }
    await vController.play();
  }

// ====================================================================================
  void onVideoRecordButtonPressed() {
    print("onVideoRecordButtonPressed1234");

    startVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = _controller;
    print("startVideoRecording1234");

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording(
          onAvailable: (CameraImage? image) {
        // print("imagetstsetset ---> $image");
        _processCameraImage(image!);
      });
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }

// // ====================================================================================

  void onStopButtonPressed() {
    stopVideoRecording().then((XFile? file) {
      if (mounted) {
        setState(() {});
      }
      if (file != null) {
        showInSnackBar('Video recorded to ${file.path}');
        ref.watch(vidPath.notifier).state = file.path;

        videoFile = file;
        ref.read(recording.notifier).state = 0;
      } else {}

      ref.read(recording.notifier).state = 0;
      _controller?.startImageStream(_processCameraImage).then((value) {});
    });
  }

  void checkingRecordState() {}

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _liveFeedBody();
  }

  Widget _liveFeedBody() {
    if (_cameras.isEmpty ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return Container();
    }
    final scale = 1 /
        (_controller!.value.aspectRatio *
            MediaQuery.of(context).size.aspectRatio);

    return Transform.scale(
      // scale: scale * 0.85,
      scaleX: scale * 0.80,
      scaleY: scale * 0.65,
      alignment: Alignment.topCenter,
      child: CameraPreview(
        _controller!,
        child: widget.customPaint ?? Text("erewrwr"),
      ),
    );

    // return Container(
    //   color: Colors.black,
    //   child: Stack(
    //     children: <Widget>[
    //       Center(
    //         child: _changingCameraLens

    //             ? Center(
    //                 child: const Text('Changing camera lens'),
    //               )
    //             : CameraPreview(
    //                 _controller!,
    //                 child: widget.customPaint,
    //               ),
    //       ),
    //       _backButton(),
    //       // Add other widgets as needed
    //     ],
    //   ),
    // );
  }

  Widget _backButton() => Positioned(
        top: 40,
        left: 8,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: Colors.black54,
            child: Icon(
              Icons.arrow_back_ios_outlined,
              size: 20,
            ),
          ),
        ),
      );

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    // If the controller is updated then update the UI.
    // _controller!.addListener(() {
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });

    // try {
    //   await _controller!.initialize();
    // } on CameraException catch (e) {
    //   switch (e.code) {
    //     case 'CameraAccessDenied':
    //       showInSnackBar('You have denied camera access.');
    //       break;
    //     case 'CameraAccessDeniedWithoutPrompt':
    //       // iOS only
    //       showInSnackBar('Please go to Settings app to enable camera access.');
    //       break;
    //     case 'CameraAccessRestricted':
    //       // iOS only
    //       showInSnackBar('Camera access is restricted.');
    //       break;
    //     case 'AudioAccessDenied':
    //       showInSnackBar('You have denied audio access.');
    //       break;
    //     case 'AudioAccessDeniedWithoutPrompt':
    //       // iOS only
    //       showInSnackBar('Please go to Settings app to enable audio access.');
    //       break;
    //     case 'AudioAccessRestricted':
    //       // iOS only
    //       showInSnackBar('Audio access is restricted.');
    //       break;
    //     default:
    //       _showCameraException(e);
    //       break;
    //   }
    // }

    // if (mounted) {
    //   setState(() {});
    // }

    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        _currentZoomLevel = value;
        _minAvailableZoom = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        _maxAvailableZoom = value;
      });
      _currentExposureOffset = 0.0;
      _controller?.getMinExposureOffset().then((value) {
        _minAvailableExposureOffset = value;
      });
      _controller?.getMaxExposureOffset().then((value) {
        _maxAvailableExposureOffset = value;
      });
      _controller?.startImageStream(_processCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
        if (widget.onCameraLensDirectionChanged != null) {
          widget.onCameraLensDirectionChanged!(camera.lensDirection);
        }
      });
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  double _calculateAverageLuminance(CameraImage image) {
    final int plane = 0; // Y plane

    final Uint8List bytes = image.planes[plane].bytes;

    double sum = 0;
    double results = 0;
    int bytesLength = bytes.length ~/ 2;

    for (int i = 0; i < bytesLength / 2; i++) {
      if (i % 2 == 0) {
        results += bytes[i];
      }
    }
    results = results / bytes.length;
    print("light results ---> $results");
    return results;
  }

  void _processCameraImage(CameraImage image) {
    ref.read(luminanceProvider.notifier).state =
        _calculateAverageLuminance(image);

    final CameraController? cameraController = _controller;

    int recordings = ref.watch(recording);
    print("recordingState ---> $recordings ");

    if (cameraController!.value.isInitialized == true) {
      print("cameraController!.value.isInitialized1234456456546");
    } else {
      print("cameraController!.value.isInitialized12346456546456---not");
    }

    if (!cameraController.value.isRecordingVideo == true) {
      print("testing0912323423");
    } else {
      print("testing0912323423---not");
    }

    if (cameraController! != null) {
      print("cameraControllerg0912323423");
    } else {
      print("testing0912323423---not");
    }

    if (recordings == 1) {
      ref.read(recording.notifier).state = 2;
      cameraController != null &&
              cameraController.value.isInitialized &&
              !cameraController.value.isRecordingVideo
          ? onVideoRecordButtonPressed()
          : null;
      print("recording---------------2222222222");
    }

    if (recordings == 3) {
      ref.read(recording.notifier).state = 0;
      if (cameraController!.value.isRecordingVideo == true) {
        print("isRecording1234");
      } else {
        print("notRecording1234");
      }

      if (cameraController.value.isInitialized == true) {
        print("isInitialized1234");
      } else {
        print("notInitialized1234");
      }

      // cameraController != null &&
      cameraController.value.isInitialized &&
              cameraController.value.isRecordingVideo
          ? onStopButtonPressed()
          : null;
      print("stop recording---------------------------------111111");
    }

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    widget.onImage(inputImage);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print('rotationCompensation: $rotationCompensation');
    }
    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}
