import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../instructionPage/instructionPage.dart';
import '../logicFunction/isolateProcessPDV.dart';
import '../mainUISettings.dart';

void showCustomDialog(
  BuildContext context,
  Widget content, {
  double widthMultiplier = 0.7,
  double heightMultiplier = 0.25,
}) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  void cancelfunc() {
    Navigator.pop(context);
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Container(
          width: screenWidth * widthMultiplier,
          height: screenHeight * heightMultiplier,
          child: content,
        ),
      );
    },
  );
}

Widget textInfoCtr(
    String label, double? counted, double fontsize, Color color) {
  return Padding(
    padding: const EdgeInsets.only(
      left: 5.0,
      top: 5.0,
    ),
    child: Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontsize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (counted != null)
          Text(
            counted.toString(),
            style: TextStyle(
              fontSize: fontsize,
              fontWeight: FontWeight.bold,
              // color: Color.fromARGB(255, 0, 0, 0),

              color: color,
              decoration: TextDecoration.none,
            ),
          ),
      ],
    ),
  );
}

Widget instructionText(FontWeight fontw, double fontsize, double leftN,
    double topN, Color color, String text) {
  return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(left: leftN, top: topN, right: 20),
        child: RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            text: text,
            style: GoogleFonts.lato(
              fontSize: fontsize,
              color: color,
              fontWeight: fontw,
            ),
          ),
        ),
      ));
}

Widget buildElevatedButton(String label, Color color, Function func) {
  return Padding(
    padding: EdgeInsets.only(left: 5.0, right: 5.0),
    child: Align(
      alignment: Alignment(1.0, 0.8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        onPressed: () {
          func();
        },
        child: Text(label),
      ),
    ),
  );
}

Widget nextPageButton(String label, Color color,
    void Function(BuildContext) onPressed, BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(left: 5.0, right: 5.0),
    child: Align(
      alignment: Alignment(1.0, 0.8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        onPressed: () {
          onPressed(context); // Pass the context if needed
          print('pressing button');
        },
        child: Text(label),
      ),
    ),
  );
}

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

void executionAnalysis(
  BuildContext context,
  int numExec,
  double avgFrames,
  List<dynamic> coordinatesData,
  Function(double) updateProgress,
  double progress,
) {
  return showCustomDialog(
    context,
    Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textInfoCtr("Total executed", numExec.toDouble(), 15, Colors.black),
            textInfoCtr("Total executed", numExec.toDouble(), 15, Colors.black),
            textInfoCtr("Average Frames: ", avgFrames.roundToDouble(), 15,
                Colors.black),
          ],
        ),
        Spacer(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildElevatedButton("Cancel", Colors.red, () {
                Navigator.pop(context);
              }),
              buildElevatedButton(
                "info",
                Colors.red,
                () {
                  translateCollectedDatatoTxt(
                    coordinatesData,
                    updateProgress,
                  );
                },
              ),
              buildElevatedButton("Submit", Colors.red, () {
                loadingBoxTranslating(
                  context,
                  coordinatesData,
                  progress,
                  updateProgress,
                ); // Pass the context to the loadingBox function
              }),
            ],
          ),
        ),
      ],
    ),
  );
}

// void ignoreCoordinatesPopOutBox(
//   BuildContext context,
//   // List<dynamic> coordinatesData,
// ) {
//   double screenWidth = MediaQuery.of(context).size.width;
//   double screenHeight = MediaQuery.of(context).size.height;
//   double textSizeModif = (screenHeight + screenWidth) * textAdaptModifier;
//   return showCustomDialog(
//       context,
//       Stack(
//         children: [
//           IconButton(
//             icon: Icon(
//               Icons.accessibility_sharp,
//               color: secondaryColor,
//               size: screenWidth * .45, //
//             ),
//             onPressed: () {},
//           ),
//           Center(
//             child: ToggleButtons(
//               children: <Widget>[
//                 Icon(Icons.format_bold),
//                 Icon(Icons.format_italic),
//                 Icon(Icons.format_underline),
//               ],
//               onPressed: (int index) {
//                 setState(() {
//                   // Toggle the state of the button at the specified index
//                   isSelected[index] = !isSelected[index];
//                 });
//               },
//               isSelected: isSelected,
//             ),
//           ),
//         ],
//       ));
// }

