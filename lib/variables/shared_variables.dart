class SharedVariables {
  static int _currentLanguageIndex = 0;
  static String _selectedLanguage = 'Русский';

  static int get currentIndex => _currentLanguageIndex;
  static set currentIndex(int index) => _currentLanguageIndex = index;

  static String get selectedLanguage => _selectedLanguage;
  static set selectedLanguage(String language) => _selectedLanguage = language;
}
