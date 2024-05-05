import 'dart:core';

bool checkMovement(Map<String, dynamic> input) {
  var prevCoordinates = input['prevCoordinates'];
  var currentCoordinates = input['currentCoordinates'];
  
  var token = input['token'];

// Movement allowance to take into account the jittery nature of
// pose estimation on poor lighting.
  // double changeRange = 0.045;
  double changeRange = 0.045;

  int noMovementCtr = 0;

// Looping through coordinates checking for movements.
  for (int ctr = 0; ctr < prevCoordinates.length; ctr++) {
    print(
        "prev -> ${prevCoordinates.elementAt(ctr) - changeRange} <= ${currentCoordinates.elementAt(ctr)} && ${prevCoordinates.elementAt(ctr) - changeRange} >= ${currentCoordinates.elementAt(ctr)} ------[] ");
    if (prevCoordinates.elementAt(ctr) - changeRange <=
            currentCoordinates.elementAt(ctr) &&
        prevCoordinates.elementAt(ctr) + changeRange >=
            currentCoordinates.elementAt(ctr)) {
      // print(
      //     "checking pose ignore noMovement[${ctr}] -> ${prevCoordinates.elementAt(ctr) - changeRange} <= ${currentCoordinates.elementAt(ctr)} && ${prevCoordinates.elementAt(ctr) - changeRange} >= ${currentCoordinates.elementAt(ctr)} ------[true] ");
      noMovementCtr++;
    } else {
      // print(
      //     "checking pose ignore noMovement[${ctr}] -> ${prevCoordinates.elementAt(ctr) - changeRange} <= ${currentCoordinates.elementAt(ctr)} && ${prevCoordinates.elementAt(ctr) - changeRange} >= ${currentCoordinates.elementAt(ctr)} ------[false] ");
      return false;
    }
  }

// There are 66 flattened X and Y coordinates, this is to check
// if all coordinates didnt change beyond the allowance.
  if (noMovementCtr >= 66) {
    return true;
  } else {
    return false;
  }
}
