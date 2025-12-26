import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/utils/system_fonts.dart';
import '../bloc/settings_bloc.dart';
import '../models/app_settings.dart';
import '../../../../shared/utils/settings_helpers.dart';
import 'settings_section.dart';

/// Appearance settings content widget for theme and font selection.
class AppearanceSettingsContent extends StatelessWidget {
  const AppearanceSettingsContent({
    super.key,
    required this.settings,
    required this.l10n,
    required this.theme,
    required this.fontsLoading,
    required this.uniqueFamilies,
  });

  final AppSettings settings;
  final AppLocalizations l10n;
  final ShadThemeData theme;
  final bool fontsLoading;
  final List<String> uniqueFamilies;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSection(
          title: l10n.theme,
          description: l10n.themeDescription,
          child: ShadSelect<AppTheme>(
            initialValue: settings.appTheme,
            placeholder: Text(l10n.theme),
            options: AppTheme.values.map(
              (appTheme) => ShadOption(
                value: appTheme,
                child: Text(getAppThemeLocalizedName(appTheme, l10n)),
              ),
            ),
            selectedOptionBuilder: (context, appTheme) =>
                Text(getAppThemeLocalizedName(appTheme, l10n)),
            onChanged: (appTheme) {
              if (appTheme != null) {
                context.read<SettingsBloc>().add(UpdateAppTheme(appTheme));
                final defaultTerminalTheme =
                    appTheme == AppTheme.light ? 'DefaultLight' : 'DefaultDark';
                context
                    .read<SettingsBloc>()
                    .add(UpdateTerminalTheme(defaultTerminalTheme));
              }
            },
          ),
        ),
        Gap(24.h),
        _buildAppFontSection(context),
      ],
    );
  }

  Widget _buildAppFontSection(BuildContext context) {
    return SettingsSection(
      title: l10n.appFontFamily,
      description: l10n.appFontFamilyDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShadSelect<String>(
            initialValue: settings.appFontFamily ?? '__default__',
            placeholder: Text(l10n.defaultGeist),
            options: fontsLoading
                ? [
                    ShadOption(
                      value: 'loading',
                      child: Row(
                        children: [
                          SizedBox(
                            width: 14.w,
                            height: 14.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Gap(8.w),
                          Text(l10n.loading),
                        ],
                      ),
                    ),
                  ]
                : [
                    ShadOption(
                      value: '__default__',
                      child: Text(l10n.defaultGeist),
                    ),
                    ...uniqueFamilies.map(
                      (f) => ShadOption(
                        key: ValueKey(f),
                        value: f,
                        child: Text(f),
                      ),
                    ),
                  ],
            selectedOptionBuilder: (context, value) {
              if (value == '__default__') {
                return Text(l10n.defaultGeist);
              }
              return Text(value);
            },
            onChanged: (String? value) async {
              if (value == 'loading') return;
              if (value == null) return;

              final settingsBloc = context.read<SettingsBloc>();

              if (value != '__default__') {
                await SystemFonts().loadFont(value);
              }

              final String? fontToSet = value == '__default__' ? null : value;
              settingsBloc.add(UpdateAppFontFamily(fontToSet));
            },
          ),
        ],
      ),
    );
  }
}
