import 'dart:async';

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
      body: controller.value.isInitialized ? buildDecodingBody() : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget buildDecodingBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder<Uint8List>(
            valueListenable: _adjustedImg,
            builder: (_, adjustedImg, __) {
              if (cameraImage == null) {
                return AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 2.0,
                      ),
                    ),
                  ),
                );
              }
              return AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.memory(
                  adjustedImg,
                  width: cameraImage!.width.toDouble(),
                  height: cameraImage!.height.toDouble(),
                  gaplessPlayback: true,
                  fit: BoxFit.cover,
                ),
              );
            },
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
                onPressed:   () {
                  startDecodingBlinks();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDecodingBlinksActive ? Colors.grey : Colors.white,
                ),
                child: const Text(
                  'Моргания',
                  style: TextStyle(color: Color(0xFF1C1B1F)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  startDecodingFlashes();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDecodingFlashesActive ? Colors.grey : Colors.white,
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
                  'Чувствительность ${_SavedDecodingVariables.sensitivityValue.toInt()}м'),
              SliderTheme(
                data: const SliderThemeData(
                  trackHeight: 1.0,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 16.0),
                ),
                child: Slider(
                  value: _SavedDecodingVariables.sensitivityValue,
                  min: 1.0,
                  max: 50.0,
                  onChanged: (value) {
                    setState(() {
                      _SavedDecodingVariables.sensitivityValue = value;
                    });
                  },
                ),
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

      controller.startImageStream((image) {
        cameraImage = image;
      });

      timer = Timer.periodic(Duration(milliseconds: 50), (Timer t) {
        if (cameraImage != null) {
          print(cameraImage!.format.group);
          print(cameraImage?.width.toDouble());
          print(cameraImage?.height.toDouble());
          img.Image yuv = img.Image.fromBytes(
            cameraImage!.planes[0].bytesPerRow,
            cameraImage!.height,
            cameraImage!.planes[0].bytes,
            format: img.Format.luminance,
          );
          yuv = img.copyRotate(yuv, 90);

          Uint8List png = img.encodePng(yuv) as Uint8List;
          _adjustedImg.value = png;
        }
      });

      setState(() {});
    }
  }

  void startDecodingFlashes() {
    isDecodingBlinksActive = false;
    if (isDecodingFlashesActive) {
      isDecodingFlashesActive = false;
    } else {
      controller.stopImageStream();
      cameraImage = null;
      timer?.cancel();
      isDecodingFlashesActive = true;
    }
    setState(() {
      // Останавливаем другую функцию, если активна
    });
    // При окончании выполнения функции isDecodingFlashesActive = false
  }
}
