import 'package:camera/camera.dart';
import 'package:flash_talk/pages/decoding_page.dart';
import 'package:flash_talk/pages/options_page.dart';
import 'package:flash_talk/pages/translation_page.dart';
import 'package:flash_talk/routes/bottom_navigation_bar.dart';
import 'package:flash_talk/variables/shared_variables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    SharedVariables.cameras = await availableCameras();
    print(SharedVariables.cameras.length);
  } on CameraException {
    print('Error: Could not get camera list');
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MainPageView extends StatefulWidget {
  const MainPageView({super.key});

  @override
  _MainPageViewState createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  final _pageController = PageController();
  bool _isBottomNavigationTapped = false;

  @override
  void initState() {
    super.initState();
    SharedVariables.currentIndex.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    SharedVariables.currentIndex.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    if (_isBottomNavigationTapped) {
      _pageController.jumpToPage(SharedVariables.currentIndex.value);
      _isBottomNavigationTapped = false;
    } else {
      _pageController.animateToPage(
        SharedVariables.currentIndex.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void onBottomNavigationTap(int index) {
    _isBottomNavigationTapped = true;
    SharedVariables.currentIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              if (!_isBottomNavigationTapped) {
                SharedVariables.currentIndex.value = index;
              }
            },
            children: const [
              TranslationPage(),
              DecodingPage(),
              OptionsPage(),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNavigationBar(onTap: onBottomNavigationTap),
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      theme: themeProvider.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: const MainPageView(),
    );
  }
}
