import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/coreFunctionality/misc/painters/pose_painter.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

// class reviewDataset extends StatelessWidget {
//   final List<Pose> coordinatesData;
//   final Size size;
//   final InputImageRotation rotation;
//   final CameraLensDirection cameraLensDirection;

//   const reviewDataset({
//     Key? key, // Key parameter added here
//     required this.coordinatesData,
//     required this.size,
//     required this.rotation,
//     required this.cameraLensDirection,
//   }) : super(key: key); // Superclass constructor call corrected here

//   @override
//   Widget build(BuildContext context) {
//     print("coordinatesData ---> ${coordinatesData}");
//     print("size ---> $size");
//     print("rotation ---> $rotation");
//     print("cameraLensDirection ---> $cameraLensDirection");

//     return Stack(
//       children: [
//         CustomPaint(
//           painter: PosePainter(
//             coordinatesData,
//             size,
//             rotation,
//             cameraLensDirection,
//             0,
//           ),
//         ),
//       ],
//     );
//   }
// }

class reviewDataSet extends StatefulWidget {
  final List<List<Pose>> coordinatesData;
  final Size size;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  const reviewDataSet(
      {super.key,
      required this.coordinatesData,
      required this.size,
      required this.rotation,
      required this.cameraLensDirection});

  @override
  State<reviewDataSet> createState() => _reviewDataSetState();
}

class _reviewDataSetState extends State<reviewDataSet> {
  int ctr = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.amber),
        CustomPaint(
          painter: PosePainter(
            widget.coordinatesData.elementAt(ctr),
            widget.size,
            widget.rotation,
            widget.cameraLensDirection,
            0,
          ),
        ),
        Text("fsadfbasdfbasdf-----> ${ctr}"),
        ElevatedButton(
            onPressed: () {
              setState(() {
                ctr++;
              });
            },
            child: Text("add")),
      ],
    );
  }
}
