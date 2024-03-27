import 'package:flash_talk/routes/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

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
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Интервал Морзе: ${SharedVariables.morseInterval} мс',
              style: const TextStyle(fontSize: 24),
            ),
            Slider(
              value: SharedVariables.morseInterval.toDouble(),
              min: 50,
              max: 500,
              divisions: 45,
              label: SharedVariables.morseInterval.round().toString(),
              onChanged: (double value) {
                setState(() {
                  SharedVariables.morseInterval = value.round();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
