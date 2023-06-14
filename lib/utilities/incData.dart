class IncomingData {
  int n1; // right encoder reading
  int n2; // left encoder reading
  bool isRightDirectionPositive;
  bool isLeftDirectionPositive;
  static bool startMapping = false;

  IncomingData({
    required this.n1,
    required this.n2,
    required this.isRightDirectionPositive,
    required this.isLeftDirectionPositive,
  }) {
    startMapping = true;
    print("Intialized");
  }
}
