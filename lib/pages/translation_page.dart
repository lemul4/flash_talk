import 'package:flash_talk/variables/shared_variables.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flash_talk/routes/bottom_navigation_bar.dart';
import 'package:flash_talk/logic/morse_translation.dart';
import 'package:sound_generator/sound_generator.dart';
import 'package:sound_generator/waveTypes.dart';
import 'package:flash_talk/logic/morse_transmission.dart';

@RoutePage()
class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  bool isMorseBeeping = false;
  bool isSwapped = false;
  String inputText = '';
  String translatedText = '';
  double frequency = 600;
  double balance = 0;
  double volume = 1;
  waveTypes waveType = waveTypes.SQUAREWAVE;
  int sampleRate = 96000;

  void _morseFlashing(String text, int interval, BuildContext context,
      MorseTransmissionCallback callback) {
    MorseTransmission().morseFlashing(text, interval, context, callback);
  }

  void _morseBeeping(
      String text,
      int interval,
      BuildContext context,
      double frequency,
      double balance,
      double volume,
      waveTypes waveType,
      MorseTransmissionCallback callback) {
    MorseTransmission().morseBeeping(text, interval, context, frequency,
        balance, volume, waveType, callback);
  }

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
                icon: SharedVariables.isMorseFlashing
                    ? Icons.stop
                    : Icons.highlight,
                onPressed: () {
                  setState(() {
                    SharedVariables.isMorseFlashing =
                        !SharedVariables.isMorseFlashing;
                  });
                  if (isSwapped) {
                    _morseFlashing(
                      inputText,
                      SharedVariables.morseInterval,
                      context,
                      (success) {
                        setState(() {
                          if (success) {
                            SharedVariables.isMorseFlashing = false;
                          }
                        });
                      },
                    );
                  } else {
                    _morseFlashing(
                      translatedText,
                      SharedVariables.morseInterval,
                      context,
                      (success) {
                        setState(() {
                          if (success) {
                            SharedVariables.isMorseFlashing = false;
                          }
                        });
                      },
                    );
                  }
                },
              ),
              const SizedBox(width: 16.0),
              _buildIconButton(
                icon: SharedVariables.isMorseBeeping
                    ? Icons.stop
                    : Icons.volume_up,
                onPressed: () {
                  setState(() {
                    SharedVariables.isMorseBeeping =
                        !SharedVariables.isMorseBeeping;
                  });
                  if (isSwapped) {
                    _morseBeeping(
                      inputText,
                      SharedVariables.morseInterval,
                      context, frequency, balance, volume, waveType,
                      (success) {
                        setState(() {
                          if (success) {
                            SharedVariables.isMorseBeeping = false;
                          }
                        });
                      },
                    );
                  } else {
                    _morseBeeping(
                      translatedText,
                      SharedVariables.morseInterval,
                      context, frequency, balance, volume, waveType,
                          (success) {
                        setState(() {
                          if (success) {
                            SharedVariables.isMorseBeeping = false;
                          }
                        });
                      },
                    );
                  }
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

  @override
  void initState() {
    super.initState();
    SoundGenerator.init(sampleRate);
  }
}
