import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Terminal font configuration settings
class TerminalFontSettings extends Equatable {
  final String fontFamily;
  final double fontSize;
  final bool isBold;
  final bool isItalic;

  const TerminalFontSettings({
    this.fontFamily = 'Cascadia Code',
    this.fontSize = 14.0,
    this.isBold = false,
    this.isItalic = false,
  });

  TerminalFontSettings copyWith({
    String? fontFamily,
    double? fontSize,
    bool? isBold,
    bool? isItalic,
  }) {
    return TerminalFontSettings(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
    );
  }

  factory TerminalFontSettings.fromJson(Map<String, dynamic> json) {
    return TerminalFontSettings(
      fontFamily: json['fontFamily'] as String? ?? 'Cascadia Code',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      isBold: json['isBold'] as bool? ?? false,
      isItalic: json['isItalic'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'isBold': isBold,
      'isItalic': isItalic,
    };
  }

  @override
  List<Object?> get props => [fontFamily, fontSize, isBold, isItalic];
}

/// Available app color schemes
enum AppTheme {
  dark('Dark'),
  light('Light');

  final String displayName;
  const AppTheme(this.displayName);
}

/// Shell types available for terminal creation
enum ShellType {
  pwsh7('PowerShell 7', 'pwsh', 'terminal'),
  powershell('Windows PowerShell', 'powershell', 'terminal'),
  cmd('Command Prompt', 'cmd', 'command'),
  wsl('WSL (Default)', 'wsl', 'server'),
  gitBash('Git Bash', 'C:\\Program Files\\Git\\bin\\bash.exe', 'gitBranch'),
  custom('Custom...', '', 'settings');

  final String displayName;
  final String command;
  final String icon;
  const ShellType(this.displayName, this.command, this.icon);
}

/// Custom shell configuration for user-defined shells
class CustomShellConfig extends Equatable {
  final String id;
  final String name;
  final String path;
  final String icon;

  const CustomShellConfig({
    required this.id,
    required this.name,
    required this.path,
    this.icon = 'terminal',
  });

  /// Create a new custom shell config with a generated ID
  factory CustomShellConfig.create({
    required String name,
    required String path,
    String icon = 'terminal',
  }) {
    return CustomShellConfig(
      id: const Uuid().v4(),
      name: name,
      path: path,
      icon: icon,
    );
  }

  CustomShellConfig copyWith({
    String? name,
    String? path,
    String? icon,
  }) {
    return CustomShellConfig(
      id: id,
      name: name ?? this.name,
      path: path ?? this.path,
      icon: icon ?? this.icon,
    );
  }

  factory CustomShellConfig.fromJson(Map<String, dynamic> json) {
    return CustomShellConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      icon: json['icon'] as String? ?? 'terminal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'icon': icon,
    };
  }

  @override
  List<Object?> get props => [id, name, path, icon];
}

/// Migrate old TerminalTheme enum names to new theme names.
String? _migrateTerminalThemeName(String? oldName) {
  if (oldName == null) return null;
  const migration = {
    'oneDark': 'OneDark',
    'dracula': 'Dracula',
    'monokai': 'Monokai',
    'nord': 'DefaultDark',
    'solarizedDark': 'DefaultDark',
    'githubDark': 'GithubDark',
  };
  return migration[oldName];
}

/// Application settings model
class AppSettings extends Equatable {
  final AppTheme appTheme;
  final String terminalThemeName;
  final String? customTerminalThemeJson;
  final TerminalFontSettings fontSettings;
  final ShellType defaultShell;
  final List<CustomShellConfig> customShells;
  final String? selectedCustomShellId; // ID of the selected custom shell
  final String locale;
  final bool terminalCursorBlink;

  const AppSettings({
    this.appTheme = AppTheme.dark,
    this.terminalThemeName = 'OneDark',
    this.customTerminalThemeJson,
    this.fontSettings = const TerminalFontSettings(),
    this.defaultShell = ShellType.pwsh7,
    this.customShells = const [],
    this.selectedCustomShellId,
    this.locale = 'en',
    this.terminalCursorBlink = true,
  });

