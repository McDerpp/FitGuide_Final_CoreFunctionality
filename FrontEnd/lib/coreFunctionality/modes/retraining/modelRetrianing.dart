import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/coreFunctionality/custom_widgets/dialogVideoPreview.dart';
// import 'package:frontend/coreFunctionality/custom_widgets/videoPreview.dart';
import 'package:frontend/coreFunctionality/modes/dataCollection/screens/base_datasetCollection.dart';
// import 'package:frontend/coreFunctionality/modes/dataCollection/screens/p1_datsetCollection.dart';
// import 'package:frontend/coreFunctionality/modes/dataCollection/testWidget.dart';
import 'package:frontend/coreFunctionality/modes/inferencing/inferencing(seamless).dart';
import 'package:frontend/services/api.dart';
import 'package:frontend/services/globalVariables.dart';
import 'package:frontend/services/provider_collection.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:path_provider/path_provider.dart';

class modelRetraining extends ConsumerStatefulWidget {
  const modelRetraining({super.key});

  @override
  ConsumerState<modelRetraining> createState() => _modelRetrainingState();
}

class _modelRetrainingState extends ConsumerState<modelRetraining> {
  Map<String, double> textSizeModifierSet = {};
  double textSizeModifierSetMedium = 1;
  double textSizeModifierSetlarge = 1;

  List<List<dynamic>> dataLoadSet = [
    [
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    ]
  ];
  List dataLoad = [];

  Future<void> apiCall() async {
    getRetrainInfo().then((response) async {
      // DefaultCacheManager cacheManager = DefaultCacheManager();

      dataLoadSet = [];

      if (response != null) {
        for (var item in response) {
          print("getting data 23423423");
          dataLoad.add(item["exercise_id"]);
          dataLoad.add(item["exercise_name"]);
          dataLoad.add(item["exercise_demo"]);
          dataLoad.add(item["ignore_coordinates"]);
          dataLoad.add(item["dataset_info"][0]['num_execution_dataset']);
          dataLoad.add(item["dataset_info"][1]['num_execution_dataset']);
          dataLoad.add(item["model_accuracy"]);

          print("item[model_accuracy]--->,${item["model_accuracy"]}");

          print("datasetURL---->${item["dataset_info"][1]['dataset_url']}");

          // await cacheManager
          //     .downloadFile(item["dataset_info"][1]['dataset_url']);
          // FileInfo? model = await cacheManager
          //     .getFileFromCache(item["dataset_info"][1]['dataset_url']);
          // print("filepath for dataset ---> ${model?.file.path}");

          dataLoadSet.add(dataLoad);

          dataLoad = [];
        }
        setState(() {});
      } else {
        print("Response is null");
      }
      print("dataLoadSet---> ${dataLoadSet[0][6]}");
    }).catchError((error) {
      print("Error: $error");
    });
  }

  Future<void> fetchData() async {
    await apiCall();
    setState(() {});
  }

  Widget CustomTileList(BuildContext context, int index) {
    double screenWidth = MediaQuery.of(context).size.width;

    return ListTile(
      title: Container(
        height: screenWidth * 0.17,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dataLoadSet[index][1].toString(),
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.w600,
                color: ref.read(secondaryColorState),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              "#${dataLoadSet[index][0].toString()}",
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w400,
                color: Colors.black26,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
      subtitle: valuePair(
        "poop",
        [
          dataLoadSet[index][4],
          dataLoadSet[index][5],
          dataLoadSet[index][6].toStringAsFixed(3),
          dataLoadSet[index][4]
        ],
        context,
      ),
      isThreeLine: true,
      trailing: Column(
        children: [
          customButton(context, "Retrain", () {
            ref.watch(exerciseID.notifier).state =
                dataLoadSet[index][0].toString();
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const collectionData(
                        isRetraining: true,
                      )),
            );
          }),
          customButton(context, "Preview", () async {
            await getVideo(dataLoadSet[index][0]).then((value) {
              showDialog(
                context: context,
                builder: (context) => dialogVideoPreview(
                  videoPath: value!,
                  isInferencingPreview: false,
                ),
              );
            });

            print("PREVIEW!");
          }),
          customButton(context, "Test", () async {
            await getModel(dataLoadSet[index][0]).then((value) {
              Map<String, dynamic> exerciseInfo1 = {
                'nameOfExercise': "Jumping Jacks",
                'restDuration': 15,
                'setsNeeded': 2,
                'numberOfExecution': 2,
                'modelPath': value.toString(),
                'videoPath': 'assets/videos/jumpNjacksVid.mp4',
                'ignoredCoordinates': ["left_arm", "left_leg"],
                'inputNum': 5,
              };

              List<Map<String, dynamic>> exerciseProgram1 = [];

              exerciseProgram1.add(exerciseInfo1);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => inferencingSeamless(
                    exerciseList: exerciseProgram1,
                  ),
                ),
              );
              print("TESTING! $value");
            });
          }),
        ],
      ),
    );
  }

  Widget customButton(BuildContext context, String label, Function func) {
    double screenWidth = MediaQuery.of(context).size.width;
    textSizeModifierSet = ref.watch(textSizeModifier);
    textSizeModifierSetMedium = textSizeModifierSet["mediumText"]!;

    return ElevatedButton(
      onPressed: () {
        func();
      },
      style: ElevatedButton.styleFrom(
        fixedSize: Size(
          screenWidth * 0.25, // Adjust the width as needed
          screenWidth * 0.07,
        ), // Adjust the width and height as needed
        padding:
            EdgeInsets.all(screenWidth * 0.01), // Apply padding to all sides
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: textSizeModifierSet["smallText"]! *
                screenWidth), // Adjust the font size as needed
      ),
    );
  }

  Widget valuePair(String title, List<dynamic> value, BuildContext context) {
    List<dynamic> content = [
      "Positive Reps : ",
      "Negative Reps : ",
      "Accuracy : ",
      "Loss : ",
    ];
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(
          content.length,
          (index) => Column(
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Text(
                        content[index],
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: screenWidth * 0.02,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value[index].toString(),
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: screenWidth * 0.005,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Map<String, double> textSize = ref.watch(textSizeModifier);
    return Scaffold(
      body: Container(
        color: ref.watch(mainColorState),
        child: Stack(
          children: [
            ListView.builder(
              itemCount: dataLoadSet.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: screenWidth * 0.02),
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.47,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: ref.watch(tertiaryColorState),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: CustomTileList(context, index),
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
