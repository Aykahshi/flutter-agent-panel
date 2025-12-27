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
import 'features/terminal/bloc/terminal_bloc.dart';
import 'shared/utils/system_fonts.dart';
import 'package:chinese_font_library/chinese_font_library.dart';

class App extends StatelessWidget {
  App({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WorkspaceBloc()),
        BlocProvider(create: (_) => SettingsBloc()..add(const LoadSettings())),
        BlocProvider(create: (_) => TerminalBloc()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(1280, 800),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return BlocConsumer<SettingsBloc, SettingsState>(
            listenWhen: (previous, current) =>
                previous.settings.appFontFamily !=
                current.settings.appFontFamily,
            listener: (context, state) {
              final fontFamily = state.settings.appFontFamily;
              if (fontFamily != null) {
                SystemFonts().loadFont(fontFamily);
              }
            },
            buildWhen: (previous, current) =>
                previous.settings.appTheme != current.settings.appTheme ||
                previous.settings.appFontFamily !=
                    current.settings.appFontFamily ||
                previous.settings.locale != current.settings.locale,
            builder: (context, state) {
              final appTheme = state.settings.appTheme;
              final fontFamily = state.settings.appFontFamily;

              return ShadApp.custom(
                themeMode: appTheme == AppTheme.light
                    ? ThemeMode.light
                    : ThemeMode.dark,
                darkTheme: ShadThemeData(
                  brightness: Brightness.dark,
                  colorScheme: _getColorScheme(appTheme),
                  textTheme: _getTextTheme(fontFamily),
                ),
                theme: ShadThemeData(
                  brightness: Brightness.light,
                  colorScheme: _getColorScheme(appTheme),
                  textTheme: _getTextTheme(fontFamily),
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
                      Locale('zh', 'CN'),
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
      return Locale(parts[0], parts[1]);
    }
    return Locale(localeStr);
  }

  ShadColorScheme _getColorScheme(AppTheme theme) => switch (theme) {
        AppTheme.dark => const ShadZincColorScheme.dark(),
        AppTheme.light => const ShadZincColorScheme.light(),
      };

  ShadTextTheme _getTextTheme(String? fontFamily) {
    final baseTheme = fontFamily == null
        ? ShadTextTheme(family: 'Geist')
        : ShadTextTheme(family: fontFamily);

    return baseTheme.copyWith(
      h1Large: baseTheme.h1Large.useSystemChineseFont(),
      h1: baseTheme.h1.useSystemChineseFont(),
      h2: baseTheme.h2.useSystemChineseFont(),
      h3: baseTheme.h3.useSystemChineseFont(),
      h4: baseTheme.h4.useSystemChineseFont(),
      p: baseTheme.p.useSystemChineseFont(),
      blockquote: baseTheme.blockquote.useSystemChineseFont(),
      table: baseTheme.table.useSystemChineseFont(),
      list: baseTheme.list.useSystemChineseFont(),
      lead: baseTheme.lead.useSystemChineseFont(),
      large: baseTheme.large.useSystemChineseFont(),
      small: baseTheme.small.useSystemChineseFont(),
      muted: baseTheme.muted.useSystemChineseFont(),
    );
  }
}
