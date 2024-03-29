import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flash_talk/routes/bottom_navigation_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Декодирование'),
        automaticallyImplyLeading: false,
      ),
      body: buildDecodingBody(),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget buildDecodingBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Плейсхолдер 4:3
          const AspectRatio(
            aspectRatio: 4 / 3,
            child: Placeholder(
              color: Colors.grey,
              strokeWidth: 2.0,
            ),
          ),
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
                onPressed: isDecodingBlinksActive
                    ? null
                    : () {
                        startDecodingBlinks();
                      },
                child: const Text('Моргания'),
              ),
              ElevatedButton(
                onPressed: isDecodingFlashesActive
                    ? null
                    : () {
                        startDecodingFlashes();
                      },
                child: const Text('Вспышки'),
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
                  thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius:
                          8.0),
                  overlayShape: RoundSliderOverlayShape(
                      overlayRadius: 16.0),
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
    setState(() {
      isDecodingBlinksActive = true;
      isDecodingFlashesActive =
          false; // Останавливаем другую функцию, если активна
    });
    // Добавьте вашу логику для Декодирования морганий
    // При окончании выполнения функции установите isDecodingBlinksActive = false
  }

  void startDecodingFlashes() {
    setState(() {
      isDecodingFlashesActive = true;
      isDecodingBlinksActive =
          false; // Останавливаем другую функцию, если активна
    });
    // Добавьте вашу логику для Декодирования вспышек
    // При окончании выполнения функции установите isDecodingFlashesActive = false
  }
}
