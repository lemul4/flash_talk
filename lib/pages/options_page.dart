import 'package:camera/camera.dart';
import 'package:flash_talk/routes/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:url_launcher/url_launcher.dart';

import '../variables/shared_variables.dart';

@RoutePage()
class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Интервал Морзе: ${SharedVariables.morseInterval} мс',
          ),
          Slider(
            value: SharedVariables.morseInterval.toDouble(),
            min: 50,
            max: 500,
            label: SharedVariables.morseInterval.round().toString(),
            onChanged: (double value) {
              setState(() {
                SharedVariables.morseInterval = value.round();
              });
            },
          ),
          const Divider(),
          Text(
            'Звуковой тон Морзе: ${SharedVariables.frequency.round()} Гц',
          ),
          Slider(
            value: SharedVariables.frequency,
            min: 200,
            max: 5000,
            label: SharedVariables.frequency.round().toString(),
            onChanged: (double value) {
              setState(() {
                SharedVariables.frequency = value.roundToDouble();
              });
            },
          ),
          const Divider(),
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
          const Divider(),
          const Text('Разрешение камеры'),
          DropdownButton<String>(
            value: resolutionPresetToString(SharedVariables.cameraResolution),
            items: <String>[
              '240p',
              '480p',
              '720p',
              '1080p',
              '2160p',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                SharedVariables.cameraResolution = stringToResolutionPreset(newValue);
              });
            },
          ),
          const Divider(),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Здесь устанавливаются значения по умолчанию
                SharedVariables.morseInterval = 150;
                SharedVariables.frequency = 1000;
                SharedVariables.sensitivityValue = 128.0;
                SharedVariables.cameraResolution = ResolutionPreset.low;

              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // цвет кнопки
            ),
            child: const Text(
              'Сбросить настройки',
              style: TextStyle(color: Color(0xFF1C1B1F)), // цвет текста
            ),
          ),
          const Divider(),
          const Text('Оцените проект на GitHub'),
          TextButton(
            onPressed: () {
              launch('https://github.com/lemul4/flash_talk');
            },
            child: const Text('https://github.com/lemul4/flash_talk'),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
  String resolutionPresetToString(ResolutionPreset preset) {
    switch (preset) {
      case ResolutionPreset.low:
        return '240p';
      case ResolutionPreset.medium:
        return '480p';
      case ResolutionPreset.high:
        return '720p';
      case ResolutionPreset.veryHigh:
        return '1080p';
      case ResolutionPreset.ultraHigh:
        return '2160p';
      default:
        return '480p';
    }
  }

  ResolutionPreset stringToResolutionPreset(String? resolution) {
    switch (resolution) {
      case '240p':
        return ResolutionPreset.low;
      case '480p':
        return ResolutionPreset.medium;
      case '720p':
        return ResolutionPreset.high;
      case '1080p':
        return ResolutionPreset.veryHigh;
      case '2160p':
        return ResolutionPreset.ultraHigh;
      default:
        return ResolutionPreset.medium;
    }
  }
}
