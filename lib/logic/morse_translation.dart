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
    List<String> morseChars = text.split(' ');
    List<String> translatedChars = [];

    for (String morseChar in morseChars) {
      translatedChars
          .add(MorseDictionary.getMorseToLanguageMap(language)[morseChar] ?? "");
    }
    return translatedChars.join('');
  }

  static String translateToMorse(String text, String language) {
    text = text.toUpperCase();
    List<String> morseList = [];
    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      if (MorseDictionary.getMorseMap(language).containsKey(char)) {
        morseList.add(MorseDictionary.getMorseMap(language)[char]!);
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