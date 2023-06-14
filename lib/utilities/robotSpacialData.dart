import 'dart:math';

import 'package:minesweeper/utilities/tile.dart';

class Postion {
  late num x;
  late num y;

  Postion({required this.x, required this.y});

  Postion.fromList({required List list}) {
    x = list[0];
    y = list[0];
  }

  static double cmToPixels(num cm) =>
      cm * (Tile.tileEquivalentLengthOfPixels / Tile.tileLength);

  static double pixelsToCm(num pixels) =>
      pixels / (Tile.tileEquivalentLengthOfPixels / Tile.tileLength);

  Postion convertFromCmsToPixels() {
    Postion finalPostion = Postion(
      x: cmToPixels(x),
      y: cmToPixels(y),
    );
    return finalPostion;
  }

  Postion convertFromPixelsToCms() {
    Postion finalPostion = Postion(
      x: pixelsToCm(x),
      y: pixelsToCm(y),
    );
    return finalPostion;
  }

  Postion operator +(Postion b) {
    Postion c = Postion(x: x + b.x, y: y + b.y);
    return c;
  }
  @override
  String toString() {
    return 'Postion: ($x , $y) ';
  }
}

class SpacialData {
  Postion postion;
  double angle;

  SpacialData({required this.postion, required this.angle});

  String toString() {
    return 'SpacialData: (${postion.toString()}, Angle:$angle)';
  }
}
