import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: TranslationPage(),
    );
  }
}

class TranslationPage extends StatefulWidget {
  @override
  _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  String inputText = '';
  String translatedText = '';
  bool isSwapped = false;
  bool isButton1Pressed = false;
  bool isButton2Pressed = false;

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Перевод'),
      ),
      body: buildTranslationBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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

  Widget buildTranslationBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLanguageSelector(isSwapped ? 'Русский' : 'Морзе'),
              IconButton(
                icon: Icon(Icons.swap_horiz),
                onPressed: () {
                  setState(() {
                    isSwapped = !isSwapped;
                  });
                },
              ),
              _buildLanguageSelector(isSwapped ? 'Морзе' : 'Русский'),
            ],
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: TextField(
              onChanged: (text) {
                setState(() {
                  inputText = text;
                });
              },
              controller: TextEditingController(text: inputText),
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: 'Введите текст',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      inputText = '';
                    });
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: SingleChildScrollView(
                child: Text(
                  translatedText.isNotEmpty ? translatedText : 'Здесь будет перевод',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildIconButton(
                icon: isButton1Pressed ? Icons.stop : Icons.volume_up,
                onPressed: () {
                  setState(() {
                    isButton1Pressed = !isButton1Pressed;
                  });
                },
              ),
              SizedBox(width: 16.0),
              _buildIconButton(
                icon: isButton2Pressed ? Icons.stop : Icons.highlight,
                onPressed: () {
                  setState(() {
                    isButton2Pressed = !isButton2Pressed;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(String language) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            language,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
