import 'package:flash_talk/variables/morse_dictionary.dart';

class MorseTranslation {
  static String translateFromMorse(String text, String language) {
    text = text
        .replaceAll('▬', '-')
        .replaceAll('—', '-')
        .replaceAll('―', '-')
        .replaceAll('_', '-')
        .replaceAll('●', '.')
        .replaceAll('•', '.');

    final MorseLanguage selectedLanguage = MorseDictionary.getLanguage(language);
    List<String> morseChars = text.split(' ');
    List<String> translatedChars = [];

    for (String morseChar in morseChars) {
      translatedChars
          .add(selectedLanguage.getMorseToLanguageMap()[morseChar] ?? "");
    }
    return translatedChars.join('');
  }

  static String translateToMorse(String text, String language) {
    text = text.toUpperCase();
    final MorseLanguage selectedLanguage = MorseDictionary.getLanguage(language);
    List<String> morseList = [];
    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      if (selectedLanguage.getMorseMap().containsKey(char)) {
        morseList.add(selectedLanguage.getMorseMap()[char]!);
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
