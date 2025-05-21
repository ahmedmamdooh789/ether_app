import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  // Singleton pattern implementation
  static final LanguageService _instance = LanguageService._internal();
  
  factory LanguageService() {
    return _instance;
  }
  
  LanguageService._internal();
  
  // Current locale
  Locale _currentLocale = const Locale('en', 'US');
  
  // Getter for current locale
  Locale get currentLocale => _currentLocale;
  
  // Available languages
  final List<Map<String, dynamic>> languages = [
    {
      'name': 'English',
      'locale': const Locale('en', 'US'),
      'code': 'en',
    },
    {
      'name': 'العربية',
      'locale': const Locale('ar', 'EG'),
      'code': 'ar',
    },
  ];
  
  // Initialize language from preferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');
    
    if (languageCode != null) {
      if (languageCode == 'ar') {
        _currentLocale = const Locale('ar', 'EG');
      } else {
        _currentLocale = const Locale('en', 'US');
      }
    }
  }
  
  // Change language
  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    
    if (languageCode == 'ar') {
      _currentLocale = const Locale('ar', 'EG');
    } else {
      _currentLocale = const Locale('en', 'US');
    }
  }
  
  // Get current language name
  String getCurrentLanguageName() {
    for (var language in languages) {
      if (language['code'] == _currentLocale.languageCode) {
        return language['name'];
      }
    }
    return 'English'; // Default
  }
}
