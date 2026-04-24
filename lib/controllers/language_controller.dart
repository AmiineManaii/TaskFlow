import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final languageControllerProvider =
    StateNotifierProvider<LanguageController, Locale>(
  (ref) => LanguageController(),
);

class LanguageController extends StateNotifier<Locale> {
  static const _prefKey = 'locale';

  LanguageController() : super(const Locale('fr')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    state = Locale(saved ?? 'fr');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }
}
