import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/terminal/bloc/terminal_bloc.dart';
import 'app_logger.dart';

/// Custom BlocObserver that logs Bloc events and state changes.
/// Uses AppLogger for consistent logging format.
class AppBlocObserver extends BlocObserver {
  AppBlocObserver();

  /// Events that should be filtered out to avoid log spam.
  static const _filteredEventTypes = <Type>{
    TerminalOutputReceived,
    ClearRestartingState,
  };

  /// State changes that are too verbose for normal logging.
  static const _verboseBlocs = <String>{
    'TerminalBloc', // High-frequency state changes
  };

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    AppLogger.instance.logger.d({
      'logger': 'Bloc',
      'action': 'onCreate',
      'bloc': bloc.runtimeType.toString(),
    });
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);

    // Filter out high-frequency events
    if (event != null && _filteredEventTypes.contains(event.runtimeType)) {
      return;
    }

    // Use trace level to avoid bug emoji 🐛
    AppLogger.instance.logger.t({
      'logger': 'Bloc',
      'action': 'onEvent',
      'bloc': bloc.runtimeType.toString(),
      'event': _formatEvent(event),
    });
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);

    // Use trace level for all changes to keep log clean
    final blocName = bloc.runtimeType.toString();
    AppLogger.instance.logger.t({
      'logger': 'Bloc',
      'action': 'onChange',
      'bloc': blocName,
      'currentState': _formatState(change.currentState),
      'nextState': _formatState(change.nextState),
    });
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);

    // Filter out high-frequency events
    final event = transition.event;
    if (event != null && _filteredEventTypes.contains(event.runtimeType)) {
      return;
    }

    // Skip detailed transition logging for verbose blocs (already logged in onChange)
    if (_verboseBlocs.contains(bloc.runtimeType.toString())) {
      return;
    }

    AppLogger.instance.logger.t({
      'logger': 'Bloc',
      'action': 'onTransition',
      'bloc': bloc.runtimeType.toString(),
      'event': _formatEvent(transition.event),
    });
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    AppLogger.instance.logger.e(
      {
        'logger': 'Bloc',
        'action': 'onError',
        'bloc': bloc.runtimeType.toString(),
        'error': error.toString(),
      },
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    AppLogger.instance.logger.d({
      'logger': 'Bloc',
      'action': 'onClose',
      'bloc': bloc.runtimeType.toString(),
    });
  }

  /// Formats an event for logging.
  String _formatEvent(Object? event) {
    if (event == null) return 'null';

    final eventName = event.runtimeType.toString();

    // For events with props, try to get a meaningful representation
    try {
      final jsonStr = jsonEncode(event);
      if (jsonStr != '{}') {
        return '$eventName: $jsonStr';
      }
    } catch (_) {
      // Event is not JSON serializable, just use toString
    }

    return eventName;
  }

  /// Formats state for logging.
  String _formatState(dynamic state) {
    if (state == null) return 'null';

    final stateName = state.runtimeType.toString();

    // Try to extract key properties for common state types
    try {
      // For states with toJson, use it
      if (state is Map) {
        return '$stateName: ${jsonEncode(state)}';
      }

      // Just return the type name for complex states
      return stateName;
    } catch (_) {
      return stateName;
    }
  }
}
