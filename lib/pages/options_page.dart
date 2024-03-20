import 'package:flash_talk/routes/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

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
    );
  }
}
