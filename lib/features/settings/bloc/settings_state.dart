part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.settings = const AppSettings(),
    this.isLoading = false,
    this.error,
  });
  final AppSettings settings;
  final bool isLoading;
  final String? error;

  SettingsState copyWith({
    AppSettings? settings,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [settings, isLoading, error];
}
