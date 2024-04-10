import 'package:sound_generator/waveTypes.dart';
import 'package:flutter/material.dart';

class SharedVariables {
  static ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
  static int morseInterval = 150;
  static double frequency = 1000;
  static double balance = 0;
  static double volume = 1;
  static waveTypes waveType = waveTypes.SQUAREWAVE;
  static int sampleRate = 96000;
  static String selectedLanguage = 'Русский';
  static double sensitivityValue = 15.0;
  static int cameraX = 1360;
  static int cameraY = 1024;
}
