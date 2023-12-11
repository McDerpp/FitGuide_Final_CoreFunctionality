import 'package:flutter/material.dart';

import '../mainUISettings.dart';

class collectedResults extends StatefulWidget {
  const collectedResults({super.key});

  @override
  State<collectedResults> createState() => _collectedResultsState();
}

class _collectedResultsState extends State<collectedResults> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textSizeModif = (screenHeight + screenWidth) * textAdaptModifier;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: mainColor,
            width: screenWidth,
            height: screenHeight,
          )
        ],
      ),
    );
  }
}
