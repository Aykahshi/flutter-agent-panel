part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final AppSettings settings;
  final bool isLoading;
  final String? error;

  const SettingsState({
    this.settings = const AppSettings(),
    this.isLoading = false,
    this.error,
  });

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
