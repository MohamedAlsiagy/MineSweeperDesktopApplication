String fromIndexToAlphabet({required int index}) {
    String output = String.fromCharCode("A".codeUnitAt(0) + index);
    return output;
  }