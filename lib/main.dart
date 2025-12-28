import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/services/app_bloc_observer.dart';
import 'core/services/app_logger.dart';
import 'core/services/user_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger first
  AppLogger.instance.init();

  // Set Bloc observer for logging
  Bloc.observer = AppBlocObserver();

  await windowManager.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      p.join(UserConfigService.instance.configPath, 'storage'),
    ),
  );

  // Initialize user config folder
  await UserConfigService.instance.ensureDirectoriesExist();

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
    'message': 'App starting',
  });
  runApp(App());
}
