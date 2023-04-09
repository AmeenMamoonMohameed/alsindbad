import 'package:flutter/material.dart';

class AppLanguage {
  ///Default Language
  static const Locale defaultLanguage = Locale("ar");

  ///List Language support in Application
  static final List<Locale> supportLanguage = [
    const Locale("ar"),
    const Locale("en"),
  ];

  ///Get Language Global Language Name
  static String getGlobalLanguageName(String code) {
    switch (code) {
      case 'ar':
        return 'عربي';
      case 'en':
        return 'English';
      default:
        return 'Unknown';
    }
  }

  ///isRTL layout
  static bool isRTL() {
    switch (AppLanguage.defaultLanguage.languageCode) {
      case "ar":
      case "he":
        return true;
      default:
        return false;
    }
  }

  ///Singleton factory
  static final AppLanguage _instance = AppLanguage._internal();

  factory AppLanguage() {
    return _instance;
  }

  AppLanguage._internal();
}
