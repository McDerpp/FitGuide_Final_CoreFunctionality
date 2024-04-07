import 'dart:core';
import 'dart:math';

List<double> paddingList = [];

void paddingInitialize() {
  for (int i = 0; i < 66; i++) {
    paddingList.add(0);
  }
}

List<List<double>> padding(List<List<double>> input, int requiredLength) {
  List<List<double>> result =
      List.from(input); // Create a copy of the input list
  List<double> paddingList =
      List.filled(66, 0); // Initialize paddingList with zeros

  while (result.length > requiredLength) {
    int maxRange = result.length;
    int randomNumber = Random().nextInt(maxRange);
    result.removeAt(randomNumber);
  }

  while (result.length < requiredLength) {
    result.add(
        List.from(paddingList)); // Create a new instance of the padding list
  }

  print("result of padding is --> ${result.length}");
  return result;
}