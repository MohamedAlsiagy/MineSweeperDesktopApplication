// ignore_for_file: prefer_initializing_formals

import 'dart:math';
import 'package:minesweeper/utilities/robot.dart';
import 'package:minesweeper/utilities/robotSpacialData.dart';

class MathematicalModel {
  //const Inputs
  static const double radiusOfWheel =
      7; // Measured in cm // TODO: To be Modified
  static const double encoderPulsesPerRotation = 16; // TODO: To be Modified
  static const double distanceBetweenWheels = 50; // TODO: To be Modified

  //variable Inputs
  int n1; // right encoder reading
  int n2; // left encoder reading
  bool isRightDirectionPositive;
  bool isLeftDirectionPositive;

  //static Inputs
  static SpacialData initialSpacialData = SpacialData(
    angle: pi / 2,
    postion: Postion(x: 0, y: 0),
  ); //TODO: To be overwritten in first build

  //Usage Variables
  late double c1; // Circumference of the right path
  late double c2; // Circumference of the left path
  late double deltaTheta;
  late double radiusOfGroundRotation;

  //Output Variables
  late SpacialData finalSpacialData;

  MathematicalModel({
    required this.n1,
    required this.n2,
    this.isRightDirectionPositive = true,
    this.isLeftDirectionPositive = true,
  });

  double calculateCircumference(
      {required int encoderReading, required bool isPostiveDirection}) {
    double circumference = (isPostiveDirection ? 1 : -1) *
        radiusOfWheel *
        (encoderReading / encoderPulsesPerRotation) *
        2 *
        pi;
    return circumference;
  }

  void calculateRadius() {
    c1 = calculateCircumference(
        encoderReading: n1, isPostiveDirection: isRightDirectionPositive);
    c2 = calculateCircumference(
        encoderReading: n2, isPostiveDirection: isLeftDirectionPositive);
    if (c1 == c2) {
      radiusOfGroundRotation = double.infinity;
      return;
    }

    radiusOfGroundRotation =
        distanceBetweenWheels * ((1 / ((c2 / c1) - 1)) + 0.5);
  }

  void calculateDeltaTheta() {
    deltaTheta = (c2 - c1) / distanceBetweenWheels;
  }

  double calculateFinalAngle() {
    calculateDeltaTheta();
    double finalAngle = (initialSpacialData.angle - deltaTheta);
    //TODO : remove or let the modelus %%
    //TODO : remove or let the modelus %%
    //TODO : remove or let the modelus %%
    //TODO : remove or let the modelus %%
    return finalAngle;
  }

  SpacialData calculateFinalSpacialData() {
    calculateRadius();
    double finalAngle = calculateFinalAngle();
    late Postion deltaFinalPostion;
    if (c1 != c2) {
      deltaFinalPostion = Postion(
        x: radiusOfGroundRotation * sin(initialSpacialData.angle) -
            radiusOfGroundRotation * sin(finalAngle),
        y: -radiusOfGroundRotation * cos(initialSpacialData.angle) +
            radiusOfGroundRotation * cos(finalAngle),
      );
    } else {
      deltaFinalPostion = Postion(
        x: c1 * cos(initialSpacialData.angle),
        y: c1 * sin(initialSpacialData.angle),
      );
    }
    print(deltaFinalPostion);
    finalSpacialData = SpacialData(
        postion: deltaFinalPostion + initialSpacialData.postion,
        angle: finalAngle);
    initialSpacialData = finalSpacialData; // TODO : Accumulation goes here
    return finalSpacialData;
  }
}
//TODO: Add calibration to the starting postion of the wheel to not start from the middle of two encoder pulses
//ex : rotate until a signal is detected
//TODO: Add calibration to the starting postion of the wheel to not start from the middle of two encoder pulses
//ex : rotate until a signal is detected
//TODO: Add calibration to the starting postion of the wheel to not start from the middle of two encoder pulses
//ex : rotate until a signal is detected
//TODO: Add calibration to the starting postion of the wheel to not start from the middle of two encoder pulses
//ex : rotate until a signal is detected
//TODO: Add calibration to the starting postion of the wheel to not start from the middle of two encoder pulses
//ex : rotate until a signal is detected
//TODO: Add calibration to the starting postion of the wheel to not start from the middle of two encoder pulses
//ex : rotate until a signal is detected
//TODO: Add calibration to the starting postion of the wheel to not start from the middle of two encoder pulses
//ex : rotate until a signal is detected

//TODO : Adding delays in control the robot for better tracking and accounting for reversing direction issue
//TODO : Adding delays in control the robot for better tracking and accounting for reversing direction issue
//TODO : Adding delays in control the robot for better tracking and accounting for reversing direction issue
//TODO : Adding delays in control the robot for better tracking and accounting for reversing direction issue
//TODO : Adding delays in control the robot for better tracking and accounting for reversing direction issue
//TODO : Adding delays in control the robot for better tracking and accounting for reversing direction issue
//TODO : Adding delays in control the robot for better tracking and accounting for reversing direction issue
