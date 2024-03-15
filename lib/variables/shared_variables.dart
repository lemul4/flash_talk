class SharedVariables {
  static int _currentLanguageIndex = 0;
  static int _morseInterval = 500;
  static String _selectedLanguage = 'Русский';

  static int get currentIndex => _currentLanguageIndex;
  static set currentIndex(int index) => _currentLanguageIndex = index;

  static int get morseInterval => _morseInterval;
  static set morseInterval(int index) => _morseInterval = index;

  static String get selectedLanguage => _selectedLanguage;
  static set selectedLanguage(String language) => _selectedLanguage = language;
}


