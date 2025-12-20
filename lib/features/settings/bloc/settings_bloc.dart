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
      customShellPath: event.customShellPath,
    )));
  }

  void _onUpdateLocale(UpdateLocale event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
        settings: state.settings.copyWith(locale: event.locale)));
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
