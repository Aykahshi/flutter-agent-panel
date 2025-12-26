import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/app_settings.dart';
import '../../../shared/utils/system_fonts.dart';

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
    on<UpdateAppFontFamily>(_onUpdateAppFontFamily);
    on<UpdateDefaultShell>(_onUpdateDefaultShell);
    on<UpdateLocale>(_onUpdateLocale);
    on<UpdateTerminalCursorBlink>(_onUpdateTerminalCursorBlink);
    on<AddCustomShell>(_onAddCustomShell);
    on<UpdateCustomShell>(_onUpdateCustomShell);
    on<RemoveCustomShell>(_onRemoveCustomShell);
    on<SelectCustomShell>(_onSelectCustomShell);
    on<UpdateAgentConfig>(_onUpdateAgentConfig);
    on<AddAgentConfig>(_onAddAgentConfig);
    on<RemoveAgentConfig>(_onRemoveAgentConfig);
  }

  void _onUpdateAppTheme(UpdateAppTheme event, Emitter<SettingsState> emit) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(appTheme: event.appTheme),
      ),
    );
  }

  void _onUpdateTerminalTheme(
    UpdateTerminalTheme event,
    Emitter<SettingsState> emit,
  ) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(
          terminalThemeName: event.themeName,
          customTerminalThemeJson: event.customThemeJson,
          clearCustomTerminalThemeJson: event.customThemeJson == null,
        ),
      ),
    );
  }

  void _onUpdateFontSettings(
    UpdateFontSettings event,
    Emitter<SettingsState> emit,
  ) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(fontSettings: event.fontSettings),
      ),
    );
  }

  void _onUpdateAppFontFamily(
    UpdateAppFontFamily event,
    Emitter<SettingsState> emit,
  ) {
    if (event.appFontFamily != null) {
      SystemFonts().loadFont(event.appFontFamily!);
    }
    emit(
      state.copyWith(
        settings: state.settings.copyWith(
          appFontFamily: event.appFontFamily,
          clearAppFontFamily: event.appFontFamily == null,
        ),
      ),
    );
  }

  void _onUpdateDefaultShell(
    UpdateDefaultShell event,
    Emitter<SettingsState> emit,
  ) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(
          defaultShell: event.defaultShell,
          selectedCustomShellId: event.selectedCustomShellId,
          clearSelectedCustomShellId: event.defaultShell != ShellType.custom,
        ),
      ),
    );
  }

  void _onUpdateLocale(UpdateLocale event, Emitter<SettingsState> emit) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(locale: event.locale),
      ),
    );
  }

  void _onUpdateTerminalCursorBlink(
    UpdateTerminalCursorBlink event,
    Emitter<SettingsState> emit,
  ) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(terminalCursorBlink: event.isEnabled),
      ),
    );
  }

  void _onAddCustomShell(AddCustomShell event, Emitter<SettingsState> emit) {
    final updatedShells = [...state.settings.customShells, event.config];
    emit(
      state.copyWith(
        settings: state.settings.copyWith(customShells: updatedShells),
      ),
    );
  }

  void _onUpdateCustomShell(
    UpdateCustomShell event,
    Emitter<SettingsState> emit,
  ) {
    final updatedShells = state.settings.customShells.map((s) {
      return s.id == event.config.id ? event.config : s;
    }).toList();
    emit(
      state.copyWith(
        settings: state.settings.copyWith(customShells: updatedShells),
      ),
    );
  }

  void _onRemoveCustomShell(
    RemoveCustomShell event,
    Emitter<SettingsState> emit,
  ) {
    final updatedShells = state.settings.customShells
        .where((s) => s.id != event.shellId)
        .toList();
    // Also clear selectedCustomShellId if we're removing the selected shell
    final shouldClearSelection =
        state.settings.selectedCustomShellId == event.shellId;
    emit(
      state.copyWith(
        settings: state.settings.copyWith(
          customShells: updatedShells,
          clearSelectedCustomShellId: shouldClearSelection,
        ),
      ),
    );
  }

  void _onSelectCustomShell(
    SelectCustomShell event,
    Emitter<SettingsState> emit,
  ) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(
          defaultShell: ShellType.custom,
          selectedCustomShellId: event.shellId,
        ),
      ),
    );
  }

  void _onUpdateAgentConfig(
    UpdateAgentConfig event,
    Emitter<SettingsState> emit,
  ) {
    final updatedAgents = state.settings.agents.map((a) {
      return a.id == event.config.id ? event.config : a;
    }).toList();
    emit(
      state.copyWith(
        settings: state.settings.copyWith(agents: updatedAgents),
      ),
    );
  }

  void _onAddAgentConfig(AddAgentConfig event, Emitter<SettingsState> emit) {
    final updatedAgents = [...state.settings.agents, event.config];
    emit(
      state.copyWith(
        settings: state.settings.copyWith(agents: updatedAgents),
      ),
    );
  }

  void _onRemoveAgentConfig(
    RemoveAgentConfig event,
    Emitter<SettingsState> emit,
  ) {
    final updatedAgents =
        state.settings.agents.where((a) => a.id != event.agentId).toList();
    emit(
      state.copyWith(
        settings: state.settings.copyWith(agents: updatedAgents),
      ),
    );
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
