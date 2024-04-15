import 'dart:convert';
import 'package:frontend/coreFunctionality/modes/globalStuff/provider/globalVariables.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider_collection.dart';

String csrfToken = '';

Future<String> getCSRFToken() async {
  final url = Uri.parse('http://192.168.1.18:8000/getToken/');
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

Future<void> collectDatasetInfo(WidgetRef ref) async {
  var uri = Uri.parse('http://192.168.1.18:8000/modelTraining/datasetSubmit/');

  String sessionKey = ref.watch(sessionKeyProvider);
  String filePath = ref.watch(correctDataSetPath);
  String filePath2 = ref.watch(incorrectDataSetPath);

  print("FILE PATH 30423423 -> $filePath");
  final headers = {
    'Authorization': sessionKey,
  };
  var request = http.MultipartRequest('POST', uri);

  request.headers.addAll(headers);

  request.files.add(await http.MultipartFile.fromPath('positiveDataset', filePath));
  request.files.add(await http.MultipartFile.fromPath('negativeDataset', filePath2));

// DatasetInfo==============================================================
  double avgLuminanceValue = ref.watch(luminanceProvider);
  int numExecutionValue = ref.watch(numExec);
  double avgSequenceValue = ref.watch(averageFrameState);
  int minSequenceValue = ref.watch(minFrameState);
  int maxSequenceValue = ref.watch(maxFrameState);

  // request.fields['avgLuminance'] = avgLuminanceValue.toString();
  request.fields['numExecution'] = numExecutionValue.toString();
  request.fields['avgSequence'] = avgSequenceValue.toString();
  request.fields['minSequence'] = minSequenceValue.toString();
  request.fields['maxSequence'] = maxSequenceValue.toString();
// DatasetInfo==============================================================

// ExerciseInfo==============================================================
  String exerciseNameVale = ref.watch(exerciseNameProvider);
  String descriptionValue = ref.watch(descriptionProvider);
  // String additionalNotesValue = ref.watch(additionalNotesProvider);
  // String partsAffectedValue = ref.watch(partsAffectedProvider);
  int exerciseNumSetValue = ref.watch(exerciseNumSetProvider);
  int exerciseNumExecutionValue = ref.watch(exerciseNumExecutionProvider);

  request.fields['exerciseName'] = exerciseNameVale;
  request.fields['description'] = descriptionValue;
  // request.fields['additionalNotes'] = additionalNotesValue;
  // request.fields['partsAffected'] = partsAffectedValue;
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
      Uri.parse('http://192.168.1.18:8000/modelTraining/set_session_variable/');

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
  var url =
      Uri.parse('http://192.168.1.18:8000/modelTraining/get_session_variable/');

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
  //     'http://192.168.1.18:8000/modelTraining/generate_session_key/'));

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
