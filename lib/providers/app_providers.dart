import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider para el tema de la aplicación
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

// Provider para el idioma de la aplicación
final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _themeKey = 'app_theme';

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system; // Default
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_themeKey);

      if (themeString != null) {
        final themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeString,
          orElse: () => ThemeMode.system,
        );
        state = themeMode;
      }
    } catch (e) {
      print('Error loading theme: $e');
    }
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeMode.toString());
      state = themeMode;
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  String getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Automático';
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
    }
  }

  IconData getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }
}

class LocaleNotifier extends Notifier<Locale?> {
  static const String _localeKey = 'app_locale';

  @override
  Locale? build() {
    _loadLocale();
    return null; // Default (system locale)
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeString = prefs.getString(_localeKey);

      if (localeString != null) {
        final localeData = json.decode(localeString);
        final locale = Locale(
          localeData['languageCode'],
          localeData['countryCode'],
        );
        state = locale;
      }
    } catch (e) {
      print('Error loading locale: $e');
    }
  }

  Future<void> setLocale(Locale? locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (locale != null) {
        final localeData = {
          'languageCode': locale.languageCode,
          'countryCode': locale.countryCode,
        };
        await prefs.setString(_localeKey, json.encode(localeData));
      } else {
        await prefs.remove(_localeKey);
      }

      state = locale;
    } catch (e) {
      print('Error saving locale: $e');
    }
  }

  String getLanguageLabel(Locale? locale) {
    if (locale == null) return 'Automático';

    switch (locale.languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  String getLanguageFlag(Locale? locale) {
    if (locale == null) return '🌐';

    switch (locale.languageCode) {
      case 'es':
        return '🇪🇸';
      case 'en':
        return '🇺🇸';
      default:
        return '🌐';
    }
  }

  List<Locale?> get supportedLocales => [
    null, // System default
    const Locale('es', 'ES'),
    const Locale('en', 'US'),
  ];
}
