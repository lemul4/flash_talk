class MorseDictionary {
  static const Map<String, String> _rusToMorse = {
    'А': '.-',
    'Б': '-...',
    'В': '.--',
    'Г': '--.',
    'Д': '-..',
    'Ё': '.',
    'Е': '.',
    'Ж': '...-',
    'З': '--..',
    'И': '..',
    'Й': '.---',
    'К': '-.-',
    'Л': '.-..',
    'М': '--',
    'Н': '-.',
    'О': '---',
    'П': '.--.',
    'Р': '.-.',
    'С': '...',
    'Т': '-',
    'У': '..-',
    'Ф': '..-.',
    'Х': '....',
    'Ц': '-.-.',
    'Ч': '---.',
    'Ш': '----',
    'Щ': '--.-',
    'Ъ': '--.--',
    'Ы': '-.--',
    'Ь': '-..-',
    'Э': '..-..',
    'Ю': '..--',
    'Я': '.-.-',
    '0': '-----',
    '1': '.----',
    '2': '..---',
    '3': '...--',
    '4': '....-',
    '5': '.....',
    '6': '-....',
    '7': '--...',
    '8': '---..',
    '9': '----.',
    ' ': '/',
  };
  static const Map<String, String> _engToMorse = {
    'A': '.-',
    'B': '-...',
    'C': '-.-.',
    'D': '-..',
    'E': '.',
    'F': '..-.',
    'G': '--.',
    'H': '....',
    'I': '..',
    'J': '.---',
    'K': '-.-',
    'L': '.-..',
    'M': '--',
    'N': '-.',
    'O': '---',
    'P': '.--.',
    'Q': '--.-',
    'R': '.-.',
    'S': '...',
    'T': '-',
    'U': '..-',
    'V': '...-',
    'W': '.--',
    'X': '-..-',
    'Y': '-.--',
    'Z': '--..',
    '0': '-----',
    '1': '.----',
    '2': '..---',
    '3': '...--',
    '4': '....-',
    '5': '.....',
    '6': '-....',
    '7': '--...',
    '8': '---..',
    '9': '----.',
    ' ': '/',
  };
  static final Map<String, String> _morseToRus = Map.fromEntries(
      _rusToMorse.entries.map((entry) => MapEntry(entry.value, entry.key)));

  static final Map<String, String> _morseToEng = Map.fromEntries(
      _engToMorse.entries.map((entry) => MapEntry(entry.value, entry.key)));

  static Map<String, String> getMorseMap(String language) {
    switch (language.toLowerCase()) {
      case 'русский':
        return _rusToMorse;
      case 'английский':
        return _engToMorse;
      default:
        throw ArgumentError('Unsupported language: $language');
    }
  }

  static Map<String, String> getMorseToLanguageMap(String language) {
    switch (language.toLowerCase()) {
      case 'русский':
        return _morseToRus;
      case 'английский':
        return _morseToEng;
      default:
        throw ArgumentError('Unsupported language: $language');
    }
  }
}
