import 'package:flash_talk/variables/shared_variables.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flash_talk/routes/bottom_navigation_bar.dart';
import 'package:flash_talk/logic/morse_translation.dart';
import 'package:torch_light/torch_light.dart';

@RoutePage()
class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  bool isButton1Pressed = false;
  bool isButton2Pressed = false;
  bool isMorseFlashing = false;
  bool isSwapped = false;
  String inputText = '';
  String translatedText = '';

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
              _buildLanguageSelector(
                  isSwapped ? 'Морзе' : SharedVariables.selectedLanguage),
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                onPressed: () {
                  setState(() {
                    inputText = '';
                    translatedText = '';
                    isSwapped = !isSwapped;
                  });
                },
              ),
              _buildLanguageSelector(
                  isSwapped ? SharedVariables.selectedLanguage : 'Морзе'),
            ],
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: TextField(
              onChanged: (text) {
                setState(() {
                  inputText = text;
                  if (isSwapped) {
                    translatedText = MorseTranslation.translateFromMorse(
                        text, SharedVariables.selectedLanguage);
                  } else {
                    translatedText = MorseTranslation.translateToMorse(
                        text, SharedVariables.selectedLanguage);
                  }
                });
              },
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: inputText,
                  selection: TextSelection.fromPosition(
                    TextPosition(offset: inputText.length),
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
                      inputText = '';
                      translatedText = '';
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
                        translatedText.isNotEmpty
                            ? translatedText
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
                          Clipboard.setData(
                              ClipboardData(text: translatedText));
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
                    isMorseFlashing = !isMorseFlashing;
                    if (isMorseFlashing) {
                      if (isSwapped) {
                        _morseFlashing(
                            inputText, SharedVariables.morseInterval, context);
                      } else {
                        _morseFlashing(translatedText,
                            SharedVariables.morseInterval, context);
                      }
                      isButton2Pressed = true;
                    }
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

  Future<void> _flash(int milliseconds) async {
    try {
      await TorchLight.enableTorch();
      await Future.delayed(Duration(milliseconds: milliseconds));
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error enabling torch: $e');
      }

    } finally {
      try {
        await TorchLight.disableTorch();
      } on Exception catch (e) {
        if (kDebugMode) {
          print('Error disabling torch: $e');
        }
      }
    }
  }

  Future<void> _pause(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  void _showMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _morseFlashing(
      String morseCode, int interval, BuildContext context) async {
    try {
      bool isTorchAvailable = await TorchLight.isTorchAvailable();
      if (!isTorchAvailable) {
        _showMessage('No torch available.', context);
        return;
      }

      morseCode = morseCode
          .replaceAll('▬', '-')
          .replaceAll('—', '-')
          .replaceAll('―', '-')
          .replaceAll('_', '-')
          .replaceAll('●', '.')
          .replaceAll('•', '.')
          .replaceAll('     ', ' / ');

      for (String morseChar in morseCode.split("")) {
        if (!isMorseFlashing) {
          break;
        }
        switch (morseChar) {
          case '.':
            await _flash(interval);
            await _pause(interval);
            continue;
          case '-':
            await _flash(3 * interval);
            await _pause(interval);
            continue;
          case ' ':
            await _pause(2 * interval);
            continue;
          case _:
            continue;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking torch availability: $e');
      }
      _showMessage(
          'Не удалось проверить, есть ли на устройстве фонарик', context);
    }

    setState(() {
      isButton2Pressed = false;
      isMorseFlashing = false;
    });
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
