import 'dart:io';
import 'dart:convert';

import '../../features/terminal/models/terminal_theme_data.dart';

/// Service to manage user configuration folder at ~/.flutter-agent-panel/
class UserConfigService {
  static final UserConfigService _instance = UserConfigService._();
  static UserConfigService get instance => _instance;

  UserConfigService._();

  String? _configPath;

  /// Get the path to the user config folder (~/.flutter-agent-panel/)
  String get configPath {
    if (_configPath != null) return _configPath!;

    final home = Platform.environment['USERPROFILE'] ?? // Windows
        Platform.environment['HOME']; // macOS/Linux

    if (home == null) {
      throw Exception('Unable to determine user home directory');
    }

    _configPath = '$home/.flutter-agent-panel';
    return _configPath!;
  }

  /// Get the path to the themes folder
  String get themesPath => '$configPath/themes';

  /// Get the path to the dark themes folder
  String get darkThemesPath => '$themesPath/dark';

  /// Get the path to the light themes folder
  String get lightThemesPath => '$themesPath/light';

  /// Get the path to the schema folder
  String get schemaPath => '$configPath/schema';

  /// Ensure all required directories exist
  Future<void> ensureDirectoriesExist() async {
    final directories = [
      configPath,
      themesPath,
      darkThemesPath,
      lightThemesPath,
      schemaPath,
    ];

    for (final dir in directories) {
      final directory = Directory(dir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        print('Created directory: $dir');
      }
    }

    // Copy schema file if not exists
    await _copySchemaIfNeeded();
  }

  /// Copy the JSON schema file to the user config folder
  Future<void> _copySchemaIfNeeded() async {
    final schemaFile = File('$schemaPath/theme.schema.json');
    if (!await schemaFile.exists()) {
      const schemaContent = '''
{
  "\$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Terminal Theme",
  "description": "A terminal color theme for Flutter Agent Panel",
  "type": "object",
  "required": ["name", "background", "foreground", "cursorColor"],
  "properties": {
    "name": {
      "type": "string",
      "description": "The display name of the theme"
    },
    "black": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "ANSI black color"
    },
    "red": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "ANSI red color"
    },
    "green": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "ANSI green color"
    },
    "yellow": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "ANSI yellow color"
    },
    "blue": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "ANSI blue color"
    },
    "purple": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "ANSI purple/magenta color"
    },
    "cyan": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "ANSI cyan color"
    },
    "white": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "ANSI white color"
    },
    "brightBlack": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "ANSI bright black color"
    },
    "brightRed": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "ANSI bright red color"
    },
    "brightGreen": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "ANSI bright green color"
    },
    "brightYellow": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "ANSI bright yellow color"
    },
    "brightBlue": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "ANSI bright blue color"
    },
    "brightPurple": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "ANSI bright purple/magenta color"
    },
    "brightCyan": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "ANSI bright cyan color"
    },
    "brightWhite": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "ANSI bright white color"
    },
    "background": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "Terminal background color"
    },
    "foreground": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "Terminal foreground/text color"
    },
    "selectionBackground": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "Text selection background color"
    },
    "cursorColor": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}\$",
      "description": "Cursor color"
    }
  }
}
''';
      await schemaFile.writeAsString(schemaContent);
      print('Created schema file: ${schemaFile.path}');
    }
  }

  /// Load user themes from the specified folder (dark or light)
  Future<List<TerminalThemeData>> loadUserThemes(String type) async {
    final themes = <TerminalThemeData>[];
    final themePath = type == 'dark' ? darkThemesPath : lightThemesPath;
    final directory = Directory(themePath);

    if (!await directory.exists()) {
      return themes;
    }

    try {
      final files = directory.listSync().whereType<File>().where(
            (f) => f.path.endsWith('.json'),
          );

      for (final file in files) {
        try {
          final content = await file.readAsString();
          final json = jsonDecode(content) as Map<String, dynamic>;
          final theme = TerminalThemeData.fromJson(json);
          themes.add(theme);
          print('Loaded user theme: ${theme.name} from ${file.path}');
        } catch (e) {
          print('Error loading user theme ${file.path}: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error scanning user themes directory: $e');
    }

    return themes;
  }

  /// Get the path to the settings file
  String get settingsFilePath => '$configPath/settings.json';

  /// Save a custom theme to the user folder
  /// Returns the saved file path, or null if failed
  Future<String?> saveCustomTheme(String jsonContent, bool isDark) async {
    try {
      final json = jsonDecode(jsonContent) as Map<String, dynamic>;
      final themeName = json['name'] as String?;

      if (themeName == null || themeName.isEmpty) {
        print('Error: Theme name is missing');
        return null;
      }

      // Generate filename from theme name
      final filename = themeName
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '-')
          .replaceAll(RegExp(r'-+'), '-');

      final themePath = isDark ? darkThemesPath : lightThemesPath;
      final filePath = '$themePath/$filename.json';

      // Format JSON nicely
      final encoder = JsonEncoder.withIndent('  ');
      final formattedJson = encoder.convert(json);

      await File(filePath).writeAsString(formattedJson);
      print('Saved custom theme to: $filePath');

      return filePath;
    } catch (e) {
      print('Error saving custom theme: $e');
      return null;
    }
  }

  /// Load settings from settings.json
  Future<Map<String, dynamic>?> loadSettingsFromFile() async {
    try {
      final file = File(settingsFilePath);
      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      print('Error loading settings: $e');
      return null;
    }
  }

  /// Save settings to settings.json
  Future<bool> saveSettingsToFile(Map<String, dynamic> settings) async {
    try {
      final file = File(settingsFilePath);
      final encoder = JsonEncoder.withIndent('  ');
      final formattedJson = encoder.convert(settings);
      await file.writeAsString(formattedJson);
      return true;
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }

  /// Open the settings file in the system default editor
  Future<bool> openSettingsFile() async {
    try {
      final file = File(settingsFilePath);

      // Create default settings file if not exists
      if (!await file.exists()) {
        await saveSettingsToFile({
          '_comment': 'Flutter Agent Panel Settings',
          'appTheme': 'dark',
          'terminalThemeName': 'DefaultDark',
          'locale': 'en',
        });
      }

      // Open file with system default application
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', settingsFilePath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [settingsFilePath]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [settingsFilePath]);
      }

      return true;
    } catch (e) {
      print('Error opening settings file: $e');
      return false;
    }
  }
}
