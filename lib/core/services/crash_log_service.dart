import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'user_config_service.dart';

/// Service for managing crash/error logs.
/// Writes detailed error information to log files for user bug reports.
class CrashLogService {
  CrashLogService._();
  static final CrashLogService _instance = CrashLogService._();
  static CrashLogService get instance => _instance;

  bool _initialized = false;
  late final String _logsPath;
  late final File _currentLogFile;

  /// Initialize the crash log service.
  /// Must be called after UserConfigService is available.
  Future<void> init() async {
    if (_initialized) return;

    _logsPath = UserConfigService.instance.logsPath;

    // Ensure logs directory exists
    final logsDir = Directory(_logsPath);
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }

    // Create log file with current date
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _currentLogFile = File('$_logsPath/crash_$dateStr.log');

    _initialized = true;
    debugPrint('CrashLogService initialized: ${_currentLogFile.path}');
  }

  /// Get the path to the logs directory.
  String get logsPath => _logsPath;

  /// Get the current log file path.
  String get currentLogFilePath => _currentLogFile.path;

  /// Log a Flutter framework error.
  Future<void> logFlutterError(FlutterErrorDetails details) async {
    if (!_initialized) return;

    final buffer = StringBuffer();
    buffer.writeln('=' * 80);
    buffer.writeln('[FLUTTER ERROR] ${DateTime.now().toIso8601String()}');
    buffer.writeln('=' * 80);
    buffer.writeln('Exception: ${details.exceptionAsString()}');
    buffer.writeln('Library: ${details.library}');
    if (details.context != null) {
      buffer.writeln('Context: ${details.context}');
    }
    buffer.writeln();
    buffer.writeln('Stack Trace:');
    buffer.writeln(details.stack ?? 'No stack trace available');
    buffer.writeln();

    await _appendToLogFile(buffer.toString());
  }

  /// Log a general error with stack trace.
  Future<void> logError(Object error, StackTrace stackTrace) async {
    if (!_initialized) return;

    final buffer = StringBuffer();
    buffer.writeln('=' * 80);
    buffer.writeln('[ERROR] ${DateTime.now().toIso8601String()}');
    buffer.writeln('=' * 80);
    buffer.writeln('Error Type: ${error.runtimeType}');
    buffer.writeln('Error: $error');
    buffer.writeln();
    buffer.writeln('Stack Trace:');
    buffer.writeln(stackTrace);
    buffer.writeln();

    await _appendToLogFile(buffer.toString());
  }

  /// Log an info message.
  Future<void> logInfo(String message) async {
    if (!_initialized) return;

    final line = '[INFO] ${DateTime.now().toIso8601String()} - $message\n';
    await _appendToLogFile(line);
  }

  /// Append content to the current log file.
  Future<void> _appendToLogFile(String content) async {
    try {
      await _currentLogFile.writeAsString(
        content,
        mode: FileMode.writeOnlyAppend,
        flush: true,
      );
    } catch (e) {
      debugPrint('Failed to write to crash log: $e');
    }
  }

  /// Clean up old log files (older than specified days).
  Future<void> cleanupOldLogs({int keepDays = 30}) async {
    if (!_initialized) return;

    try {
      final logsDir = Directory(_logsPath);
      if (!await logsDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));

      await for (final entity in logsDir.list()) {
        if (entity is File && entity.path.endsWith('.log')) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            debugPrint('Deleted old log file: ${entity.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to cleanup old logs: $e');
    }
  }
}
