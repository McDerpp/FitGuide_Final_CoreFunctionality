// import 'package:flutter/material.dart';
// import 'package:frontend/coreFunctionality/custom_widgets/customButton.dart';
// import 'package:frontend/coreFunctionality/custom_widgets/customWidgetPDV.dart';
// import 'package:frontend/coreFunctionality/custom_widgets/custom_dialogbox.dart';

// import '../logicFunction/isolateProcessPDV.dart';
// import 'loading_box.dart';

// Widget textInfoCtr(
//     String label, double? counted, double fontsize, Color color) {
//   return Padding(
//     padding: const EdgeInsets.only(
//       left: 5.0,
//       top: 5.0,
//     ),
//     child: Row(
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: fontsize,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         if (counted != null)
//           Text(
//             counted.toString(),
//             style: TextStyle(
//               fontSize: fontsize,
//               fontWeight: FontWeight.bold,
//               // color: Color.fromARGB(255, 0, 0, 0),

//               color: color,
//               decoration: TextDecoration.none,
//             ),
//           ),
//       ],
//     ),
//   );
// }



// void executionAnalysis({
//   required Map<String, double> textSizeModifier,
//   required Map<String, Color> colorSet,
//   required BuildContext context,
//   required int numExec,
//   required double avgFrames,
//   required List<dynamic> coordinatesData,
//   required Function(double) updateProgress,
//   required double progress,
// }) {
//   double screenWidth = MediaQuery.of(context).size.width;
//   double screenHeight = MediaQuery.of(context).size.height;

//   return showCustomDialog(
//     context,
//     Column(
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             textInfoCtr("Total executedssssssssss", numExec.toDouble(),
//                 textSizeModifier['smallText2']! * screenWidth, Colors.white),
//             textInfoCtr("Total executed", numExec.toDouble(),
//                 textSizeModifier['mediumText']! * screenWidth, Colors.white),
//           ],
//         ),
//         // Spacer(),
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               // buildElevatedButton(
//               //   context: context,
//               //   label: "Cancel",
//               //   color: Colors.red,
//               //   textSizeModifierIndividual: textSizeModifier,
//               //   func: () {
//               //     Navigator.pop(context);
//               //   },
//               // ),
//               buildElevatedButton(
//                 context: context,
//                 label: "info",
//                 colorSet: colorSet,
//                 textSizeModifierIndividual: textSizeModifier['smallText2']!,
//                 func: () {
//                   translateCollectedDatatoTxt(
//                     coordinatesData,
//                     updateProgress,
//                   );
//                 },
//               ),
//               buildElevatedButton(
//                 context: context,
//                 label: "Submit",
//                 colorSet: colorSet,
//                 textSizeModifierIndividual: textSizeModifier['smallText2']!,
//                 func: () {
//                   loadingBoxTranslating(
//                     context,
//                     coordinatesData,
//                     progress,
//                     updateProgress,
//                   ); // Pass the context to the loadingBox function
//                 },
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
