import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

import '../modes/dataCollection/screens/collectionData.dart';
import '../pose_detector_view.dart';
import 'package:frontend/coreFunctionality/extraWidgets/customWidgetPDV.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mainUISettings.dart';

// 'assets/models/wholeModel/otestingtesting(loss_0.063)(acc_0.982).tflite'

class instructionPage extends StatefulWidget {
  final bool isInferencing;
  final String inferencingModelPath;
  const instructionPage(
      {super.key, required this.isInferencing, this.inferencingModelPath = ''});

  @override
  State<instructionPage> createState() => _instructionPageState();
}

class _instructionPageState extends State<instructionPage> {
  final List<Widget> _pages = [];
  final _pageViewController = PageController();

  List<Map<String, dynamic>> collectionInstruction = [
    {
      'title': "Step 1 (Be in the screen) :",
      'instruction':
          "collecting of data is done by getting coordinates of the placements of certain parts of the body on the screen. Sets of these recorded coordinates are considered sequences and the use can think of it as like a frame by frame representation of your movements. All of these will be used in training the AI model for the exercise that the user is doing. ",
    },
    {
      'title': "Step 2 (Perform, do the exercise) :",
      'instruction':
          "The whole body must be present in the screen in order to start getting and produce a good data, otherwise it wont record anything. The user will know when the body is detected by seeing overlay of a skeleton.",
    },
    {
      'title': "Step 3 (Stop briefly, about less than a sec) :",
      'instruction':
          "After step 1, the user can now proceed with doing the exercise. However, there are things that the user should take into consideration. A good and consistent pacing is required when executing the exercise, fast and inconsistent execution can create problems along the line. Number of executions is another thing, being able to perform more exercise can be beneficial.",
    },
    {
      'title': "Step 4 (Repeat step 3 and 4) :",
      'instruction':
          "Repeat the process until you have sufficient execution performed. Recommended number of execution is atleast 50 to be able to produce a decent model. More than 100 number of execution would yield a good model.",
    },
    {
      'title': "Step 5 (Submit!) :",
      'instruction':
          "The user is now done with collecting data, now the user will have to fill in some data about the exercise recently performed. After everything, you can finally submit it and train it. Now, what's left to do is to wait for it, some time might be needed to train it, the user will get a notification as soon as the training is done.",
    },
  ];

  int _currentPage = 0;

  void nextPageFunc(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => collectionData(),
      ),
    );
  }

  void backPageFunc(BuildContext context) {
    Navigator.pop(context);
  }

  Widget individualPage() {
    return Container(
      child: Stack(
        children: [],
      ),
    );
  }

  Widget dataCollectingInstruction(
      Map<dynamic, dynamic> data, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: screenWidth * 0.5,
            height: screenWidth * 0.5,
            color: const Color.fromARGB(255, 255, 134, 68),
          ),
          SizedBox(
            height: screenHeight * .02,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Text(
                  "  ${data['title']}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize:
                        ((screenHeight + screenWidth) * textAdaptModifier) *
                            14.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(
                  height: screenHeight * .02,
                ),
                Text(
                  "  ${data['instruction']}",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize:
                        ((screenHeight + screenWidth) * textAdaptModifier) *
                            11.0,
                    fontWeight: FontWeight.w300,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return IconButton(
      icon: Icon(
        Icons.question_mark_sharp,
        color: tertiaryColor,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  backgroundColor: tertiaryColor.withOpacity(0.85),
                  content: Container(
                    color: Colors.transparent,
                    width: double.maxFinite,
                    height: screenHeight * .5,
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      body: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: PageView(
                                  controller: _pageViewController,
                                  onPageChanged: (int page) {
                                    setState(() {
                                      _currentPage = page;
                                    });
                                  },
                                  children: [
                                    dataCollectingInstruction(
                                        collectionInstruction[0], context),
                                    dataCollectingInstruction(
                                        collectionInstruction[1], context),
                                    dataCollectingInstruction(
                                        collectionInstruction[2], context),
                                    dataCollectingInstruction(
                                        collectionInstruction[3], context),
                                    dataCollectingInstruction(
                                        collectionInstruction[4], context),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment(0.0, 1.15),
                            child: DotsIndicator(
                              dotsCount: 5,
                              position: _currentPage.toDouble(),
                              decorator: DotsDecorator(
                                color: Colors.grey,
                                activeColor: Colors.blue,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
