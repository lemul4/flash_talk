import 'package:camera/camera.dart';
import 'package:flash_talk/routes/router.dart';
import 'package:flash_talk/variables/shared_variables.dart';
import 'package:flutter/material.dart';


Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    SharedVariables.cameras = await availableCameras();
    print(SharedVariables.cameras.length);
  } on CameraException {
    print('Error: Could not get camera list');}
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
