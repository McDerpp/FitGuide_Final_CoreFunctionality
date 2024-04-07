
void calculateVarianceIsolate(
    int numFrameGroup, List<List<List<double>>> coordinatesData) {
  if (coordinatesData.length % numFrameGroup == 0) {
    double variance = 0;
    List<int> sequenceLen = [];
    List<int> sequenceTally = [];
    List<List<List<double>>> individualCoorManager = [];

    for (List<List<double>> sequenceData in coordinatesData) {
      if (sequenceLen.contains(sequenceData.length) == false) {
        sequenceLen.add(sequenceData.length);
        individualCoorManager.add(sequenceData);
        sequenceTally.add(1);
      } else {
        int tempIndex = sequenceLen.indexOf(sequenceData.length);
        int tempSeq = sequenceLen[tempIndex];

        sequenceTally[tempIndex] = sequenceTally[tempIndex]++;
        for (int ctr1 = 0;
            ctr1 <= individualCoorManager[tempIndex].length;
            ctr1++) {
          for (int ctr = 0;
              ctr <= individualCoorManager[tempIndex][ctr1].length;
              ctr++) {
            individualCoorManager[tempIndex][ctr1][ctr] =
                individualCoorManager[tempIndex][ctr1][ctr] +
                    sequenceData[ctr1][ctr];
          }
        }
      }
    }
  }
}
