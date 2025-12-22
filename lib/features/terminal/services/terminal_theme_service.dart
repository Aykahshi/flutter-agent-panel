import 'dart:convert';

import '../../../core/services/user_config_service.dart';
import '../models/built_in_themes.dart';
import '../models/terminal_theme_data.dart';

/// Service to load terminal themes.
class TerminalThemeService {
  static final TerminalThemeService _instance = TerminalThemeService._();
  static TerminalThemeService get instance => _instance;

  TerminalThemeService._();

  List<TerminalThemeData>? _darkThemes;
  List<TerminalThemeData>? _lightThemes;

  /// Get all dark themes (built-in + user themes).
  Future<List<TerminalThemeData>> getDarkThemes() async {
    if (_darkThemes != null) return _darkThemes!;

    // Load user themes
    final userThemes = await UserConfigService.instance.loadUserThemes('dark');

    // Merge: built-in first, user themes can override by name
    final mergedThemes = <String, TerminalThemeData>{};
    for (final theme in builtInDarkThemes) {
      mergedThemes[theme.name] = theme;
    }
    for (final theme in userThemes) {
      mergedThemes[theme.name] = theme; // Override if same name
    }

    _darkThemes = mergedThemes.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return _darkThemes!;
  }

  /// Get all light themes (built-in + user themes).
  Future<List<TerminalThemeData>> getLightThemes() async {
    if (_lightThemes != null) return _lightThemes!;

    // Load user themes
    final userThemes = await UserConfigService.instance.loadUserThemes('light');

    // Merge: built-in first, user themes can override by name
    final mergedThemes = <String, TerminalThemeData>{};
    for (final theme in builtInLightThemes) {
      mergedThemes[theme.name] = theme;
    }
    for (final theme in userThemes) {
      mergedThemes[theme.name] = theme; // Override if same name
    }

    _lightThemes = mergedThemes.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return _lightThemes!;
  }

  /// Get a theme by name, searching both dark and light themes.
  Future<TerminalThemeData?> getThemeByName(String name) async {
    final darkThemes = await getDarkThemes();
    final lightThemes = await getLightThemes();

    for (final theme in [...darkThemes, ...lightThemes]) {
      if (theme.name == name) return theme;
    }
    return null;
  }

  /// Get a dark theme by name.
  Future<TerminalThemeData?> getDarkThemeByName(String name) async {
    final themes = await getDarkThemes();
    for (final theme in themes) {
      if (theme.name == name) return theme;
    }
    return null;
  }

  /// Get a light theme by name.
  Future<TerminalThemeData?> getLightThemeByName(String name) async {
    final themes = await getLightThemes();
    for (final theme in themes) {
      if (theme.name == name) return theme;
    }
    return null;
  }

  /// Get the default dark theme.
  Future<TerminalThemeData> getDefaultDarkTheme() async {
    final themes = await getDarkThemes();
    return themes.firstWhere(
      (t) => t.name == 'DefaultDark',
      orElse: () => themes.first,
    );
  }

  /// Get the default light theme.
  Future<TerminalThemeData> getDefaultLightTheme() async {
    final themes = await getLightThemes();
    return themes.firstWhere(
      (t) => t.name == 'DefaultLight',
      orElse: () => themes.first,
    );
  }

  /// Parse a custom JSON string into a TerminalThemeData.
  /// Returns null if parsing fails.
  TerminalThemeData? parseCustomTheme(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return TerminalThemeData.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Validate a custom JSON string.
  /// Returns null if valid, or a record with (errorType, details) if invalid.
  /// errorType: 'jsonMustBeObject', 'missingRequiredField', 'invalidJson', 'errorParsingTheme'
  (String errorType, String? details)? validateCustomThemeJson(
      String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      if (json is! Map<String, dynamic>) {
        return ('jsonMustBeObject', null);
      }
      // Check required fields
      final requiredFields = [
        'background',
        'foreground',
        'cursorColor',
      ];
      for (final field in requiredFields) {
        if (!json.containsKey(field)) {
          return ('missingRequiredField', field);
        }
      }
      // Try to parse it
      TerminalThemeData.fromJson(json);
      return null;
    } on FormatException catch (e) {
      return ('invalidJson', e.message);
    } catch (e) {
      return ('errorParsingTheme', e.toString());
    }
  }

  /// Clear cached themes (useful for testing or hot reload).
  void clearCache() {
    _darkThemes = null;
    _lightThemes = null;
  }
}
