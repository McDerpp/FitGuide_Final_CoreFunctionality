import 'package:flutter/material.dart';

import '../mainUISettings.dart';

Widget titleDescription({
  required BuildContext context,
  required String title,
  required String description,
  int titleFontSize = 21,
  int descriptionFontSize = 19,
}) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  double textSizeModif = (screenHeight + screenWidth) * textAdaptModifier;
  return Row(
    children: [
      SizedBox(height: screenHeight * 0.08),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize * textSizeModif,
              fontWeight: FontWeight.w400,
              color: secondaryColor,
            ),
          ),
          Text(
            "$description",
            style: TextStyle(
              fontSize: descriptionFontSize * textSizeModif,
              fontWeight: FontWeight.w300,
              color: tertiaryColor,
            ),
          ),
        ],
      ),
    ],
  );
}
