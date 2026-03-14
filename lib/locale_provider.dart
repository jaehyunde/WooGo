// locale_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  // 생성자: 클래스가 만들어질 때 저장된 언어를 불러옵니다.
  LocaleProvider() {
    _loadLocale();
  }

  // 1. 언어 설정 저장하기
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();

    // 기기에 'language_code'라는 키로 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  // 2. 저장된 언어 불러오기
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');

    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners(); // 불러온 뒤 화면을 다시 그리게 함
    }
  }

  // 언어 초기화 (시스템 설정으로)
  Future<void> clearLocale() async {
    _locale = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('language_code');
  }
}