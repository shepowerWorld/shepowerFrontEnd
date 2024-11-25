import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

class LanguageProvider extends ChangeNotifier {
  final GoogleTranslator translator = GoogleTranslator();
  late SharedPreferences _prefs;

  String _selectedLanguage = 'en';

  String get selectedLanguage => _selectedLanguage;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _selectedLanguage = _prefs.getString('selectedLanguage') ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _selectedLanguage = languageCode;
    await _prefs.setString('selectedLanguage', languageCode);
    notifyListeners();
  }

  Future<String> translate(String text) async {
    final translation = await translator.translate(
      text,
      from: 'en',
      to: _selectedLanguage,
    );
    return translation.text;
  }
}

class Languages {
  Map<String, String> languageCodeMapping = {
    'Arabic': 'ar',
    'Amharic': 'am',
    'Bengali': 'bn',
    'Belarusian': 'be',
    'Gujarati': 'gu',
    'Japanese': 'ja',
    'Kannada': 'kn',
    'Myanmar': 'uk',
    'Russian': 'ru',
    'Serbian': 'sr',
    'Tamil': 'ta',
    'Telugu': 'te',
    'Marathi': 'ma',
    'Hindi': 'hi',
    'Ukrainian': 'uk',
    'Bangla': 'ba',
    'English': 'en'
  };
}
