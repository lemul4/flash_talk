import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flash_talk/variables/shared_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flash_talk/routes/bottom_navigation_bar.dart';
import 'package:camera/camera.dart';
import 'package:opencv_dart/opencv_dart.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'dart:developer';

class _SavedDecodingVariables {
  static double sensitivityValue = 25.0;
  static String decodingText = "";
}

@RoutePage()
class DecodingPage extends StatefulWidget {
  const DecodingPage({super.key});

  @override
  _DecodingPageState createState() => _DecodingPageState();
}

class _DecodingPageState extends State<DecodingPage> {
  bool isDecodingFlashesActive = false;
  bool isDecodingBlinksActive = false;
  late List<CameraDescription> cameras;
  late CameraController controller;
  CameraImage? cameraImage;
  Uint8List? imageData;
  late ValueNotifier<Uint8List> _adjustedImg;
  Timer? timer;
  late double fpsCamera;
  late double fpsDecoding;
  late ValueNotifier<String> _textCamera;
  late ValueNotifier<String> _textDecoding;

  @override
  void initState() {
    super.initState();
    initCamera();
    fpsCamera = 0;
    fpsDecoding = 0;
    _textCamera = ValueNotifier("");
    _textDecoding = ValueNotifier("");
    _adjustedImg = ValueNotifier(Uint8List(0));
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], SharedVariables.cameraResolution,
        enableAudio: false);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    timer?.cancel();
    controller.stopImageStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Декодирование'),
        automaticallyImplyLeading: false,
      ),
      body: controller.value.isInitialized
          ? buildDecodingBody()
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget buildDecodingBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(controller),

                  ///Image.memory(
                  ///  adjustedImg,
                  ///  gaplessPlayback: true,
                  ///   fit: BoxFit.fill,),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 75, // Высота квадрата
                    width: 75, // Ширина квадрата
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red, // Цвет границы
                        width: 3, // Толщина границы
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Плейсхолдер 4:3
          const SizedBox(height: 16.0),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _SavedDecodingVariables.decodingText.isNotEmpty
                            ? _SavedDecodingVariables.decodingText
                            : " Здесь будет находиться декодированный текст",
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _SavedDecodingVariables.decodingText = "";
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text: _SavedDecodingVariables.decodingText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Текст скопирован в буфер обмена'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    startDecodingBlinks();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDecodingBlinksActive ? Colors.grey : Colors.white,
                ),
                child: const Text(
                  'Моргания',
                  style: TextStyle(color: Color(0xFF1C1B1F)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    startDecodingFlashes();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDecodingFlashesActive ? Colors.grey : Colors.white,
                ),
                child: const Text(
                  'Вспышки',
                  style: TextStyle(color: Color(0xFF1C1B1F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Светочувствительность: ${SharedVariables.sensitivityValue.round()} м',
              ),
              Slider(
                value: SharedVariables.sensitivityValue,
                min: 0,
                max: 255,
                label: SharedVariables.sensitivityValue.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    SharedVariables.sensitivityValue = value.roundToDouble();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void startDecodingBlinks() {
    isDecodingFlashesActive = false;
    if (isDecodingBlinksActive) {
      isDecodingBlinksActive = false;
      controller.stopImageStream();
      cameraImage = null;
      timer?.cancel();
      setState(() {});
    } else {
      isDecodingBlinksActive = true;
      controller.stopImageStream();
      cameraImage = null;
      timer?.cancel();
      setState(() {});
    }
  }

  Future<void> startDecodingFlashes() async {
    isDecodingBlinksActive = false;
    if (isDecodingFlashesActive) {
      isDecodingFlashesActive = false;
      controller.stopImageStream();
      cameraImage = null;
      timer?.cancel();
      setState(() {});
    } else {
      isDecodingFlashesActive = true;
      controller.stopImageStream();
      cameraImage = null;
      timer?.cancel();

      int frameCount = 0;
      late DateTime? flashStartTime;
      late DateTime? flashEndTime;

      controller.startImageStream((image) {
        cameraImage = image;
      });
      DateTime startTime = DateTime.now();
      flashStartTime = DateTime.now();
      flashEndTime = DateTime.now();
      flashStartTime = null;
      while (isDecodingFlashesActive) {
        if (cameraImage != null) {
          frameCount++;
          final bytes = cameraImage!.planes[0].bytes;
          const rowLength = 320;
          const columnLength = 240;
          List<List<int>> matrix = List.generate(
              rowLength, (i) => List.generate(columnLength, (j) => 0));

          for (var i = 0; i < columnLength; i++) {
            for (var j = 0; j < rowLength; j++) {
              matrix[j][columnLength - i - 1] = bytes[i * rowLength + j];
            }
          }

          late double meanLight;
          int sumLights = 0;
          int k = 0;
          for (var i = 94; i < 145; i++) {
            for (var j = 134; j < 185; j++) {
              sumLights = sumLights + matrix[j][i];
              k++;
            }
          }
          meanLight = sumLights / k;
          if (meanLight > SharedVariables.sensitivityValue) {
            if (flashStartTime == null) {
              flashStartTime = DateTime.now();
              if (flashEndTime != null) {
                if (DateTime.now().difference(flashEndTime).inMilliseconds >
                        3 * SharedVariables.morseInterval -
                            SharedVariables.morseInterval &&
                    DateTime.now().difference(flashEndTime).inMilliseconds <
                        3 * SharedVariables.morseInterval +
                            SharedVariables.morseInterval) {
                  _SavedDecodingVariables.decodingText += " ";
                  _textDecoding.value = _SavedDecodingVariables.decodingText;
                }
                if (DateTime.now().difference(flashEndTime).inMilliseconds >
                    7 * SharedVariables.morseInterval -
                        SharedVariables.morseInterval) {
                  _SavedDecodingVariables.decodingText += " / ";
                  _textDecoding.value = _SavedDecodingVariables.decodingText;
                }
                flashEndTime = null;
              }
            }
          } else {
            if (flashEndTime == null) {
              flashEndTime = DateTime.now();
              if (flashStartTime != null) {
                if (DateTime.now().difference(flashStartTime).inMilliseconds >
                        SharedVariables.morseInterval -
                            SharedVariables.morseInterval * 0.8 &&
                    DateTime.now().difference(flashStartTime).inMilliseconds <
                        SharedVariables.morseInterval +
                            SharedVariables.morseInterval * 0.8) {
                  _SavedDecodingVariables.decodingText += ".";
                  _textDecoding.value = _SavedDecodingVariables.decodingText;
                }
                if (DateTime.now().difference(flashStartTime).inMilliseconds >
                        3 * SharedVariables.morseInterval -
                            SharedVariables.morseInterval &&
                    DateTime.now().difference(flashStartTime).inMilliseconds <
                        3 * SharedVariables.morseInterval +
                            SharedVariables.morseInterval) {
                  _SavedDecodingVariables.decodingText += "-";
                  _textDecoding.value = _SavedDecodingVariables.decodingText;
                }
                flashStartTime = null;
              }
            }
          }

          ///for (var i = 0; i < matrix.length; i++) {
          ///print(matrix[i]);
          /// }
          print(meanLight);
          """img.Image outputImage = img.Image.fromBytes(
            cameraImage!.width,
            cameraImage!.height,
            cameraImage!.planes[0].bytes,
            format: img.Format.luminance,
          );

          outputImage = img.copyRotate(outputImage, 90);
          Uint8List png = img.encodePng(outputImage) as Uint8List;
          _adjustedImg.value = png;""";

          if (DateTime.now().difference(startTime).inSeconds >= 1) {
            double fps =
                frameCount / DateTime.now().difference(startTime).inSeconds;
            print('FPS: $fps');
            frameCount = 0;
            startTime = DateTime.now();
          }
          cameraImage = null;
        } else {
          await Future.delayed(const Duration(microseconds: 1));
        }
        setState(() {});
      }

      setState(() {});
    }
  }
}
