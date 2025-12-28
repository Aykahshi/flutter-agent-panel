import 'package:logger/logger.dart';

/// Centralized logger service for the application.
class AppLogger {
  AppLogger._();

  static final AppLogger instance = AppLogger._();

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _initialized = true;
    _logger.i('Logger initialized');
  }

  Logger get logger => _logger;
}
