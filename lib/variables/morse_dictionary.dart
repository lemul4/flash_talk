abstract class MorseLanguage {
  Map<String, String> getMorseMap();
  Map<String, String> getMorseToLanguageMap();
}

class MorseDictionary {
  static final Map<String, MorseLanguage> _languages = {
    'русский': RussianMorseLanguage(),
    'английский': EnglishMorseLanguage(),
  };

  static MorseLanguage getLanguage(String language) {
    final MorseLanguage? selectedLanguage = _languages[language.toLowerCase()];
    if (selectedLanguage == null) {
      throw ArgumentError('Unsupported language: $language');
    }
    return selectedLanguage;
  }
}

class RussianMorseLanguage implements MorseLanguage {
  @override
  Map<String, String> getMorseMap() => {
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

  @override
  Map<String, String> getMorseToLanguageMap() =>
      Map.fromEntries(getMorseMap().entries.map((entry) =>
          MapEntry(entry.value, entry.key)));

}

class EnglishMorseLanguage implements MorseLanguage {
  @override
  Map<String, String> getMorseMap() => {
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

  @override
  Map<String, String> getMorseToLanguageMap() =>
      Map.fromEntries(getMorseMap().entries.map((entry) =>
          MapEntry(entry.value, entry.key)));

}


