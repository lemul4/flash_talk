import 'package:flash_talk/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flash_talk/variables/shared_variables.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});
  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: SharedVariables.currentIndex,
      onTap: (index) {
      setState(() {
        SharedVariables.currentIndex = index;
      });
      switch (index) {
        case 0:
          context.router.replace(const TranslationRoute());
        case 1:
          context.router.replace(const DecodingRoute());
        case 2:
          context.router.replace(const OptionsRoute());
      }
    },
      items: const [
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
    );
  }
}
