import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/coreFunctionality/custom_widgets/errorWidget.dart';
import 'package:frontend/coreFunctionality/mainUISettings.dart';
import 'package:frontend/coreFunctionality/modes/dataCollection/screens/p4_exerciseDetail.dart';
import 'package:frontend/services/globalVariables.dart';
import 'package:frontend/services/provider_collection.dart';
import 'package:video_player/video_player.dart';

import 'customButton.dart';

class dialogVideoPreview extends ConsumerStatefulWidget {
  final dynamic videoPath;
  final bool isInferencingPreview;

  dialogVideoPreview({
    required this.videoPath,
    this.isInferencingPreview = false,
  });

  @override
  ConsumerState<dialogVideoPreview> createState() => _dialogVideoPreviewState();
}

class _dialogVideoPreviewState extends ConsumerState<dialogVideoPreview> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = widget.isInferencingPreview == true
        ? VideoPlayerController.asset(widget.videoPath)
        : VideoPlayerController.file((widget.videoPath));
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
    _controller.setLooping(true);
    _controller.play();
    final colorSet = ref.watch(ColorSet);
    final textModif = ref.watch(textSizeModifier);

    return AlertDialog(
      backgroundColor: colorSet["ColorSet1"]?["mainColor"],
      content: Container(
        width: _controller.value.size.width * 0.5,
        height: _controller.value.size.height * 0.5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              children: [
                VideoPlayer(_controller),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildElevatedButton(
              context: context,
              label: "Close",
              colorSet: colorSet["ColorSet1"]!,
              textSizeModifierIndividual: textModif['smallText2']!,
              func: () {
                _controller.pause();
                Navigator.pop(context);
              },
            ),
          ],
        )
      ],
    );
  }
}
