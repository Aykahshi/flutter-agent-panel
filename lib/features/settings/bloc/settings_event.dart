part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UpdateAppTheme extends SettingsEvent {
  const UpdateAppTheme(this.appTheme);
  final AppTheme appTheme;

  @override
  List<Object?> get props => [appTheme];
}

class UpdateTerminalTheme extends SettingsEvent {
  const UpdateTerminalTheme(this.themeName, {this.customThemeJson});
  final String themeName;
  final String? customThemeJson;

  @override
  List<Object?> get props => [themeName, customThemeJson];
}

class UpdateFontSettings extends SettingsEvent {
  const UpdateFontSettings(this.fontSettings);
  final TerminalFontSettings fontSettings;

  @override
  List<Object?> get props => [fontSettings];
}

class UpdateAppFontFamily extends SettingsEvent {
  const UpdateAppFontFamily(this.appFontFamily);
  final String? appFontFamily;

  @override
  List<Object?> get props => [appFontFamily];
}

class UpdateDefaultShell extends SettingsEvent {
  const UpdateDefaultShell(this.defaultShell, {this.selectedCustomShellId});
  final ShellType defaultShell;
  final String? selectedCustomShellId;

  @override
  List<Object?> get props => [defaultShell, selectedCustomShellId];
}

class UpdateLocale extends SettingsEvent {
  const UpdateLocale(this.locale);
  final String locale;

  @override
  List<Object?> get props => [locale];
}

class UpdateTerminalCursorBlink extends SettingsEvent {
  const UpdateTerminalCursorBlink(this.isEnabled);
  final bool isEnabled;

  @override
  List<Object?> get props => [isEnabled];
}

class AddCustomShell extends SettingsEvent {
  const AddCustomShell(this.config);
  final CustomShellConfig config;

  @override
  List<Object?> get props => [config];
}

class UpdateCustomShell extends SettingsEvent {
  const UpdateCustomShell(this.config);
  final CustomShellConfig config;

  @override
  List<Object?> get props => [config];
}

class RemoveCustomShell extends SettingsEvent {
  const RemoveCustomShell(this.shellId);
  final String shellId;

  @override
  List<Object?> get props => [shellId];
}

class SelectCustomShell extends SettingsEvent {
  const SelectCustomShell(this.shellId);
  final String shellId;

  @override
  List<Object?> get props => [shellId];
}

class UpdateAgentConfig extends SettingsEvent {
  const UpdateAgentConfig(this.config);
  final AgentConfig config;

  @override
  List<Object?> get props => [config];
}

class AddAgentConfig extends SettingsEvent {
  const AddAgentConfig(this.config);
  final AgentConfig config;

  @override
  List<Object?> get props => [config];
}

class RemoveAgentConfig extends SettingsEvent {
  const RemoveAgentConfig(this.agentId);
  final String agentId;

  @override
  List<Object?> get props => [agentId];
}

class UpdateGlobalEnvVars extends SettingsEvent {
  const UpdateGlobalEnvVars(this.envVars);
  final Map<String, String> envVars;

  @override
  List<Object?> get props => [envVars];
}