void loadingBoxTranslating(
  BuildContext context,
  List<dynamic> coordinatesData,
  double progress,
  Function(double) updateProgress,
) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  translateCollectedDatatoTxt(
    coordinatesData,
    updateProgress,
  );

  return showCustomDialog(
    context,
    Container(
      width: 100,
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Please wait...",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
          ),
          SizedBox(
              height:
                  10), // Add some spacing between text and CircularProgressIndicator
          Center(
            child: CircularProgressIndicator(
              value: .5,
              strokeWidth: 8.0,
              color: secondaryColor,
              backgroundColor: mainColor,
              semanticsLabel: 'Loading',
            ),
          ),
          SizedBox(
              height:
                  10), // Add some spacing between CircularProgressIndicator and bottom text
          Text(
            "Processing",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
          ),
        ],
      ),
    ),
  );
}

void sendingToTrain(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  return showCustomDialog(
    context,
    Container(
      width: 100,
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Please wait...",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: CircularProgressIndicator(
              value: progressT / 100,
              strokeWidth: 8.0,
              color: secondaryColor,
              backgroundColor: mainColor,
              semanticsLabel: 'Loading',
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Processing",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
          ),
          Text(
            "Processing",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget description1({
  required DescTitle,
  required String Desc,
  required BuildContext context,
}) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  double textSizeModif = (screenHeight + screenWidth) * textAdaptModifier;
  return Padding(
    padding: EdgeInsets.only(top: 15.0),
    child: Container(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DescTitle,
            style: TextStyle(
              fontSize: 13.0 * textSizeModif,
              fontWeight: FontWeight.w400,
              color: secondaryColor,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
          SizedBox(height: 3.0), // Add some spacing between the texts
          Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Text(
              Desc,
              style: TextStyle(
                fontSize: 18.0 * textSizeModif,
                fontWeight: FontWeight.w500,
                color: tertiaryColor,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget longDescription({
  required BuildContext context,
  required DescTitle,
  required String longDesc,
}) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  double textSizeModif = (screenHeight + screenWidth) * textAdaptModifier;

  return Padding(
    padding: EdgeInsets.only(top: 8.0),
    child: Container(
      width: screenWidth * .9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DescTitle,
            style: TextStyle(
              fontSize: 15.0 * textSizeModif,
              fontWeight: FontWeight.bold,
              color: secondaryColor,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
          const SizedBox(height: 3.0), //
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              longDesc,
              style: TextStyle(
                fontSize: 12.0 * textSizeModif,
                fontWeight: FontWeight.bold,
                color: tertiaryColor,
              ),
              maxLines: 15,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildBackIcon(BuildContext context) {
  return IconButton(
    icon: Icon(
      Icons.arrow_back,
      color: secondaryColor,
      size: 30.0,
    ),
    onPressed: () {},
  );
}

Widget buildHelpIcon(BuildContext context) {
  return IconButton(
    icon: Icon(
      Icons.help,
      color: secondaryColor,
      size: 30.0,
    ),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => instructionPage(
            isInferencing: true,
          ),
        ),
      );
    },
  );
}

// Future popOutDialogUpdating() {
//   return showDialog(
//     context: context,
//     builder: (context) {
//       String contentText = "Content of Dialog";
//       return StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: Text("Title of Dialog"),
//             content: Text(contentText),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text("Cancel"),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: headColor,
//                   fixedSize: Size(
//                     screenHeight * 0.15,
//                     screenHeight * 0.05,
//                   ),
//                 ),
//                 onPressed: () {
//                   print("HEAD PRESSED!");
//                   setState(() {
//                     headColor = Colors.deepOrange;
//                   });
//                 },
//                 child: Text('Head'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     contentText = "Changed Content of Dialog";
//                   });
//                 },
//                 child: Text("Change"),
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }

// Widget settings(BuildContext context) {
//   return IconButton(
//     icon: Icon(
//       Icons.settings,
//       color: secondaryColor,
//       size: 30.0, //
//     ),
//     onPressed: () {
//       showCustomDialog(context, Text('data'));
//        Slider(
//           value: _sliderValue,
//           onChanged: (value) {
//             setState(() {
//               _sliderValue = value;
//             });
//           },
//           min: 0.0,
//           max: 100.0,
//         ),
//     },
//   );
// }




//  await openDialog(
                //   context,
                //   Stack(
                //     children: [
                //       Positioned(
                //         left: (screenWidth * 0.7) * .1,
                //         bottom: (screenHeight * 0.35),
                //         child: IconButton(
                //           icon: Icon(
                //             Icons.accessibility_sharp,
                //             color: secondaryColor,
                //             size: screenWidth * .50, //
                //           ),
                //           onPressed: () {},
                //         ),
                //       ),
                //       // ----------------------HEAD------------------------------
                //       Positioned(
                //         top: screenHeight * 0.5 * 0.02,
                //         right: screenWidth * 0.7 * 0.37,
                //         child: ElevatedButton(
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: headColor,
                //             fixedSize: Size(
                //               screenHeight * 0.15,
                //               screenHeight * 0.05,
                //             ),
                //           ),
                //           onPressed: () {
                //             print("HEAD PRESSED!");
                //             setState(() {
                //               headColor = Colors.deepOrange;
                //             });
                //           },
                //           child: Text('Head'),
                //         ),
                //       ),

                //       // ----------------------BODY------------------------------

                //       Positioned(
                //         top: screenHeight * 0.5 * 0.5,
                //         left: screenWidth * .7 * .08,
                //         child: ElevatedButton(
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: bodyColor,
                //             fixedSize: Size(
                //               screenHeight * 0.15,
                //               screenHeight * 0.05,
                //             ),
                //           ),
                //           onPressed: () {},
                //           child: Text('Body'),
                //         ),
                //       ),
                //       // ----------------------LEFT_ARM------------------------------

                //       Positioned(
                //         top: screenHeight * 0.5 * 0.2,
                //         right: screenWidth * .7 * .025,
                //         child: ElevatedButton(
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: leftArmColor,
                //             fixedSize: Size(
                //               screenHeight * 0.15,
                //               screenHeight * 0.05,
                //             ),
                //           ),
                //           onPressed: () {},
                //           child: Text('Left Arm'),
                //         ),
                //       ),
                //       // ----------------------RIGHT_ARM------------------------------

                //       Positioned(
                //         top: screenHeight * 0.5 * 0.2,
                //         left: screenWidth * .7 * .025,
                //         child: ElevatedButton(
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: rightArmColor,
                //             fixedSize: Size(
                //               screenHeight * 0.15,
                //               screenHeight * 0.05,
                //             ),
                //           ),
                //           onPressed: () {},
                //           child: Text('Right Arm'),
                //         ),
                //       ),
                //       // ----------------------LEFT_LEG------------------------------

                //       Positioned(
                //         bottom: screenHeight * 0.5 * 0.2,
                //         right: screenWidth * .7 * .01,
                //         child: ElevatedButton(
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: leftLegColor,
                //             fixedSize: Size(
                //               screenHeight * 0.15,
                //               screenHeight * 0.05,
                //             ),
                //           ),
                //           onPressed: () {},
                //           child: Text('Left Leg'),
                //         ),
                //       ),
                //       // ----------------------RIGHT_LEG------------------------------

                //       Positioned(
                //         bottom: screenHeight * 0.5 * 0.2,
                //         left: screenWidth * .7 * .01,
                //         child: ElevatedButton(
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: rightLegColor,
                //             fixedSize: Size(
                //               screenHeight * 0.15,
                //               screenHeight * 0.05,
                //             ),
                //           ),
                //           onPressed: () {},
                //           child: Text('Right Leg'),
                //         ),
                //       ),
                //     ],
                //   ),
                // );
                // setState(() {});
                // showCustomDialog(
                //   context,
                //   heightMultiplier: 0.5,
                //   Stack(
                //     children: [
                //       Positioned(
                //         left: (screenWidth * 0.7) * .1,
                //         bottom: (screenHeight * 0.35),
                //         child: IconButton(
                //           icon: Icon(
                //             Icons.accessibility_sharp,
                //             color: secondaryColor,
                //             size: screenWidth * .50, //
                //           ),
                //           onPressed: () {},
                //         ),
                //       ),
                //       // ----------------------HEAD------------------------------
                //       Positioned(
                //         top: screenHeight * 0.5 * 0.02,
                //         right: screenWidth * 0.7 * 0.37,
                //         child: ElevatedButton(
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: headColor,
                //             fixedSize: Size(
                //               screenHeight * 0.15,
                //               screenHeight * 0.05,
                //             ),
                //           ),
                //           onPressed: () {
                //             print("HEAD PRESSED!");
                //             setState(() {
                //               headColor = Colors.deepOrange;
                //             });
                //           },
                //           child: Text('Head'),
                //         ),
                //       ),
                //       // ----------------------BODY------------------------------

                //       Positioned(
                //         top: screenHeight * 0.5 * 0.5,
                //         left: screenWidth * .7 * .08,
                //         child: ElevatedButton(
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: bodyColor,
                //             fixedSize: Size(
                //               screenHeight * 0.15,
                //               screenHeight * 0.05,
                //             ),
                //           ),
                //           onPressed: () {},
                //           child: Text('Body'),
                //         ),
                //       ),
                //       // ----------------------LEFT_ARM------------------------------

                //       Positioned(
                //         top: screenHeight * 0.5 * 0.2,
                //         right: screenWidth * .7 * .025,
                //         child: ElevatedButton(
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: leftArmColor,
                //             fixedSize: Size(
                //               screenHeight * 0.15,
                //               screenHeight * 0.05,
                //             ),
                //           ),
                //           onPressed: () {},
                //           child: Text('Left Arm'),
                //         ),
                //       ),
                //       // ----------------------RIGHT_ARM------------------------------

                //       Positioned(
                //         top: screenHeight * 0.5 * 0.2,
                //         left: screenWidth * .7 * .025,
                //         child: ElevatedButton(
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: rightArmColor,
                //             fixedSize: Size(
                //               screenHeight * 0.15,
                //               screenHeight * 0.05,
                //             ),
                //           ),
                //           onPressed: () {},
                //           child: Text('Right Arm'),
                //         ),
                //       ),
                //       // ----------------------LEFT_LEG------------------------------

                //       Positioned(
                //         bottom: screenHeight * 0.5 * 0.2,
                //         right: screenWidth * .7 * .01,
                //         child: ElevatedButton(
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: leftLegColor,
                //             fixedSize: Size(
                //               screenHeight * 0.15,
                //               screenHeight * 0.05,
                //             ),
                //           ),
                //           onPressed: () {},
                //           child: Text('Left Leg'),
                //         ),
                //       ),
                //       // ----------------------RIGHT_LEG------------------------------

                //       Positioned(
                //         bottom: screenHeight * 0.5 * 0.2,
                //         left: screenWidth * .7 * .01,
                //         child: ElevatedButton(
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: rightLegColor,
                //             fixedSize: Size(
                //               screenHeight * 0.15,
                //               screenHeight * 0.05,
                //             ),
                //           ),
                //           onPressed: () {},
                //           child: Text('Right Leg'),
                //         ),
                //       ),
                //     ],
                //   ),
                // );


                