import 'package:flash_talk/router.dart';
import 'package:flutter/material.dart';
import 'decoding.dart';
import 'router.dart';
import 'translation_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData.dark(),
      routerConfig: _appRouter.config(),
    );
  }
}

