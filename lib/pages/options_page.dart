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
            'Светочувствительность: ${SharedVariables.sensitivityValue.round()} м',
          ),
          Slider(
            value: SharedVariables.sensitivityValue,
            min: 1,
            max: 30,
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
            value: '${SharedVariables.cameraX}x${SharedVariables.cameraY}',
            items: <String>[
              '320x240',
              '640x480',
              '800x600',
              '1024x768',
              '1280x960',
              '1360x1024',
              '1440x1080',
              '1600x1200',
              '1920x1440',
              '2048x1536',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                var dimensions = newValue!.split('x');
                SharedVariables.cameraX = int.parse(dimensions[0]);
                SharedVariables.cameraY = int.parse(dimensions[1]);
              });
            },
          ),
          const Divider(),
          InkWell(
            onTap: () {
              setState(() {

                SharedVariables.morseInterval = 150;
                SharedVariables.frequency = 1000;
                SharedVariables.sensitivityValue = 15.0;
                SharedVariables.cameraX = 1360;
                SharedVariables.cameraY = 1024;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(1000.0),
              ),
              child: const Center(
                child: Text(
                  'Сбросить настройки',
                  style: TextStyle(fontSize: 16.0, ),
                ),
              ),
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
}
