import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/coreFunctionality/custom_widgets/errorWidget.dart';
import 'package:frontend/coreFunctionality/modes/dataCollection/screens/p4_exerciseDetail.dart';
import 'package:frontend/coreFunctionality/modes/globalStuff/provider/globalVariables.dart';
import 'package:frontend/services/provider_collection.dart';
import 'package:video_player/video_player.dart';

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
    _controller = widget.isInferencingPreview == true
        ? VideoPlayerController.asset(widget.videoPath)
        : VideoPlayerController.file(File(widget.videoPath));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> textSizeModif = ref.watch(textSizeModifier);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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

    _controller.setLooping(true);
    _controller.play();

    return Center(
      child: Container(
        width:
            _controller.value.size.width * 0.65, // Adjust the width as needed
        height:
            _controller.value.size.height * 0.65, // Adjust the height as needed
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              children: [
                VideoPlayer(_controller),
                Positioned(
                  bottom: 4.0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildElevatedButton(
                        context: context,
                        label: widget.isInferencingPreview == false
                            ? "Submit"
                            : "Close",
                        colorSet: colorSet,
                        textSizeModifierIndividual:
                            textSizeModif['smallText2']!,
                        func: () {
                          widget.isInferencingPreview == false
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const collectionDataP3(),
                                  ),
                                )
                              : ref.watch(showPreviewProvider.notifier).state =
                                  false;
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
