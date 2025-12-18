import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/base_viewmodel.dart';

class ThemeViewModel extends BaseViewModel {
  static final ThemeViewModel _instance = ThemeViewModel._internal();
  factory ThemeViewModel() => _instance;
  ThemeViewModel._internal() {
    _loadTheme();
  }

  final _themeMode = signal<ThemeMode>(ThemeMode.system);
  ReadonlySignal<ThemeMode> get themeMode => _themeMode;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_mode');
    if (themeString != null) {
      _themeMode.value = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeString,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString());
  }
}
