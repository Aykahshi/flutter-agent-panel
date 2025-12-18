import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:macos_ui/macos_ui.dart';
import 'package:yaru/yaru.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/l10n/app_localizations.dart';

import 'shared/utils/platform_utils.dart';
import 'package:signals/signals_flutter.dart';
import 'features/workspace/views/workspace_view.dart';
import 'core/viewmodels/theme_viewmodel.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1280, 800), // Default design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return Watch((context) {
          final themeMode = ThemeViewModel().themeMode.value;

          if (PlatformUtils.isWindows) {
            return FluentApp(
              title: 'Flutter Agent Panel',
              themeMode: themeMode,
              theme: FluentThemeData.light(),
              darkTheme: FluentThemeData.dark(),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                FluentLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: const WorkspaceView(),
            );
          } else if (PlatformUtils.isMacOS) {
            return MacosApp(
              title: 'Flutter Agent Panel',
              themeMode: themeMode,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: const WorkspaceView(),
            );
          } else {
            // Linux (Yaru) / Default
            return MaterialApp(
              title: 'Flutter Agent Panel',
              themeMode: themeMode,
              theme: yaruLight,
              darkTheme: yaruDark,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: const WorkspaceView(),
            );
          }
        });
      },
    );
  }
}
