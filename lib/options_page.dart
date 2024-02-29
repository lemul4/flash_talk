import 'package:flash_talk/shared_variables.dart';
import 'package:flutter/material.dart';
import 'decoding.dart';
import 'package:auto_route/auto_route.dart';
import 'router.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: SharedVariables.currentIndex,
        onTap: (index) {
          setState(() {
            SharedVariables.currentIndex = index;
          });

          switch (index) {
            case 0:
              context.router.navigate(TranslationRoute());
            case 1:
              context.router.navigate(DecodingRoute());
            case 2:
              context.router.navigate(OptionsRoute());
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.translate),
            label: 'Перевод',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.code),
            label: 'Декодирование',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}
