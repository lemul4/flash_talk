import 'package:flash_talk/shared_variables.dart';
import 'package:flutter/material.dart';
import 'decoding.dart';
import 'package:auto_route/auto_route.dart';
import 'router.dart';
@RoutePage()
class TranslationPage extends StatefulWidget {
  @override
  _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  String inputText = '';
  String translatedText = '';
  bool isSwapped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Перевод'),
        automaticallyImplyLeading: false,
      ),
      body: buildTranslationBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: SharedVariables.currentIndex,  // Use the shared variable
        onTap: (index) {
          setState(() {
            SharedVariables.currentIndex = index;  // Update the shared variable
          });

          switch (index) {
            case 0:
              context.router.push(TranslationRoute());
              break;
            case 1:
              context.router.push(DecodingRoute());
              break;
            case 2:
              break;
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
              style: TextStyle(fontSize: 18.0),
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
              padding: EdgeInsets.fromLTRB(8, 8, 50, 8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: SingleChildScrollView(
                child: Text(
                  inputText.isNotEmpty ? inputText : 'Здесь будет перевод',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
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
}