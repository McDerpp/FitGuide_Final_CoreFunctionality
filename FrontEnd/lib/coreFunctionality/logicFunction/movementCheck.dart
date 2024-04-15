import 'dart:core';

bool checkMovement(Map<String, dynamic> input) {
  var prevCoordinates = input['prevCoordinates'];
  var currentCoordinates = input['currentCoordinates'];
  var token = input['token'];

  bool noMovement = false;
  double changeRange = 0.045;
  int noMovementCtr = 0;

  for (int ctr = 0; ctr < prevCoordinates.length; ctr++) {
    if (prevCoordinates.elementAt(ctr) - changeRange <=
            currentCoordinates.elementAt(ctr) &&
        prevCoordinates.elementAt(ctr) + changeRange >=
            currentCoordinates.elementAt(ctr)) {
      noMovementCtr++;
    } else {
      return false;
    }
  }

  if (noMovementCtr >= 65) {
    return true;
  } else {
    return false;
  }
}
