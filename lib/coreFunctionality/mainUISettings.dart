// import 'dart:js';
import 'dart:ui';

import 'package:flutter/material.dart';


Color mainColor = const Color.fromARGB(255, 27, 26, 26);
Color secondaryColor = Color.fromARGB(255, 207, 84, 84);
Color tertiaryColor = Color.fromARGB(255, 255, 255, 255);

double smallTextModifier = 0.025;
double mediumTextModifier = 0.05;
double largeTextModifier = 0.07;

double textAdaptModifier = 0.0009;

// =========================================================================================================================================

// this is to calibrate the counter of collecting delay for getting of coordinates
int collectingCtrDelay = 0;
double correctThreshold = 0.75;
int currentDuration = 3;
final int _duration = 10;
