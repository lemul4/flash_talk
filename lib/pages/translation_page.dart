import 'package:flash_talk/variables/shared_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'dart:async';
import 'package:flash_talk/logic/morse_translation.dart';
import 'package:provider/provider.dart';
import 'package:sound_generator/sound_generator.dart';
import 'package:sound_generator/waveTypes.dart';
import 'package:flash_talk/logic/morse_transmission.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../logic/theme_provider.dart';

@RoutePage()
class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  bool isListening = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final MorseTransmitter beeping = MorseBeeping();
  final MorseTransmitter flashing = MorseFlashing();

  final inputText = TextEditingController();

  @override
  void initState() {
    super.initState();
    SoundGenerator.init(sampleRate);
    SoundGenerator.setFrequency(SharedVariables.frequency);
    SoundGenerator.setBalance(balance);
    SoundGenerator.setVolume(volume);
    SoundGenerator.setWaveType(waveType);
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    flashing.isTransmitting.value = false;
    beeping.isTransmitting.value = false;
    _animationController.dispose();
    flashing.dispose();
    beeping.dispose();
    super.dispose();
  }

  bool isSwapped = false;
  String translatedText = '';
  double balance = 0;
  double volume = 1;
  waveTypes waveType = waveTypes.SINUSOIDAL;
  int sampleRate = 44100;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SharedVariables.currentIndex,
      builder: (context, value, child) {
        if (value != 0) {
          flashing.isTransmitting.value = false;
          beeping.isTransmitting.value = false;
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Перевод'),
            automaticallyImplyLeading: false,
          ),
          body: buildTranslationBody(),
        );
      },
    );
  }

  Widget buildTranslationBody() {
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Column(
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
                        inputText.text = '';
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
                      if (isSwapped) {
                        translatedText = MorseTranslation.translateFromMorse(
                            text, SharedVariables.selectedLanguage);
                      } else {
                        translatedText = MorseTranslation.translateToMorse(
                            text, SharedVariables.selectedLanguage);
                      }
                    });
                  },
                  maxLines: null,
                  expands: true,
                  controller: inputText,
                  style: const TextStyle(fontSize: 18.0),
                  decoration: InputDecoration(
                    hintText: 'Введите текст',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          inputText.clear();
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
                    color: themeProvider.isDarkTheme
                        ? Colors.grey[800]
                        : Colors.grey[700],
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
                            style: const TextStyle(
                                fontSize: 18.0, color: Colors.white),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: translatedText));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Текст скопирован в буфер обмена'),
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
                      icon: Icons.volume_up,
                      onPressed: () {
                        SoundGenerator.setFrequency(SharedVariables.frequency);
                        SoundGenerator.setWaveType(waveType);
                        SoundGenerator.setBalance(balance);
                        SoundGenerator.setVolume(volume);
                        if (isSwapped) {
                          beeping.transmit(inputText.text,
                              SharedVariables.morseInterval, context);
                        } else {
                          beeping.transmit(translatedText,
                              SharedVariables.morseInterval, context);
                        }
                      },
                      valueListenable: beeping.isTransmitting),
                  const SizedBox(width: 16.0),
                  _buildIconButton(
                      icon: Icons.highlight,
                      onPressed: () {
                        if (isSwapped) {
                          flashing.transmit(
                            inputText.text,
                            SharedVariables.morseInterval,
                            context,
                          );
                        } else {
                          flashing.transmit(
                            translatedText,
                            SharedVariables.morseInterval,
                            context,
                          );
                        }
                      },
                      valueListenable: flashing.isTransmitting),
                ],
              ),
              const SizedBox(height: 58.0),
            ],
          ),
          Positioned(
              bottom: 58,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTapUp: (details) {
                    setState(() {
                      isListening = false;
                    });
                    _animationController.stop();
                    _animationController.reset();
                    _speechToText.stop();
                  },
                  onTapDown: (details) async {
                    if (!isSwapped) {
                      if (!isListening) {
                        _animationController.repeat(reverse: true);
                        var available = await _speechToText.initialize();
                        if (available) {
                          setState(() {
                            isListening = true;
                            String localeId =
                                SharedVariables.selectedLanguage == 'Русский'
                                    ? 'ru_RU'
                                    : 'en_US';
                            _speechToText.listen(
                              onResult: (result) {
                                setState(() {
                                  inputText.text = result.recognizedWords;
                                  translatedText =
                                      MorseTranslation.translateToMorse(
                                          inputText.text,
                                          SharedVariables.selectedLanguage);
                                });
                              },
                              localeId: localeId,
                            );
                          });
                        } else {
                          setState(() {
                            isListening = false;
                          });
                        }
                      }
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: backgroundColor,
                            width: 10.0 + _animation.value / 4,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 35.0 + _animation.value,
                          backgroundColor: themeProvider.isDarkTheme
                              ? Colors.white
                              : Colors.grey[900],
                          child: Icon(
                            isListening ? Icons.mic : Icons.mic_off,
                            color: backgroundColor,
                            size: 40.0 + _animation.value,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(String language) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Expanded(
      child: InkWell(
        onTap: () {
          _showLanguagePicker(context);
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(
                color: themeProvider.isDarkTheme
                    ? Colors.white
                    : Colors.grey[800]!),
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

  Widget _buildIconButton(
      {required IconData icon,
      required VoidCallback onPressed,
      required valueListenable}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ValueListenableBuilder<bool>(
      valueListenable: valueListenable,
      builder: (context, value, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(
                    color: themeProvider.isDarkTheme
                        ? Colors.white
                        : Colors.grey[800]!),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                value ? Icons.stop : icon,
                color: themeProvider.isDarkTheme
                    ? Colors.white
                    : Colors.grey[800]!,
              ),
            ),
          ),
        );
      },
    );
  }
}
