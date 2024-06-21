import 'package:flash_talk/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flash_talk/variables/shared_variables.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final Function(int) onTap;

  const CustomBottomNavigationBar({super.key, required this.onTap});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SharedVariables.currentIndex,
      builder: (context, value, child) {
        return BottomNavigationBar(
          currentIndex: value,
          onTap: (index) {
            widget.onTap(index);
            switch (index) {
              case 0:
                context.router.navigate(const TranslationRoute());
                break;
              case 1:
                context.router.navigate(const DecodingRoute());
                break;
              case 2:
                context.router.navigate(const OptionsRoute());
                break;
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
      },
    );
  }
}
