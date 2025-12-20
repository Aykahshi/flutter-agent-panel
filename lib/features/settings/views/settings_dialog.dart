import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:system_fonts/system_fonts.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../shared/utils/platform_utils.dart';
import '../bloc/settings_bloc.dart';
import '../models/app_settings.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showShadDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _customShellController;
  List<String> _uniqueFamilies = [];

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsBloc>().state.settings;
    _customShellController =
        TextEditingController(text: settings.customShellPath ?? '');
    _loadSystemFonts();
  }

  Future<void> _loadSystemFonts() async {
    final systemFonts = SystemFonts();
    final fonts = systemFonts.getFontList();
    if (mounted) {
      // Robust filtering for unique family names
      final styleKeywords = {
        'light',
        'thin',
        'thinitalic',
        'lightitalic',
        'regular',
        'italic',
        'oblique',
        'medium',
        'mediumitalic',
        'semibold',
        'demibold',
        'semibolditalic',
        'bold',
        'bolditalic',
        'extrabold',
        'ultrabold',
        'black',
        'heavy',
        'extra',
        'ultra',
        'condensed',
        'expanded',
        'monospaced',
        'sans',
        'serif'
      };

      final families = fonts
          .map((f) {
            // Split by non-alphanumeric characters or camelCase boundaries
            // But let's keep it simple: split by space, dash, or underscore
            final parts = f.split(RegExp(r'[ \-_]'));
            final familyParts = <String>[];

            for (final part in parts) {
              final lowerPart = part.toLowerCase();
              if (styleKeywords.contains(lowerPart)) {
                break; // Stop at first style keyword
              }
              familyParts.add(part);
            }

            return familyParts.isEmpty ? f : familyParts.join(' ');
          })
          .toSet()
          .toList()
        ..sort();

      setState(() {
        _uniqueFamilies = families;
      });
    }
  }

  @override
  void dispose() {
    _customShellController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = context.t;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final settings = state.settings;

        return ShadDialog(
          title: Text(l10n.settings),
          description: Text(l10n.configureAppDescription),
          child: SizedBox(
            width: 600.w,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),

                  // Grid-like layout for key options
                  Wrap(
                    spacing: 20.w,
                    runSpacing: 20.h,
                    children: [
                      // Language Section
                      _buildSmallSection(
                        width: 280.w,
                        title: l10n.language,
                        child: ShadSelect<String>(
                          key: const ValueKey('settings-language-select'),
                          initialValue: settings.locale,
                          placeholder: Text(l10n.selectLanguage),
                          options: [
                            ShadOption(value: 'en', child: Text(l10n.english)),
                            ShadOption(
                                value: 'zh', child: Text(l10n.chineseHans)),
                            ShadOption(
                                value: 'zh_Hant',
                                child: Text(l10n.chineseHant)),
                          ],
                          selectedOptionBuilder: (context, value) {
                            if (value == 'en') return Text(l10n.english);
                            if (value == 'zh') return Text(l10n.chineseHans);
                            if (value == 'zh_Hant')
                              return Text(l10n.chineseHant);
                            return Text(value);
                          },
                          onChanged: (value) {
                            if (value != null) {
                              context
                                  .read<SettingsBloc>()
                                  .add(UpdateLocale(value));
                            }
                          },
                        ),
                      ),

                      // App Theme Section
                      _buildSmallSection(
                        width: 280.w,
                        title: l10n.theme,
                        child: ShadSelect<AppTheme>(
                          initialValue: settings.appTheme,
                          placeholder: Text(l10n.theme),
                          options: AppTheme.values.map(
                            (theme) => ShadOption(
                              value: theme,
                              child:
                                  Text(_getAppThemeLocalizedName(theme, l10n)),
                            ),
                          ),
                          selectedOptionBuilder: (context, theme) =>
                              Text(_getAppThemeLocalizedName(theme, l10n)),
                          onChanged: (theme) {
                            if (theme != null) {
                              context
                                  .read<SettingsBloc>()
                                  .add(UpdateAppTheme(theme));
                            }
                          },
                        ),
                      ),

                      // Terminal Theme Section
                      _buildSmallSection(
                        width: 280.w,
                        title: l10n.terminalSettings,
                        child: ShadSelect<TerminalTheme>(
                          initialValue: settings.terminalTheme,
                          placeholder: Text(l10n.terminalSettings),
                          options: TerminalTheme.values.map(
                            (theme) => ShadOption(
                              value: theme,
                              child: Text(
                                  _getTerminalThemeLocalizedName(theme, l10n)),
                            ),
                          ),
                          selectedOptionBuilder: (context, theme) =>
                              Text(_getTerminalThemeLocalizedName(theme, l10n)),
                          onChanged: (theme) {
                            if (theme != null) {
                              context
                                  .read<SettingsBloc>()
                                  .add(UpdateTerminalTheme(theme));
                            }
                          },
                        ),
                      ),

                      // Font Family Section
                      _buildSmallSection(
                        width: 280.w,
                        title: l10n.fontFamily,
                        child: ShadSelect<String>(
                          initialValue: settings.fontSettings.fontFamily,
                          placeholder: Text(l10n.fontFamily),
                          options: _uniqueFamilies.isEmpty
                              ? [
                                  ShadOption(
                                      value: settings.fontSettings.fontFamily,
                                      child: Text(
                                          settings.fontSettings.fontFamily))
                                ]
                              : _uniqueFamilies
                                  .map((f) =>
                                      ShadOption(value: f, child: Text(f)))
                                  .toList(),
                          selectedOptionBuilder: (context, value) =>
                              Text(value),
                          onChanged: (value) {
                            if (value != null) {
                              context
                                  .read<SettingsBloc>()
                                  .add(UpdateFontSettings(
                                    settings.fontSettings
                                        .copyWith(fontFamily: value),
                                  ));
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  SizedBox(height: 12.h),

                  // Font Size
                  Row(
                    children: [
                      Text(l10n.fontSize,
                          style: theme.textTheme.small.copyWith(
                              color: theme.colorScheme.mutedForeground)),
                      const Spacer(),
                      Text('${settings.fontSettings.fontSize.toInt()}px',
                          style: theme.textTheme.small),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  ShadSlider(
                    initialValue: settings.fontSettings.fontSize,
                    min: 10,
                    max: 24,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(UpdateFontSettings(
                            settings.fontSettings.copyWith(fontSize: value),
                          ));
                    },
                  ),

                  SizedBox(height: 12.h),

                  // Bold / Italic toggles
                  Row(
                    children: [
                      ShadCheckbox(
                        value: settings.fontSettings.isBold,
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(UpdateFontSettings(
                                settings.fontSettings.copyWith(isBold: value),
                              ));
                        },
                        label: Text(l10n.bold),
                      ),
                      SizedBox(width: 16.w),
                      ShadCheckbox(
                        value: settings.fontSettings.isItalic,
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(UpdateFontSettings(
                                settings.fontSettings.copyWith(isItalic: value),
                              ));
                        },
                        label: Text(l10n.italic),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Font Preview
                  Text(l10n.fontPreview,
                      style: theme.textTheme.small
                          .copyWith(color: theme.colorScheme.mutedForeground)),
                  SizedBox(height: 4.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.background,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: theme.colorScheme.border),
                    ),
                    child: Text(
                      l10n.fontPreviewText,
                      style: TextStyle(
                        fontFamily: settings.fontSettings.fontFamily,
                        fontSize: settings.fontSettings.fontSize,
                        fontWeight: settings.fontSettings.isBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontStyle: settings.fontSettings.isItalic
                            ? FontStyle.italic
                            : FontStyle.normal,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Default Shell Section
                  _buildSectionTitle(theme, l10n.shellSettings),
                  SizedBox(height: 8.h),
                  ShadSelect<ShellType>(
                    initialValue: settings.defaultShell,
                    placeholder: Text(l10n.defaultShell),
                    options: ShellType.values
                        .map((s) => ShadOption(
                              value: s,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_getShellIcon(s.icon), size: 16.sp),
                                  SizedBox(width: 8.w),
                                  Text(s == ShellType.custom
                                      ? l10n.custom
                                      : _getShellTypeLocalizedName(s, l10n)),
                                ],
                              ),
                            ))
                        .toList(),
                    selectedOptionBuilder: (context, value) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getShellIcon(value.icon), size: 16.sp),
                        SizedBox(width: 8.w),
                        Text(value == ShellType.custom
                            ? l10n.custom
                            : _getShellTypeLocalizedName(value, l10n)),
                      ],
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsBloc>().add(UpdateDefaultShell(
                              value,
                              customShellPath: value == ShellType.custom
                                  ? _customShellController.text
                                  : null,
                            ));
                      }
                    },
                  ),

                  // Custom Shell Path (visible only when Custom is selected)
                  if (settings.defaultShell == ShellType.custom) ...[
                    SizedBox(height: 12.h),
                    Text(l10n.customShellPath,
                        style: theme.textTheme.small.copyWith(
                            color: theme.colorScheme.mutedForeground)),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Expanded(
                          child: ShadInput(
                            controller: _customShellController,
                            placeholder:
                                const Text('e.g., C:\\path\\to\\shell.exe'),
                            onChanged: (value) {
                              context
                                  .read<SettingsBloc>()
                                  .add(UpdateDefaultShell(
                                    ShellType.custom,
                                    customShellPath: value,
                                  ));
                            },
                          ),
                        ),
                        SizedBox(width: 8.w),
                        ShadButton.outline(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: PlatformUtils.isWindows
                                  ? ['exe', 'bat', 'cmd']
                                  : [],
                            );
                            if (result != null &&
                                result.files.single.path != null) {
                              final path = result.files.single.path!;
                              _customShellController.text = path;
                              if (context.mounted) {
                                context
                                    .read<SettingsBloc>()
                                    .add(UpdateDefaultShell(
                                      ShellType.custom,
                                      customShellPath: path,
                                    ));
                              }
                            }
                          },
                          child: Text(l10n.browse),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getAppThemeLocalizedName(AppTheme theme, AppLocalizations l10n) {
    switch (theme) {
      case AppTheme.slateDark:
        return l10n.slateDark;
      case AppTheme.zincDark:
        return l10n.zincDark;
      case AppTheme.neutralDark:
        return l10n.neutralDark;
      case AppTheme.stoneDark:
        return l10n.stoneDark;
      case AppTheme.grayDark:
        return l10n.grayDark;
    }
  }

  String _getTerminalThemeLocalizedName(
      TerminalTheme theme, AppLocalizations l10n) {
    switch (theme) {
      case TerminalTheme.oneDark:
        return l10n.oneDark;
      case TerminalTheme.dracula:
        return l10n.dracula;
      case TerminalTheme.monokai:
        return l10n.monokai;
      case TerminalTheme.nord:
        return l10n.nord;
      case TerminalTheme.solarizedDark:
        return l10n.solarizedDark;
      case TerminalTheme.githubDark:
        return l10n.githubDark;
    }
  }

  String _getShellTypeLocalizedName(ShellType shell, AppLocalizations l10n) {
    switch (shell) {
      case ShellType.pwsh7:
        return l10n.pwsh7;
      case ShellType.powershell:
        return l10n.powershell;
      case ShellType.cmd:
        return l10n.cmd;
      case ShellType.wsl:
        return l10n.wsl;
      case ShellType.gitBash:
        return l10n.gitBash;
      case ShellType.custom:
        return l10n.custom;
    }
  }

  Widget _buildSmallSection({
    required double width,
    required String title,
    required Widget child,
  }) {
    final theme = ShadTheme.of(context);
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(theme, title),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ShadThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.small.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.mutedForeground,
      ),
    );
  }

  IconData _getShellIcon(String iconName) {
    switch (iconName) {
      case 'terminal':
        return LucideIcons.terminal;
      case 'command':
        return LucideIcons.squareTerminal;
      case 'server':
        return LucideIcons.server;
      case 'gitBranch':
        return LucideIcons.gitBranch;
      case 'settings':
        return LucideIcons.settings;
      default:
        return LucideIcons.terminal;
    }
  }
}
