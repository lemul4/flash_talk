import 'package:flash_talk/shared_variables.dart';
import 'package:flutter/material.dart';
import 'decoding.dart';
import 'package:auto_route/auto_route.dart';
import 'router.dart';
import 'package:flutter/services.dart';
import 'russian_morse_dictionary.dart';

class _SavedTranslationVariables {
  static String inputText = '';
  static String translatedText = '';
  static bool isSwapped = false;
}

@RoutePage()
class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  bool isButton1Pressed = false;
  bool isButton2Pressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Перевод'),
        automaticallyImplyLeading: false,
      ),
      body: buildTranslationBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: SharedVariables.currentIndex,
        onTap: (index) {
          setState(() {
            SharedVariables.currentIndex = index;
          });

          switch (index) {
            case 0:
              context.router.navigate(TranslationRoute());
              break;
            case 1:
              context.router.navigate(DecodingRoute());
              break;
            case 2:
              context.router.navigate(OptionsRoute());
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
              _buildLanguageSelector(
                  _SavedTranslationVariables.isSwapped ? 'Русский' : 'Морзе'),
              IconButton(
                icon: Icon(Icons.swap_horiz),
                onPressed: () {
                  setState(() {
                    _SavedTranslationVariables.isSwapped =
                        !_SavedTranslationVariables.isSwapped;
                  });
                },
              ),
              _buildLanguageSelector(
                  _SavedTranslationVariables.isSwapped ? 'Морзе' : 'Русский'),
            ],
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: TextField(
              onChanged: (text) {
                setState(() {
                  _SavedTranslationVariables.inputText = text;
                  _SavedTranslationVariables.translatedText = translateToMorse(text);
                });
              },
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: _SavedTranslationVariables.inputText,
                  selection: TextSelection.fromPosition(
                    TextPosition(offset: _SavedTranslationVariables.inputText.length),
                  ),
                ),
              ),
              maxLines: null,
              expands: true,
              style: TextStyle(fontSize: 18.0),
              decoration: InputDecoration(
                hintText: 'Введите текст',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _SavedTranslationVariables.inputText = '';
                      _SavedTranslationVariables.translatedText = '';
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _SavedTranslationVariables.translatedText.isNotEmpty
                            ? _SavedTranslationVariables.translatedText
                            : 'Здесь будет перевод',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                              text: _SavedTranslationVariables.translatedText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Текст скопирован в буфер обмена'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),
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
              const SizedBox(width: 16.0),
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


  String translateToMorse(String text) {
    text = text.toUpperCase();

    List<String> morseList = [];
    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      if (RussianMorseDictionary.rusToMorse.containsKey(char)) {
        morseList.add(RussianMorseDictionary.rusToMorse[char]!);
      } else if (char == ' ') {
        morseList.add(' ');
      }
    }
    morseList = morseList.map((morse) {
      return morse.replaceAll('-', '—').replaceAll('.', '●');
    }).toList();

    return morseList.join(' ');
  }

}
