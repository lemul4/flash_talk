import 'dart:async';

import 'package:flash_talk/variables/shared_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flash_talk/routes/bottom_navigation_bar.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../main.dart';


class _SavedDecodingVariables {
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
  late CameraController controller;
  CameraImage? cameraImage;
  Uint8List? imageData;
  Timer? timer;
  late double fpsCamera;
  late double fpsDecoding;
  late ValueNotifier<String> _textDecoding;
  late ValueNotifier<String?> _fpsNotifier;
  late ValueNotifier<String?> _meanLightNotifier;

  @override
  void initState() {
    super.initState();
    fpsCamera = 0;
    fpsDecoding = 0;
    _fpsNotifier = ValueNotifier<String?>(null);
    _meanLightNotifier = ValueNotifier<String?>(null);
    _textDecoding = ValueNotifier("");
    initCamera();

  }

  Future<void> initCamera() async {
    controller =
        CameraController(SharedVariables.cameras[0], SharedVariables.cameraResolution, enableAudio: false, fps: 60);
    controller.setFocusMode(FocusMode.locked);
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
    _meanLightNotifier.dispose();
    _fpsNotifier.dispose();
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
          : const Center(child: CircularProgressIndicator()),
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
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder<String?>(
                valueListenable: _fpsNotifier,
                builder: (context, value, child) {
                  if (value == null) {
                    return const SizedBox(height: 20.0);
                  } else {
                    return Text(value);
                  }
                },
              ),
              ValueListenableBuilder<String?>(
                valueListenable: _meanLightNotifier,
                builder: (context, value, child) {
                  if (value == null) {
                    return const SizedBox(height: 20.0);
                  } else {
                    return Text(value);
                  }
                },
              ),
            ],
          ),

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
                'Светочувствительность: ${SharedVariables.sensitivityValue.round()}',
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
    if (isDecodingFlashesActive) {
      isDecodingFlashesActive = false;
      controller.stopImageStream();
      cameraImage = null;
      timer?.cancel();
      _fpsNotifier = ValueNotifier<String?>(null);
      _meanLightNotifier = ValueNotifier<String?>(null);
      setState(() {});
    } else {
      isDecodingFlashesActive = true;
      cameraImage = null;
      timer?.cancel();
      controller.setFocusMode(FocusMode.locked);

      controller.startImageStream((image) {
        cameraImage = image;
      });

      decodeFlashes();

      setState(() {});
    }
  }

  Future<void> decodeFlashes() async {
    int frameCount = 0;
    DateTime? flashStartTime;
    DateTime? flashEndTime;
    DateTime startTime = DateTime.now();

    const double startRowPercentage = 0.4;
    const double endRowPercentage = 0.6;
    const double startColPercentage = 0.4;
    const double endColPercentage = 0.6;

    while (isDecodingFlashesActive) {
      if(SharedVariables.currentIndex.value != 1) {
        isDecodingFlashesActive = false;
        controller.stopImageStream();
        cameraImage = null;
        timer?.cancel();
        _fpsNotifier = ValueNotifier<String?>(null);
        _meanLightNotifier = ValueNotifier<String?>(null);
        break;
      }
      if (cameraImage != null) {
        frameCount++;
        final bytes = cameraImage!.planes[0].bytes;
        int rowLength = cameraImage!.width;
        int columnLength = cameraImage!.height;

        int startRow = (startRowPercentage * rowLength).toInt();
        int endRow = (endRowPercentage * rowLength).toInt();
        int startCol = (startColPercentage * columnLength).toInt();
        int endCol = (endColPercentage * columnLength).toInt();
        int numPixels = (endRow - startRow) * (endCol - startCol);

        int sumLights = 0;
        for (var i = startCol; i < endCol; i++) {
          for (var j = startRow; j < endRow; j++) {
            sumLights += bytes[i * rowLength + j];
          }
        }

        int meanLight = sumLights ~/ numPixels;
        _meanLightNotifier.value = 'Яркость: $meanLight';

        if (meanLight > SharedVariables.sensitivityValue) {
          if (flashStartTime == null) {
            flashStartTime = DateTime.now();
            if (flashEndTime != null) {
              int duration =
                  DateTime.now().difference(flashEndTime).inMilliseconds;
              if (duration >
                      3 * SharedVariables.morseInterval -
                          SharedVariables.morseInterval &&
                  duration <
                      3 * SharedVariables.morseInterval +
                          SharedVariables.morseInterval) {
                _SavedDecodingVariables.decodingText += " ";
              } else if (duration >
                  7 * SharedVariables.morseInterval -
                      SharedVariables.morseInterval) {
                _SavedDecodingVariables.decodingText += " / ";
              }
              _textDecoding.value = _SavedDecodingVariables.decodingText;
              flashEndTime = null;
            }
          }
        } else {
          if (flashEndTime == null) {
            flashEndTime = DateTime.now();
            if (flashStartTime != null) {
              int duration =
                  DateTime.now().difference(flashStartTime).inMilliseconds;
              if (duration > SharedVariables.morseInterval * 0.2 &&
                  duration < SharedVariables.morseInterval * 1.8) {
                _SavedDecodingVariables.decodingText += "●";
              } else if (duration >
                      3 * SharedVariables.morseInterval -
                          SharedVariables.morseInterval &&
                  duration <
                      3 * SharedVariables.morseInterval +
                          SharedVariables.morseInterval) {
                _SavedDecodingVariables.decodingText += "—";
              }
              _textDecoding.value = _SavedDecodingVariables.decodingText;
              flashStartTime = null;
            }
          }
        }

        """img.Image outputImage = img.Image.fromBytes(
          cameraImage!.width,
          cameraImage!.height,
          bytes,
          format: img.Format.luminance,
        );

        outputImage = img.copyRotate(outputImage, 90);
        Uint8List png = Uint8List.fromList(img.encodePng(outputImage));
        _adjustedImg.value = png;""";

        if (DateTime.now().difference(startTime).inSeconds >= 1) {
          int fps =
          frameCount ~/ DateTime.now().difference(startTime).inSeconds;
          _fpsNotifier.value = 'ФПС: $fps';
          frameCount = 0;
          startTime = DateTime.now();
        }
        cameraImage = null;
      } else {
        await Future.delayed(const Duration(microseconds: 1));
      }
      setState(() {});
    }
  }
}
