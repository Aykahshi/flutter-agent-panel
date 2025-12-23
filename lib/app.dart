import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'features/workspace/bloc/workspace_bloc.dart';
import 'features/settings/bloc/settings_bloc.dart';
import 'features/settings/models/app_settings.dart';

class App extends StatelessWidget {
  App({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WorkspaceBloc()),
        BlocProvider(create: (_) => SettingsBloc()..add(const LoadSettings())),
      ],
      child: ScreenUtilInit(
        designSize: const Size(1280, 800),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              final appTheme = state.settings.appTheme;

              return ShadApp.custom(
                themeMode: appTheme == AppTheme.light
                    ? ThemeMode.light
                    : ThemeMode.dark,
                darkTheme: ShadThemeData(
                  brightness: Brightness.dark,
                  colorScheme: _getColorScheme(appTheme),
                ),
                theme: ShadThemeData(
                  brightness: Brightness.light,
                  colorScheme: _getColorScheme(appTheme),
                ),
                appBuilder: (context) {
                  return MaterialApp.router(
                    title: 'Flutter Agent Panel',
                    theme: Theme.of(context),
                    debugShowCheckedModeBanner: false,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: const [
                      Locale('en'),
                      Locale('zh'),
                      Locale.fromSubtags(
                        languageCode: 'zh',
                        scriptCode: 'Hant',
                      ),
                    ],
                    locale: _parseLocale(state.settings.locale),
                    routerConfig: _appRouter.config(),
                    builder: (context, child) => ShadAppBuilder(
                      child: child ?? const SizedBox.shrink(),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Locale _parseLocale(String localeStr) {
    if (localeStr.contains('_')) {
      final parts = localeStr.split('_');
      if (parts.length > 1 && parts[1] == 'Hant') {
        return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
      }
      return Locale(parts[0], parts[1]);
    }
    return Locale(localeStr);
  }

  ShadColorScheme _getColorScheme(AppTheme theme) => switch (theme) {
        AppTheme.dark => const ShadZincColorScheme.dark(),
        AppTheme.light => const ShadZincColorScheme.light(),
      };
}
