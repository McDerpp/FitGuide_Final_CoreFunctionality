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

class CountdownTimer extends StatefulWidget {
  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _seconds;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _seconds = 10; // Set the initial duration in seconds
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: CountdownPainter(_seconds),
              ),
            ),
            Text(
              '$_seconds',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_seconds == 0) {
          timer.cancel();
        } else {
          setState(() {
            _seconds--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class CountdownPainter extends CustomPainter {
  final int seconds;

  CountdownPainter(this.seconds);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke;

    double radius = size.width / 2;
    Offset center = Offset(radius, radius);

    canvas.drawCircle(center, radius, paint);

    double sweepAngle = 2 * pi * (seconds / 60);
    double startAngle = -pi / 2; // Start the countdown from the top

    paint.color = Colors.red;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        -sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

Widget countdownTimer(
  BuildContext context,
  String dynamicCountDownText,
  Color dynamicCountdownColor,
  CountDownController _controller,
) {
  final CountDownController _controller = CountDownController();
  // int currentDuration = 3;
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  double textSizeModif = (screenHeight + screenWidth) * textAdaptModifier;

  return (CircularCountDownTimer(
    duration: currentDuration,
    initialDuration: 0,
    controller: _controller,
    // width: MediaQuery.of(context).size.width / 2,
    // height: MediaQuery.of(context).size.height / 2,
    width: MediaQuery.of(context).size.width / 4,
    height: MediaQuery.of(context).size.height / 4,
    ringColor: Colors.white!,
    ringGradient: null,
    fillColor: Colors.red,
    fillGradient: null,
    backgroundColor: dynamicCountdownColor,
    backgroundGradient: null,
    strokeWidth: 20.0,
    strokeCap: StrokeCap.round,
    textStyle: TextStyle(
      fontSize: 20.0 * textSizeModif,
      color: Colors.white,
      fontWeight: FontWeight.w400,
    ),
    textFormat: CountdownTextFormat.S,
    isReverse: false,
    isReverseAnimation: false,
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
      if (duration.inSeconds == 0) {
        return dynamicCountDownText;
      } else {
        return Function.apply(defaultFormatterFunction, [duration]);
      }
    },
  ));
}
