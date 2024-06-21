import 'dart:async';
import 'package:flash_talk/variables/shared_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../logic/theme_provider.dart';

class _SavedDecodingVariables {
  static String decodingText = "";
}

@RoutePage()
class DecodingPage extends StatefulWidget {
  const DecodingPage({super.key});

  @override
  _DecodingPageState createState() => _DecodingPageState();
}

class _DecodingPageState extends State<DecodingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final themeProvider = ThemeProvider();

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
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    initCamera();
  }

  Future<void> initCamera() async {
    controller = CameraController(
        SharedVariables.cameras[0], SharedVariables.cameraResolution,
        enableAudio: false, fps: 60);
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
    _animationController.dispose();
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
    );
  }

  Widget buildDecodingBody() {
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CameraPreview(controller),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: themeProvider.isDarkTheme
                                ? Colors.deepPurpleAccent
                                : Colors.deepPurple,
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
                    color: themeProvider.isDarkTheme
                        ? Colors.grey[800]
                        : Colors.grey[700],
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
                            style: const TextStyle(
                                fontSize: 18.0, color: Colors.white),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _SavedDecodingVariables.decodingText = "";
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.white),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text:
                                        _SavedDecodingVariables.decodingText));
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
              const SizedBox(height: 64.0),
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
                        SharedVariables.sensitivityValue =
                            value.roundToDouble();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 58.0),
            ],
          ),
          Positioned(
            bottom: 75 + 58,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  startDecodingFlashes();
                },
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: backgroundColor,
                          width: 10.0 + _animation.value / 4,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 35.0 + _animation.value,
                        backgroundColor: themeProvider.isDarkTheme
                            ? Colors.white
                            : Colors.grey[900],
                        child: Icon(
                          Icons.flash_on,
                          color: backgroundColor,
                          size: 40.0 + _animation.value,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
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
      _animationController.stop();
      _animationController.reset();
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
      _animationController.repeat(reverse: true);
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
      if (SharedVariables.currentIndex.value != 1) {
        _animationController.stop();
        _animationController.reset();
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
