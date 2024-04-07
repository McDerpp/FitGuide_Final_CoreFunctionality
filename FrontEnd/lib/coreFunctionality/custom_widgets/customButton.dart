import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:frontend/coreFunctionality/modes/globalStuff/provider/globalVariables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logicFunction/isolateProcessPDV.dart';
import '../mainUISettings.dart';

Widget buildElevatedButton({
  required BuildContext context,
  required String label,
  required Map<String, Color> colorSet,
  required double textSizeModifierIndividual,
  required Function func,
  optionalModif = 0.8,
}) {
  print("colorSet-> $colorSet");
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  dynamic textsize = textSizeModifierIndividual;
  print("textsize===$textsize.state");
  textsize = textsize * screenWidth;

  dynamic buttonSizeX = screenWidth * 0.35 * optionalModif;
  dynamic buttonSizeY = screenHeight * 0.008 * optionalModif;

  Size minSize = Size(buttonSizeX, buttonSizeY);
  Size maxSize = Size(buttonSizeX, buttonSizeY);

  return Padding(
    padding: EdgeInsets.only(
      left: 0.05 * buttonSizeX,
      right: 0.05 * buttonSizeX,
      top: 0.05 * buttonSizeX,
      bottom: 0.05 * buttonSizeX,
    ),
    child: Align(
      alignment: Alignment(1.0, 0.8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          // backgroundColor: colorSet['secondaryColorState'],
          backgroundColor: colorSet['tertiaryColor'],

          fixedSize: minSize,
          // padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 2.0),
        ),
        onPressed: () {
          func();
        },
        child: Text(
          label,
          style: TextStyle(
            fontSize: textsize,
            color: colorSet['mainColor'],
          ),
        ),
      ),
    ),
  );
}
