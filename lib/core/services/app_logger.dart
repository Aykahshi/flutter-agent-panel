import 'package:logger/logger.dart';

/// Centralized logger service for the application.
class AppLogger {
  AppLogger._();

  static final AppLogger instance = AppLogger._();

  late final Logger _logger;
  bool _initialized = false;

  /// Initialize the logger with console output.
  void init() {
    if (_initialized) return;

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );

    _initialized = true;
    _logger.i('Logger initialized');
  }

  Logger get logger {
    if (!_initialized) {
      // Fallback logger if not initialized
      return Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
      );
    }
    return _logger;
  }
}
