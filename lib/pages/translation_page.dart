import 'package:flash_talk/variables/shared_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flash_talk/routes/bottom_navigation_bar.dart';
import 'package:flash_talk/logic/morse_translation.dart';

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
        title: const Text('Перевод'),
        automaticallyImplyLeading: false,
      ),
      body: buildTranslationBody(),
      bottomNavigationBar: const CustomBottomNavigationBar(),
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
              _buildLanguageSelector(_SavedTranslationVariables.isSwapped
                  ? 'Морзе'
                  : SharedVariables.selectedLanguage),
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                onPressed: () {
                  setState(() {
                    _SavedTranslationVariables.inputText = '';
                    _SavedTranslationVariables.translatedText = '';
                    _SavedTranslationVariables.isSwapped =
                        !_SavedTranslationVariables.isSwapped;
                  });
                },
              ),
              _buildLanguageSelector(_SavedTranslationVariables.isSwapped
                  ? SharedVariables.selectedLanguage
                  : 'Морзе'),
            ],
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: TextField(
              onChanged: (text) {
                setState(() {
                  _SavedTranslationVariables.inputText = text;
                  if (_SavedTranslationVariables.isSwapped) {
                    _SavedTranslationVariables.translatedText =
                        MorseTranslation.translateFromMorse(
                            text, SharedVariables.selectedLanguage);
                  } else {
                    _SavedTranslationVariables.translatedText =
                        MorseTranslation.translateToMorse(
                            text, SharedVariables.selectedLanguage);
                  }
                });
              },
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: _SavedTranslationVariables.inputText,
                  selection: TextSelection.fromPosition(
                    TextPosition(
                        offset: _SavedTranslationVariables.inputText.length),
                  ),
                ),
              ),
              maxLines: null,
              expands: true,
              style: const TextStyle(fontSize: 18.0),
              decoration: InputDecoration(
                hintText: 'Введите текст',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
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
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                              text: _SavedTranslationVariables.translatedText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
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
      child: InkWell(
        onTap: () {
          _showLanguagePicker(context);
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Text(
              language,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    String? selectedLanguage = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, 'Русский'),
            _buildLanguageOption(context, 'Английский'),
          ],
        );
      },
    );

    if (selectedLanguage != null) {
      setState(() {
        SharedVariables.selectedLanguage = selectedLanguage;
      });
    }
  }

  Widget _buildLanguageOption(BuildContext context, String language) {
    return ListTile(
      title: Text(language),
      onTap: () {
        Navigator.pop(context, language);
      },
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
          padding: const EdgeInsets.all(8.0),
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
