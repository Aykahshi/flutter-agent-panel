import 'package:equatable/equatable.dart';

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

/// Available terminal color themes
enum TerminalTheme {
  oneDark('One Dark'),
  dracula('Dracula'),
  monokai('Monokai'),
  nord('Nord'),
  solarizedDark('Solarized Dark'),
  githubDark('GitHub Dark');

  final String displayName;
  const TerminalTheme(this.displayName);
}

/// Available app color schemes
enum AppTheme {
  slateDark('Slate Dark'),
  zincDark('Zinc Dark'),
  neutralDark('Neutral Dark'),
  stoneDark('Stone Dark'),
  grayDark('Gray Dark');

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

/// Application settings model
class AppSettings extends Equatable {
  final AppTheme appTheme;
  final TerminalTheme terminalTheme;
  final TerminalFontSettings fontSettings;
  final ShellType defaultShell;
  final String? customShellPath;
  final String locale;
  final bool terminalCursorBlink;

  const AppSettings({
    this.appTheme = AppTheme.slateDark,
    this.terminalTheme = TerminalTheme.oneDark,
    this.fontSettings = const TerminalFontSettings(),
    this.defaultShell = ShellType.pwsh7,
    this.customShellPath,
    this.locale = 'en',
    this.terminalCursorBlink = true,
  });

  AppSettings copyWith({
    AppTheme? appTheme,
    TerminalTheme? terminalTheme,
    TerminalFontSettings? fontSettings,
    ShellType? defaultShell,
    String? customShellPath,
    String? locale,
    bool? terminalCursorBlink,
  }) {
    return AppSettings(
      appTheme: appTheme ?? this.appTheme,
      terminalTheme: terminalTheme ?? this.terminalTheme,
      fontSettings: fontSettings ?? this.fontSettings,
      defaultShell: defaultShell ?? this.defaultShell,
      customShellPath: customShellPath ?? this.customShellPath,
      locale: locale ?? this.locale,
      terminalCursorBlink: terminalCursorBlink ?? this.terminalCursorBlink,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      appTheme: AppTheme.values.firstWhere(
        (e) => e.name == json['appTheme'],
        orElse: () => AppTheme.slateDark,
      ),
      terminalTheme: TerminalTheme.values.firstWhere(
        (e) => e.name == json['terminalTheme'],
        orElse: () => TerminalTheme.oneDark,
      ),
      fontSettings: json['fontSettings'] != null
          ? TerminalFontSettings.fromJson(json['fontSettings'])
          : const TerminalFontSettings(),
      defaultShell: ShellType.values.firstWhere(
        (e) => e.name == json['defaultShell'],
        orElse: () => ShellType.pwsh7,
      ),
      customShellPath: json['customShellPath'] as String?,
      locale: json['locale'] as String? ?? 'en',
      terminalCursorBlink: json['terminalCursorBlink'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appTheme': appTheme.name,
      'terminalTheme': terminalTheme.name,
      'fontSettings': fontSettings.toJson(),
      'defaultShell': defaultShell.name,
      'customShellPath': customShellPath,
      'locale': locale,
      'terminalCursorBlink': terminalCursorBlink,
    };
  }

  /// Get the shell command to execute
  String get shellCommand {
    if (defaultShell == ShellType.custom && customShellPath != null) {
      return customShellPath!;
    }
    return defaultShell.command;
  }

  @override
  List<Object?> get props => [
        appTheme,
        terminalTheme,
        fontSettings,
        defaultShell,
        customShellPath,
        locale,
        terminalCursorBlink,
      ];
}
