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
  final AppTheme appTheme;
  const UpdateAppTheme(this.appTheme);

  @override
  List<Object?> get props => [appTheme];
}

class UpdateTerminalTheme extends SettingsEvent {
  final TerminalTheme terminalTheme;
  const UpdateTerminalTheme(this.terminalTheme);

  @override
  List<Object?> get props => [terminalTheme];
}

class UpdateFontSettings extends SettingsEvent {
  final TerminalFontSettings fontSettings;
  const UpdateFontSettings(this.fontSettings);

  @override
  List<Object?> get props => [fontSettings];
}

class UpdateDefaultShell extends SettingsEvent {
  final ShellType defaultShell;
  final String? selectedCustomShellId;
  const UpdateDefaultShell(this.defaultShell, {this.selectedCustomShellId});

  @override
  List<Object?> get props => [defaultShell, selectedCustomShellId];
}

class UpdateLocale extends SettingsEvent {
  final String locale;
  const UpdateLocale(this.locale);

  @override
  List<Object?> get props => [locale];
}

class UpdateTerminalCursorBlink extends SettingsEvent {
  final bool isEnabled;
  const UpdateTerminalCursorBlink(this.isEnabled);

  @override
  List<Object?> get props => [isEnabled];
}

class AddCustomShell extends SettingsEvent {
  final CustomShellConfig config;
  const AddCustomShell(this.config);

  @override
  List<Object?> get props => [config];
}

class UpdateCustomShell extends SettingsEvent {
  final CustomShellConfig config;
  const UpdateCustomShell(this.config);

  @override
  List<Object?> get props => [config];
}

class RemoveCustomShell extends SettingsEvent {
  final String shellId;
  const RemoveCustomShell(this.shellId);

  @override
  List<Object?> get props => [shellId];
}

class SelectCustomShell extends SettingsEvent {
  final String shellId;
  const SelectCustomShell(this.shellId);

  @override
  List<Object?> get props => [shellId];
}
