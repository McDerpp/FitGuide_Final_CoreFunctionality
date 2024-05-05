import 'dart:convert';
import 'package:frontend/services/globalVariables.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'provider_collection.dart';
import 'package:path/path.dart' as path;

String csrfToken = '';
String ipAddress = "192.168.1.26:8000";

Future<String> getCSRFToken() async {
  final url = Uri.parse('http://${ipAddress}/getToken/');
  final response = await http.get(url);
  String convertedData = '';
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    String convertedData = data["csrf_token"];
    print("data ---> $data");
    print("getting token ---> $convertedData");
    return convertedData;
  } else {
    throw Exception('Failed to load data');
  }
}

Future<dynamic> getRetrainInfo() async {
  var url = Uri.parse('http://${ipAddress}/modelTraining/get_retrain_info/');
  try {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var responseData = response.body;
      print("responseData---> $responseData");

      dynamic responseJson = json.decode(responseData);

      return responseJson;
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (error) {
    print('Error: $error');
  }
}

// Future<String> getModel(int exercisePK) async {
//   var url = Uri.parse('http://${ipAddress}/modelTraining/get_model/$exercisePK/');

//   try {
//     var response = await http.get(url);
//     if (response.statusCode == 200) {
//     final documentsDirectory = await getApplicationDocumentsDirectory();
//     print("documentsDirectory -- > $documentsDirectory");

//     const filePath = 'assets/models/wholeModel';
//     print("filePath -- > $filePath");

//     final file = File(filePath);
//     await file.writeAsBytes(response.bodyBytes);

//       // var responseData = response.body;
//       // print("responseData---> $responseData");

//       // dynamic responseJson = json.decode(responseData);

//       // return filePath;
//     } else {
//       print('Request failed with status: ${response.statusCode}');
//     }
//   } catch (error) {
//     print('Error at get model: $error');
//   }

//   return "filePath";

// }

Future<String?> getModel(int exercisePK) async {
  var url =
      Uri.parse('http://${ipAddress}/modelTraining/get_model/$exercisePK/');

  try {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final documentsDirectory = await getTemporaryDirectory();
      final filePath = path.join(documentsDirectory.path, 'model.tflite');

      // Create the necessary directories
      await Directory(path.dirname(filePath)).create(recursive: true);

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return filePath;
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (error) {
    print('Error: $error');
  }

  return null; // Return null in case of error or non-200 response
}

Future<File?> getVideo(int exercisePK) async {
  var url =
      Uri.parse('http://${ipAddress}/modelTraining/get_demo/$exercisePK/');

  try {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      print("demo response received ---> ${response}");
      final documentsDirectory = await getTemporaryDirectory();
      final filePath = path.join(documentsDirectory.path, 'videoDemo.mp4');

      final file = File(filePath);
      print("video demo---> ${file}");
      await file.writeAsBytes(response.bodyBytes);

      return file;
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (error) {
    print('Error: $error');
  }

  return null; // Return null in case of error or non-200 response
}

Future<void> collectDatasetInfo(WidgetRef ref) async {
  var uri = Uri.parse('http://${ipAddress}/modelTraining/datasetSubmit/');

  String sessionKey = ref.watch(sessionKeyProvider);
  String positiveData = ref.watch(correctDataSetPath);
  String negativeData = ref.watch(incorrectDataSetPath);
  String videoDemo = ref.watch(vidPath);

  final headers = {
    'Authorization': sessionKey,
  };
  var request = http.MultipartRequest('POST', uri);

  request.headers.addAll(headers);

  request.files
      .add(await http.MultipartFile.fromPath('positiveDataset', positiveData));
  request.files
      .add(await http.MultipartFile.fromPath('negativeDataset', negativeData));
  request.files.add(await http.MultipartFile.fromPath('videoDemo', videoDemo));

// DatasetInfo==============================================================
  int numExecutionValuePositive =
      ref.watch(coordinatesDataProvider).state.length;
  double avgSequenceValuePositive = ref.watch(averageFrameState);
  int minSequenceValuePositive = ref.watch(minFrameState);
  int maxSequenceValuePositive = ref.watch(maxFrameState);

  int numExecutionValueNegative =
      ref.watch(incorrectCoordinatesDataProvider).state.length;
  double avgSequenceValueNegative = ref.watch(averageFrameNegativeState);
  int minSequenceValueNegative = ref.watch(minFrameNegativeState);
  int maxSequenceValueNegative = ref.watch(maxFrameNegativeState);

  // request.fields['avgLuminance'] = avgLuminanceValue.toString();
  request.fields['numExecutionPositive'] = numExecutionValuePositive.toString();
  request.fields['avgSequencePositive'] = avgSequenceValuePositive.toString();
  request.fields['minSequencePositive'] = minSequenceValuePositive.toString();
  request.fields['maxSequencePositive'] = maxSequenceValuePositive.toString();

  request.fields['numExecutionNegative'] = numExecutionValueNegative.toString();
  request.fields['avgSequenceNegative'] = avgSequenceValueNegative.toString();
  request.fields['minSequenceNegative'] = minSequenceValueNegative.toString();
  request.fields['maxSequenceNegative'] = maxSequenceValueNegative.toString();
// DatasetInfo==============================================================

// ExerciseInfo==============================================================
  String exerciseNameVale = ref.watch(exerciseNameProvider);
  int exerciseNumSetValue = ref.watch(exerciseNumSetProvider);
  int exerciseNumExecutionValue = ref.watch(exerciseNumExecutionProvider);

  request.fields['exerciseName'] = exerciseNameVale;
  request.fields['ingoreCoordinates'] =
      ref.watch(ignoreCoordinatesProvider).toString();
  request.fields['exerciseNumSet'] = exerciseNumSetValue.toString();
  request.fields['exerciseNumExecution'] = exerciseNumExecutionValue.toString();
// ExerciseInfo==============================================================

  // Send the request
  var response = await http.Client().send(request);

  // Check the response status code
  if (response.statusCode == 200) {
    print('Dataset info collected successfully');
  } else {
    print('Failed to collect dataset info: ${response.statusCode}');
  }
}

void setSessionVariable(String sessionKey) async {
  var url =
      Uri.parse('http://${ipAddress}/modelTraining/set_session_variable/');

  final headers = {
    'Authorization': sessionKey,
  };

  var response = await http.post(url, headers: headers);

  if (response.statusCode == 200) {
    print('Session variable set successfully');
  } else {
    print('Failed to set session variable: ${response.reasonPhrase}');
  }
}

void getSessionVariable(String sessionKey) async {
  var url = Uri.parse('http:/${ipAddress}/modelTraining/get_session_variable/');

  final headers = {
    'Authorization': sessionKey,
  };

  var response = await http.post(url, headers: headers);

  if (response.statusCode == 200) {
    print('Session variable GET successfully');
  } else {
    print('Failed to GET session variable: ${response.reasonPhrase}');
  }
}

Future<String> getSessionKey() async {
  // final response = await http.get(Uri.parse(
  //     'http://${ipAddress}/modelTraining/generate_session_key/'));

  // if (response.statusCode == 200) {
  //   final sessionKey = response.body;

  //   return sessionKey;
  // } else {
  //   throw Exception('Failed to retrieve session key');
  // }
  return "0";
}

void fetchSessionKey() async {
  try {
    final sessionKey = await getSessionKey();
    print('Session Key: $sessionKey');

    // Use the session key as needed
    // ...
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> retrainModel(WidgetRef ref, String exerciseId) async {
  var url = Uri.parse('http://${ipAddress}/modelTraining/retrain_model/');

  var request = http.MultipartRequest('POST', url);
  print("ref.watch(correctDataSetPath) ---> ${ref.watch(correctDataSetPath)}");
  print(
      "ref.watch(incorrectDataSetPath) ---> ${ref.watch(incorrectDataSetPath)}");

  String positiveData = ref.watch(correctDataSetPath);
  String negativeData = ref.watch(incorrectDataSetPath);
  print("exercise ID in API ----> $exerciseId");
  request.files
      .add(await http.MultipartFile.fromPath('positiveDataset', positiveData));
  request.files
      .add(await http.MultipartFile.fromPath('negativeDataset', negativeData));

  request.fields['exerciseId'] = exerciseId.toString();

  var response = await http.Client().send(request);
}
