import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/app_settings.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettings>((event, emit) {
      // HydratedBloc handles loading automatically,
      // but we can use this to trigger additional logic if needed.
    });
    on<UpdateAppTheme>(_onUpdateAppTheme);
    on<UpdateTerminalTheme>(_onUpdateTerminalTheme);
    on<UpdateFontSettings>(_onUpdateFontSettings);
    on<UpdateDefaultShell>(_onUpdateDefaultShell);
    on<UpdateLocale>(_onUpdateLocale);
    on<UpdateTerminalCursorBlink>(_onUpdateTerminalCursorBlink);
    on<AddCustomShell>(_onAddCustomShell);
    on<UpdateCustomShell>(_onUpdateCustomShell);
    on<RemoveCustomShell>(_onRemoveCustomShell);
    on<SelectCustomShell>(_onSelectCustomShell);
  }

  void _onUpdateAppTheme(UpdateAppTheme event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
        settings: state.settings.copyWith(appTheme: event.appTheme)));
  }

  void _onUpdateTerminalTheme(
      UpdateTerminalTheme event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
        settings: state.settings.copyWith(terminalTheme: event.terminalTheme)));
  }

  void _onUpdateFontSettings(
      UpdateFontSettings event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
        settings: state.settings.copyWith(fontSettings: event.fontSettings)));
  }

  void _onUpdateDefaultShell(
      UpdateDefaultShell event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
        settings: state.settings.copyWith(
      defaultShell: event.defaultShell,
      selectedCustomShellId: event.selectedCustomShellId,
      clearSelectedCustomShellId: event.defaultShell != ShellType.custom,
    )));
  }

  void _onUpdateLocale(UpdateLocale event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
        settings: state.settings.copyWith(locale: event.locale)));
  }

  void _onUpdateTerminalCursorBlink(
      UpdateTerminalCursorBlink event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
        settings:
            state.settings.copyWith(terminalCursorBlink: event.isEnabled)));
  }

  void _onAddCustomShell(AddCustomShell event, Emitter<SettingsState> emit) {
    final updatedShells = [...state.settings.customShells, event.config];
    emit(state.copyWith(
        settings: state.settings.copyWith(customShells: updatedShells)));
  }

  void _onUpdateCustomShell(
      UpdateCustomShell event, Emitter<SettingsState> emit) {
    final updatedShells = state.settings.customShells.map((s) {
      return s.id == event.config.id ? event.config : s;
    }).toList();
    emit(state.copyWith(
        settings: state.settings.copyWith(customShells: updatedShells)));
  }

  void _onRemoveCustomShell(
      RemoveCustomShell event, Emitter<SettingsState> emit) {
    final updatedShells = state.settings.customShells
        .where((s) => s.id != event.shellId)
        .toList();
    // Also clear selectedCustomShellId if we're removing the selected shell
    final shouldClearSelection =
        state.settings.selectedCustomShellId == event.shellId;
    emit(state.copyWith(
        settings: state.settings.copyWith(
      customShells: updatedShells,
      clearSelectedCustomShellId: shouldClearSelection,
    )));
  }

  void _onSelectCustomShell(
      SelectCustomShell event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
        settings: state.settings.copyWith(
      defaultShell: ShellType.custom,
      selectedCustomShellId: event.shellId,
    )));
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    try {
      final settings = AppSettings.fromJson(json['settings']);
      return SettingsState(settings: settings);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return {
      'settings': state.settings.toJson(),
    };
  }
}
