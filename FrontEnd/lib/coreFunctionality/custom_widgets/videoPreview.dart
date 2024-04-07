import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/coreFunctionality/modes/dataCollection/screens/collectionDataP3.dart';
import 'package:frontend/coreFunctionality/modes/globalStuff/provider/globalVariables.dart';
import 'package:video_player/video_player.dart';

import '../modes/dataCollection/services/provider_collection.dart';
import 'customButton.dart';

class VideoPreviewScreen extends ConsumerStatefulWidget {
  final String videoPath;
  final bool isInferencingPreview;

  VideoPreviewScreen({
    required this.videoPath,
    this.isInferencingPreview = false,
  });

  @override
  _VideoPreviewScreenState createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends ConsumerState<VideoPreviewScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void dialog(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double vidSizeModifier = 0.6;
    double vidHeight = _controller.value.size.height * vidSizeModifier;
    double vidWidth = _controller.value.size.width * vidSizeModifier;

    Map<String, double> textSizeModif = ref.watch(textSizeModifier);

    Color mainColor = ref.watch(mainColorState);
    Color secondaryColor = ref.watch(secondaryColorState);
    Color tertiaryColor = ref.watch(tertiaryColorState);
    _controller.setLooping(true);
    _controller.play();

    late Map<String, Color> colorSet;
    colorSet = {
      "mainColor": mainColor,
      "secondaryColor": secondaryColor,
      "tertiaryColor": tertiaryColor,
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: screenWidth * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FutureBuilder(
                      future: _initializeVideoPlayerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      buildElevatedButton(
                        context: context,
                        label: widget.isInferencingPreview == false
                            ? "Submit"
                            : "Close",
                        colorSet: colorSet,
                        textSizeModifierIndividual:
                            textSizeModif['smallText2']!,
                        func: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const collectionDataP3(),
                              // const collectionDataP2(),
                            ),
                          );
                        },
                      ),
                    ])
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textSizeModif =
        (screenHeight + screenWidth) * ref.watch(textAdaptModifierState);

    var textSizeModifierSet = ref.watch(textSizeModifier);
    var textSizeModifierSetIndividual = textSizeModifierSet["smallText"]!;
    late Map<String, Color> colorSet;

    Color mainColor = ref.watch(mainColorState);
    Color secondaryColor = ref.watch(secondaryColorState);
    Color tertiaryColor = ref.watch(tertiaryColorState);
    textSizeModifierSet = ref.watch(textSizeModifier);
    textSizeModifierSetIndividual = textSizeModifierSet["smallText"]!;
    colorSet = {
      "mainColor": mainColor,
      "secondaryColor": secondaryColor,
      "tertiaryColor": tertiaryColor,
    };

    return Container(
        child: buildElevatedButton(
      context: context,
      label: widget.isInferencingPreview == false ? "Submit" : "Preview",
      colorSet: colorSet,
      textSizeModifierIndividual: textSizeModifierSetIndividual,
      func: () {
        dialog(context);
      },
    ));
  }
}
