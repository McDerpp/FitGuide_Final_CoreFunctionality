import 'package:dashboard/coordinatesData.dart';
import 'package:dashboard/globalVariable.dart';
import 'package:dashboard/modelTrained.dart';
import 'package:dashboard/navBar.dart';
import 'package:dashboard/trainingProgress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitGuide',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: home(),
    );
  }
}

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() {
//     // TODO: implement createState
//     throw UnimplementedError();
//   }
// }

class home extends ConsumerStatefulWidget {
  const home({super.key});

  @override
  ConsumerState<home> createState() => _homeState();
}

int currentContent = 0;
// trainingProgress - 0
// modelsTrained - 1
// coordinatesData - 1

class _homeState extends ConsumerState<home> {
  @override
  Widget build(BuildContext context) {
    // int currentContent = ref.watch(currentContentProvider);
    int currentContent = ref.watch(currentContentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('FitGuide'),
      ),
      body: Center(
        child: currentContent == 0
            ? trainingProgress()
            : currentContent == 1
                ? modelTrained()
                : currentContent == 2
                    ? coordinatesData()
                    : Text("NULL"),
      ),
      drawer: navBar(),
    );
  }
}