  AppSettings copyWith({
    AppTheme? appTheme,
    String? terminalThemeName,
    String? customTerminalThemeJson,
    bool clearCustomTerminalThemeJson = false,
    TerminalFontSettings? fontSettings,
    ShellType? defaultShell,
    List<CustomShellConfig>? customShells,
    String? selectedCustomShellId,
    bool clearSelectedCustomShellId = false,
    String? locale,
    bool? terminalCursorBlink,
  }) {
    return AppSettings(
      appTheme: appTheme ?? this.appTheme,
      terminalThemeName: terminalThemeName ?? this.terminalThemeName,
      customTerminalThemeJson: clearCustomTerminalThemeJson
          ? null
          : (customTerminalThemeJson ?? this.customTerminalThemeJson),
      fontSettings: fontSettings ?? this.fontSettings,
      defaultShell: defaultShell ?? this.defaultShell,
      customShells: customShells ?? this.customShells,
      selectedCustomShellId: clearSelectedCustomShellId
          ? null
          : (selectedCustomShellId ?? this.selectedCustomShellId),
      locale: locale ?? this.locale,
      terminalCursorBlink: terminalCursorBlink ?? this.terminalCursorBlink,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    // Handle migration from old customShellPath to new customShells list
    List<CustomShellConfig> customShells = [];
    if (json['customShells'] != null) {
      customShells = (json['customShells'] as List)
          .map((e) => CustomShellConfig.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['customShellPath'] != null &&
        (json['customShellPath'] as String).isNotEmpty) {
      // Migrate old single custom shell path to new format
      customShells = [
        CustomShellConfig.create(
          name: 'Custom Shell',
          path: json['customShellPath'] as String,
        ),
      ];
    }

    return AppSettings(
      appTheme: AppTheme.values.firstWhere(
        (e) => e.name == json['appTheme'],
        orElse: () => AppTheme.dark,
      ),
      terminalThemeName:
          _migrateTerminalThemeName(json['terminalTheme'] as String?) ??
              (json['terminalThemeName'] as String? ?? 'OneDark'),
      customTerminalThemeJson: json['customTerminalThemeJson'] as String?,
      fontSettings: json['fontSettings'] != null
          ? TerminalFontSettings.fromJson(json['fontSettings'])
          : const TerminalFontSettings(),
      defaultShell: ShellType.values.firstWhere(
        (e) => e.name == json['defaultShell'],
        orElse: () => ShellType.pwsh7,
      ),
      customShells: customShells,
      selectedCustomShellId: json['selectedCustomShellId'] as String?,
      locale: json['locale'] as String? ?? 'en',
      terminalCursorBlink: json['terminalCursorBlink'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appTheme': appTheme.name,
      'terminalThemeName': terminalThemeName,
      'customTerminalThemeJson': customTerminalThemeJson,
      'fontSettings': fontSettings.toJson(),
      'defaultShell': defaultShell.name,
      'customShells': customShells.map((e) => e.toJson()).toList(),
      'selectedCustomShellId': selectedCustomShellId,
      'locale': locale,
      'terminalCursorBlink': terminalCursorBlink,
    };
  }

  /// Get the selected custom shell config (if any)
  CustomShellConfig? get selectedCustomShell {
    if (defaultShell != ShellType.custom || selectedCustomShellId == null) {
      return null;
    }
    try {
      return customShells.firstWhere((s) => s.id == selectedCustomShellId);
    } catch (_) {
      return customShells.isNotEmpty ? customShells.first : null;
    }
  }

  /// Get the shell command to execute
  String get shellCommand {
    if (defaultShell == ShellType.custom) {
      final customShell = selectedCustomShell;
      if (customShell != null) {
        return customShell.path;
      }
    }
    return defaultShell.command;
  }

  @override
  List<Object?> get props => [
        appTheme,
        terminalThemeName,
        customTerminalThemeJson,
        fontSettings,
        defaultShell,
        customShells,
        selectedCustomShellId,
        locale,
        terminalCursorBlink,
      ];
}
