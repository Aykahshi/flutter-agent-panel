import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/services/app_bloc_observer.dart';
import 'core/services/app_logger.dart';
import 'core/services/crash_log_service.dart';
import 'core/services/user_config_service.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize user config folder first (needed for logging paths)
    await UserConfigService.instance.ensureDirectoriesExist();

    // Initialize crash log service
    await CrashLogService.instance.init();

    // Initialize logger with file output
    AppLogger.instance.init();

    // Set up Flutter error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      CrashLogService.instance.logFlutterError(details);
      AppLogger.instance.logger.e({
        'logger': 'FlutterError',
        'error': details.exceptionAsString(),
        'library': details.library,
      });
    };

    // Set up platform error handler for errors not caught by Flutter
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      CrashLogService.instance.logError(error, stack);
      AppLogger.instance.logger.e({
        'logger': 'PlatformError',
        'error': error.toString(),
      });
      return true;
    };

    // Set Bloc observer for logging
    Bloc.observer = AppBlocObserver();

    await windowManager.ensureInitialized();

    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(
        p.join(UserConfigService.instance.configPath, 'storage'),
      ),
    );

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    AppLogger.instance.logger.i({
      'logger': 'App',
      'message': 'App starting with global error handling',
    });

    // Clean up old log files (keep 30 days)
    await CrashLogService.instance.cleanupOldLogs();

    runApp(App());
  }, (Object error, StackTrace stack) {
    // Zone error handler - catches async errors not handled elsewhere
    CrashLogService.instance.logError(error, stack);
    AppLogger.instance.logger.e({
      'logger': 'ZoneError',
      'error': error.toString(),
    });
  });
}
