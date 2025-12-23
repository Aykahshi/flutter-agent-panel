import 'package:equatable/equatable.dart';

import 'app_theme.dart';
import 'custom_shell_config.dart';
import 'shell_type.dart';
import 'terminal_font_settings.dart';
import 'agent_config.dart';

// Re-export for backwards compatibility
export 'app_theme.dart';
export 'custom_shell_config.dart';
export 'shell_type.dart';
export 'terminal_font_settings.dart';
export 'agent_config.dart';

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
    this.agents = const [],
  });

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
      agents: _mergeWithDefaults(json['agents'] as List?),
    );
  }
  final AppTheme appTheme;
  final String terminalThemeName;
  final String? customTerminalThemeJson;
  final TerminalFontSettings fontSettings;
  final ShellType defaultShell;
  final List<CustomShellConfig> customShells;
  final String? selectedCustomShellId; // ID of the selected custom shell
  final String locale;
  final bool terminalCursorBlink;
  final List<AgentConfig> agents;

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
    List<AgentConfig>? agents,
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
      agents: agents ?? this.agents,
    );
  }

  static List<AgentConfig> _mergeWithDefaults(List<dynamic>? jsonAgents) {
    final defaults = _getDefaultAgents();
    if (jsonAgents == null) return defaults;

    final loaded = jsonAgents
        .map((e) => AgentConfig.fromJson(e as Map<String, dynamic>))
        .toList();

    // Add any default agents that are missing from the loaded list (by ID)
    final loadedIds = loaded.map((a) => a.id).toSet();
    for (final defaultAgent in defaults) {
      if (!loadedIds.contains(defaultAgent.id)) {
        loaded.add(defaultAgent);
      }
    }

    return loaded;
  }

  static List<AgentConfig> _getDefaultAgents() {
    return [
      AgentConfig(
        id: 'preset_claude',
        preset: AgentPreset.claude,
        name: AgentPreset.claude.displayName,
        command: AgentPreset.claude.defaultCommand,
      ),
      AgentConfig(
        id: 'preset_qwen',
        preset: AgentPreset.qwen,
        name: AgentPreset.qwen.displayName,
        command: AgentPreset.qwen.defaultCommand,
      ),
      AgentConfig(
        id: 'preset_codex',
        preset: AgentPreset.codex,
        name: AgentPreset.codex.displayName,
        command: AgentPreset.codex.defaultCommand,
      ),
      AgentConfig(
        id: 'preset_gemini',
        preset: AgentPreset.gemini,
        name: AgentPreset.gemini.displayName,
        command: AgentPreset.gemini.defaultCommand,
      ),
      AgentConfig(
        id: 'preset_opencode',
        preset: AgentPreset.opencode,
        name: AgentPreset.opencode.displayName,
        command: AgentPreset.opencode.defaultCommand,
      ),
      AgentConfig(
        id: 'preset_github_copilot',
        preset: AgentPreset.githubCopilot,
        name: AgentPreset.githubCopilot.displayName,
        command: AgentPreset.githubCopilot.defaultCommand,
        args: AgentPreset.githubCopilot.defaultArgs,
      ),
    ];
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
      'agents': agents.map((e) => e.toJson()).toList(),
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
        agents,
      ];
}
