// import 'dart:math';
// import 'package:minesweeper/utilities/robot.dart';
import 'package:minesweeper/utilities/robotSpacialData.dart';

import 'constants.dart';

class Tile {
  late MineTypes _isMineHere;
  late Postion postion;
  bool isRobotHere = false;
  static Postion _robotPostion = Postion(x: 0, y: 0);
  static const double tileLength = 100; //measured in cm
  static late int numberOfGrids;
  static double tileEquivalentLengthOfPixels = tileLength;
  static Map<String, List<Tile>> minePlaces = {
    "${MineTypes.surfaceMine}": [],
    "${MineTypes.underGroundMine}": []
  };

  Tile({required MineTypes isMineHere, required this.postion}) {
    _isMineHere = isMineHere;
    if (identical(_robotPostion.x, postion)) {
      isRobotHere = true;
    }
  }

  Tile.fromIndex(
      {required int index,
      required MineTypes mineType,
      required int numberOfGrids}) {
    _isMineHere = mineType;
    postion = Postion(
      x: index % numberOfGrids,
      y: (numberOfGrids - 1) - (index ~/ numberOfGrids),
    );
    if (_robotPostion.x == postion.x && _robotPostion.y == postion.y) {
      isRobotHere = true;
    }
  }

  MineTypes getMineType() => _isMineHere;

  void setMineType(MineTypes mineType) {
    if (_isMineHere != mineType) {
      if (_isMineHere != MineTypes.safe) {
        minePlaces["$_isMineHere"]!.remove(this);
      }

      _isMineHere = mineType;

      if (_isMineHere != MineTypes.safe) {
        minePlaces["$_isMineHere"]!.add(this);
      }
    }
  }
  static int fromGridPostionToIndex(Postion postion ) {
    return (((numberOfGrids - 1) - postion.y) * numberOfGrids + postion.x)
    as int;
  }
  static Postion decodeActualPosToGridPos({
    required actualPostion,
    required double robotSize,
    Postion? relativeReferenceOnTheRobot,
  }) {
    relativeReferenceOnTheRobot ??= Postion(x: 0.5, y: 0.5);
    // print((actualPostion.x - robotSize) / tileEquivalentLengthOfPixels);
    Postion relativeActualPostionToRef = Postion(
      x: actualPostion.x -
          robotSize +
          relativeReferenceOnTheRobot.x * robotSize,
      y: actualPostion.y -
          robotSize +
          relativeReferenceOnTheRobot.y * robotSize,
    );
    Postion postionOnGridVirtual = Postion(
      x: relativeActualPostionToRef.x ~/ tileEquivalentLengthOfPixels,
      y: relativeActualPostionToRef.y ~/ tileEquivalentLengthOfPixels,
    );
    Postion postionOnGrid = Postion(
      x: () {
        if (postionOnGridVirtual.x > numberOfGrids - 1) {
          return numberOfGrids - 1;
        } else if (postionOnGridVirtual.x < 0) {
          return 0;
        } else {
          return postionOnGridVirtual.x;
        }
      }(),
      y: () {
        if (postionOnGridVirtual.y > numberOfGrids - 1) {
          return numberOfGrids - 1;
        } else if (postionOnGridVirtual.y < 0) {
          return 0;
        } else {
          return postionOnGridVirtual.y;
        }
      }(),
    );
    return postionOnGrid;
  }

  static Postion specifyActualPostionOnTile({
    required Postion tilePostionOnGrid,
    required Postion
        relativePostionInsideTile, //Relative Postion inside the tile provide (x , y) in range of (0 -> 1 , 0 -> 1) for meaningful results
    required double robotSize,
    Postion? relativeReferenceOnTheRobot,
  }) {
    relativeReferenceOnTheRobot ??= Postion(x: 0.5, y: 0.5);
    Postion actualPostionOfRobot = Postion(
      x: (tilePostionOnGrid.x + relativePostionInsideTile.x) *
              tileEquivalentLengthOfPixels +
          (1 - relativeReferenceOnTheRobot.x) * robotSize,
      y: (tilePostionOnGrid.y + relativePostionInsideTile.y) *
              tileEquivalentLengthOfPixels +
          (1 - relativeReferenceOnTheRobot.y) * robotSize,
    );
    return actualPostionOfRobot;
  }

  static Map<String, int> setRobotPostionOnGrid(
      {required Postion robotPostion}) {

    int oldIndex = fromGridPostionToIndex(_robotPostion );
    int newIndex = fromGridPostionToIndex(robotPostion);
    _robotPostion = robotPostion;
    // print([oldIndex ,newIndex]);
    return {"new": newIndex, "old": oldIndex};
  }
  @override
  String toString() {
    return "${'$_isMineHere'.replaceFirst("MineTypes.", "")} Located at  ${fromIndexToAlphabet(index: postion.y as int)}${postion.x+1}";
  }
  static Postion getRobotPostion() => _robotPostion;
}

enum MineTypes { safe, underGroundMine, surfaceMine }
