import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class SharedVariables {
  static List<CameraDescription> cameras = <CameraDescription>[];
  static ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
  static int morseInterval = 150;
  static double frequency = 1000;
  static String selectedLanguage = 'Русский';
  static double sensitivityValue = 128.0;
  static ResolutionPreset cameraResolution = ResolutionPreset.low;

}
