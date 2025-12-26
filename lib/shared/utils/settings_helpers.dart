import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/l10n/app_localizations.dart';
import '../../features/settings/models/app_settings.dart';

/// Get localized name for app theme
String getAppThemeLocalizedName(AppTheme theme, AppLocalizations l10n) =>
    switch (theme) {
      AppTheme.dark => l10n.dark,
      AppTheme.light => l10n.light,
    };

/// Get localized name for shell type
String getShellTypeLocalizedName(ShellType shell, AppLocalizations l10n) =>
    switch (shell) {
      ShellType.pwsh7 => l10n.pwsh7,
      ShellType.powershell => l10n.powershell,
      ShellType.cmd => l10n.cmd,
      ShellType.wsl => l10n.wsl,
      ShellType.gitBash => l10n.gitBash,
      ShellType.custom => l10n.custom,
    };

/// Get icon for shell type
IconData getShellIcon(String iconName) => switch (iconName) {
      'terminal' => LucideIcons.terminal,
      'command' => LucideIcons.squareTerminal,
      'server' => LucideIcons.server,
      'gitBranch' => LucideIcons.gitBranch,
      'settings' => LucideIcons.settings,
      _ => LucideIcons.terminal,
    };

/// Get color for agent preset
Color? getAgentColor(AgentPreset preset) => switch (preset) {
      AgentPreset.claude => const Color(0xFFD97757),
      AgentPreset.qwen => const Color(0xFF615CED),
      AgentPreset.codex => const Color(0xFF10A37F),
      AgentPreset.gemini => const Color(0xFF4E87F6),
      AgentPreset.opencode => Colors.blueGrey,
      _ => null,
    };
