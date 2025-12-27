import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:gap/gap.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/services/user_config_service.dart';
import '../../../shared/utils/system_fonts.dart';
import '../../../shared/utils/settings_helpers.dart';
import '../bloc/settings_bloc.dart';
import '../models/app_settings.dart';
import '../widgets/settings_section.dart';
import '../widgets/general_settings_content.dart';
import '../widgets/custom_shells_content.dart';
import '../widgets/agents_content.dart';
import '../widgets/update_settings_content.dart';
import '../../terminal/models/terminal_theme_data.dart';
import '../../terminal/services/terminal_theme_service.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key, this.initialTab = 0});

  /// The initial tab index to display when the dialog opens.
  final int initialTab;

  static Future<void> show(BuildContext context, {int initialTab = 0}) {
    return showShadDialog(
      context: context,
      builder: (context) => SettingsDialog(initialTab: initialTab),
    );
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late ScrollController _sidebarScrollController;
  List<String> _uniqueFamilies = [];
  late int _selectedIndex;
  List<TerminalThemeData> _darkThemes = [];
  List<TerminalThemeData> _lightThemes = [];
  bool _themesLoading = true;
  final TextEditingController _customThemeJsonController =
      TextEditingController();
  String? _customThemeError;
  bool _fontsLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    _sidebarScrollController = ScrollController();
    _loadSystemFonts();
    TerminalThemeService.instance.clearCache();
    _loadTerminalThemes();
  }

  Future<void> _loadSystemFonts() async {
    setState(() => _fontsLoading = true);
    try {
      final systemFonts = SystemFonts();
      final fonts = await systemFonts.getFontFamilies();
      if (mounted) {
        setState(() {
          _uniqueFamilies = fonts;
          _fontsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _fontsLoading = false);
      }
    }
  }

  Future<void> _loadTerminalThemes() async {
    final service = TerminalThemeService.instance;
    final settings = context.read<SettingsBloc>().state.settings;

    final darkThemes = await service.getDarkThemes();
    final lightThemes = await service.getLightThemes();

    if (mounted) {
      setState(() {
        _darkThemes = darkThemes;
        _lightThemes = lightThemes;
        _themesLoading = false;
        if (settings.customTerminalThemeJson != null) {
          _customThemeJsonController.text = settings.customTerminalThemeJson!;
        }
      });
    }
  }

  @override
  void dispose() {
    _sidebarScrollController.dispose();
    _customThemeJsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.t;

    // Define categories - Custom Shells as independent category
    final categories = [
      {'icon': LucideIcons.settings, 'label': l10n.general},
      {'icon': LucideIcons.palette, 'label': l10n.appearance},
      {'icon': LucideIcons.terminal, 'label': l10n.terminalSettings},
      {'icon': LucideIcons.squareTerminal, 'label': l10n.customShells},
      {'icon': LucideIcons.bot, 'label': l10n.agents},
      {'icon': LucideIcons.download, 'label': l10n.update},
    ];

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final settings = state.settings;

        final screenSize = MediaQuery.sizeOf(context);
        final dialogWidth = screenSize.width * 0.65;
        final dialogHeight = screenSize.height * 0.65;

        return ShadDialog(
          title: const SizedBox.shrink(), // Custom title in sidebar/content
          description: const SizedBox.shrink(),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: 600.0.clamp(0.0, dialogWidth),
            maxWidth: dialogWidth,
            minHeight: 400.0.clamp(0.0, dialogHeight),
            maxHeight: dialogHeight,
          ),
          scrollable: false,
          child: Container(
            width: dialogWidth,
            height: dialogHeight,
            color: theme.colorScheme.background,
            child: Row(
              children: [
                // Sidebar
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.card,
                      border: Border(
                        right: BorderSide(
                          color: theme.colorScheme.border,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            controller: _sidebarScrollController,
                            padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 0),
                            itemCount: categories.length,
                            separatorBuilder: (_, __) => Gap(4.h),
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              final isSelected = _selectedIndex == index;
                              return ShadButton.ghost(
                                width: double.infinity,
                                mainAxisAlignment: MainAxisAlignment.start,
                                backgroundColor: isSelected
                                    ? theme.colorScheme.secondary
                                    : Colors.transparent,
                                hoverBackgroundColor: theme.colorScheme.muted,
                                onPressed: () {
                                  setState(() => _selectedIndex = index);
                                  if (categories[index]['label'] ==
                                      l10n.agents) {
                                    _verifyAgentInstallations();
                                  }
                                },
                                leading: Icon(
                                  cat['icon'] as IconData,
                                  size: 18.sp,
                                  color: isSelected
                                      ? theme.colorScheme.foreground
                                      : theme.colorScheme.mutedForeground,
                                ),
                                child: Flexible(
                                  child: Text(
                                    cat['label'] as String,
                                    overflow: TextOverflow.ellipsis,
                                    style: (theme.textTheme.small).copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? theme.colorScheme.foreground
                                          : theme.colorScheme.mutedForeground,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content Area
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 24.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.colorScheme.border,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                categories[_selectedIndex]['label'] as String,
                                style: theme.textTheme.h3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Scrollable Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(
                            32.w,
                          ),
                          child: _buildContentForIndex(
                            _selectedIndex,
                            settings,
                            l10n,
                            theme,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentForIndex(
    int index,
    AppSettings settings,
    AppLocalizations l10n,
    ShadThemeData theme,
  ) {
    return switch (index) {
      0 => GeneralSettingsContent(
          settings: settings,
        ),
      1 => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsSection(
              title: l10n.theme,
              description: l10n.themeDescription,
              child: ShadSelect<AppTheme>(
                initialValue: settings.appTheme,
                placeholder: Text(l10n.theme),
                options: AppTheme.values.map(
                  (theme) => ShadOption(
                    value: theme,
                    child: Text(getAppThemeLocalizedName(theme, l10n)),
                  ),
                ),
                selectedOptionBuilder: (context, theme) =>
                    Text(getAppThemeLocalizedName(theme, l10n)),
                onChanged: (theme) {
                  if (theme != null) {
                    context.read<SettingsBloc>().add(UpdateAppTheme(theme));
                    // Auto-select default terminal theme for the new app theme
                    final defaultTerminalTheme = theme == AppTheme.light
                        ? 'DefaultLight'
                        : 'DefaultDark';
                    context.read<SettingsBloc>().add(
                          UpdateTerminalTheme(defaultTerminalTheme),
                        );
                  }
                },
              ),
            ),
            Gap(24.h),
            // App Font Family
            SettingsSection(
              title: l10n.appFontFamily,
              description: l10n.appFontFamilyDescription,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShadSelect<String>(
                    initialValue: settings.appFontFamily ?? '__default__',
                    placeholder: Text(l10n.defaultGeist),
                    options: _fontsLoading
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
                            ..._uniqueFamilies.map(
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

                      if (!mounted) return;

                      final String? fontToSet =
                          value == '__default__' ? null : value;
                      settingsBloc.add(
                        UpdateAppFontFamily(fontToSet),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      2 => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsSection(
              title: l10n.terminalSettings,
              description: l10n.terminalSettingsDescription,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme dropdown
                  if (_themesLoading)
                    const Center(child: ShadProgress())
                  else
                    ShadSelect<String>(
                      initialValue: settings.terminalThemeName,
                      placeholder: Text(l10n.terminalSettings),
                      options: (settings.appTheme == AppTheme.light
                              ? _lightThemes
                              : _darkThemes)
                          .map(
                        (themeData) => ShadOption(
                          value: themeData.name,
                          child: Text(themeData.name),
                        ),
                      ),
                      selectedOptionBuilder: (context, themeName) =>
                          Text(themeName),
                      onChanged: (themeName) {
                        if (themeName != null) {
                          context
                              .read<SettingsBloc>()
                              .add(UpdateTerminalTheme(themeName));
                        }
                      },
                    ),
                  Gap(24.h),

                  // Custom Theme JSON
                  Text(
                    l10n.customTheme,
                    style: theme.textTheme.large,
                  ),
                  Gap(8.h),
                  Text(
                    l10n.customThemeDescription,
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    l10n.customThemeFolderHint,
                    style: theme.textTheme.muted.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Gap(12.h),
                  ShadInput(
                    controller: _customThemeJsonController,
                    placeholder: const Text(
                      '{"name": "Custom", "background": "#1e1e1e", ...}',
                    ),
                    minLines: 3,
                    maxLines: 6,
                  ),
                  if (_customThemeError != null) ...[
                    Gap(8.h),
                    Text(
                      _customThemeError!,
                      style: theme.textTheme.small.copyWith(
                        color: theme.colorScheme.destructive,
                      ),
                    ),
                  ],
                  Gap(12.h),
                  Row(
                    children: [
                      ShadButton.outline(
                        onPressed: () async {
                          final json = _customThemeJsonController.text.trim();
                          if (json.isEmpty) {
                            setState(() => _customThemeError = null);
                            return;
                          }

                          final validationResult = TerminalThemeService.instance
                              .validateCustomThemeJson(json);
                          if (validationResult != null) {
                            final (errorType, details) = validationResult;
                            final errorMessage = switch (errorType) {
                              'jsonMustBeObject' => l10n.jsonMustBeObject,
                              'missingRequiredField' =>
                                l10n.missingRequiredField(details ?? ''),
                              'invalidJson' => l10n.invalidJson(details ?? ''),
                              'errorParsingTheme' =>
                                l10n.errorParsingTheme(details ?? ''),
                              _ => details ?? errorType,
                            };
                            setState(() => _customThemeError = errorMessage);
                            return;
                          }

                          // Save theme to user folder
                          final isDark = settings.appTheme == AppTheme.dark;
                          final settingsBloc = context.read<SettingsBloc>();

                          final savedPath = await UserConfigService.instance
                              .saveCustomTheme(json, isDark);

                          if (savedPath != null) {
                            // Clear cache and reload themes
                            TerminalThemeService.instance.clearCache();
                            await _loadTerminalThemes();

                            // Select the new theme
                            try {
                              final themeJson =
                                  jsonDecode(json) as Map<String, dynamic>;
                              final themeName = themeJson['name'] as String;

                              if (!mounted) return;
                              settingsBloc.add(
                                UpdateTerminalTheme(themeName),
                              );
                            } catch (_) {}

                            _customThemeJsonController.clear();
                            setState(() => _customThemeError = null);
                          }
                        },
                        child: Text(l10n.applyCustomTheme),
                      ),
                      Gap(12.w),
                      ShadButton.ghost(
                        onPressed: () {
                          _customThemeJsonController.clear();
                          setState(() => _customThemeError = null);
                        },
                        child: Text(l10n.clearCustomTheme),
                      ),
                    ],
                  ),
                  Gap(24.h),

                  // Cursor Blink
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.cursorBlink,
                              style: theme.textTheme.large,
                            ),
                            Text(
                              l10n.cursorBlinkDescription,
                              style: theme.textTheme.small.copyWith(
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ShadSwitch(
                        value: settings.terminalCursorBlink,
                        onChanged: (value) {
                          context
                              .read<SettingsBloc>()
                              .add(UpdateTerminalCursorBlink(value));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              height: 48.h,
              color: theme.colorScheme.border,
            ),
            SettingsSection(
              title: l10n.fontFamily,
              description: l10n.fontFamilyDescription,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShadSelect<String>(
                    initialValue: settings.fontSettings.fontFamily,
                    placeholder: Text(l10n.fontFamily),
                    options: _fontsLoading
                        ? [
                            ShadOption(
                              value: settings.fontSettings.fontFamily,
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
                        : _uniqueFamilies.isEmpty
                            ? [
                                ShadOption(
                                  value: settings.fontSettings.fontFamily,
                                  child: Text(settings.fontSettings.fontFamily),
                                ),
                              ]
                            : _uniqueFamilies
                                .map(
                                  (f) => ShadOption(value: f, child: Text(f)),
                                )
                                .toList(),
                    selectedOptionBuilder: (context, value) => Text(value),
                    onChanged: (value) async {
                      if (value != null) {
                        // Load font first so preview updates correctly
                        await SystemFonts().loadFont(value);
                        if (!mounted) return;
                        context.read<SettingsBloc>().add(
                              UpdateFontSettings(
                                settings.fontSettings
                                    .copyWith(fontFamily: value),
                              ),
                            );
                      }
                    },
                  ),
                  Gap(16.h),
                  // Font Size
                  Row(
                    children: [
                      Text(
                        l10n.fontSize,
                        style: theme.textTheme.small.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${settings.fontSettings.fontSize.toInt()}px',
                        style: theme.textTheme.small,
                      ),
                    ],
                  ),
                  Gap(4.h),
                  ShadSlider(
                    initialValue: settings.fontSettings.fontSize,
                    min: 10,
                    max: 24,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(
                            UpdateFontSettings(
                              settings.fontSettings.copyWith(fontSize: value),
                            ),
                          );
                    },
                  ),
                  Gap(16.h),
                  // Bold/Italic
                  Row(
                    children: [
                      ShadCheckbox(
                        value: settings.fontSettings.isBold,
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(
                                UpdateFontSettings(
                                  settings.fontSettings.copyWith(isBold: value),
                                ),
                              );
                        },
                        label: Text(l10n.bold),
                      ),
                      Gap(16.w),
                      ShadCheckbox(
                        value: settings.fontSettings.isItalic,
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(
                                UpdateFontSettings(
                                  settings.fontSettings
                                      .copyWith(isItalic: value),
                                ),
                              );
                        },
                        label: Text(l10n.italic),
                      ),
                    ],
                  ),
                  Gap(16.h),
                  // Preview
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.background,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: theme.colorScheme.border),
                    ),
                    child: Text(
                      key: ValueKey(
                        '${settings.fontSettings.fontFamily}_${settings.fontSettings.fontSize}_${settings.fontSettings.isBold}_${settings.fontSettings.isItalic}',
                      ),
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
                ],
              ),
            ),
            Divider(
              height: 48.h,
              color: theme.colorScheme.border,
            ),
            SettingsSection(
              title: l10n.shellSettings,
              description: l10n.shellSettingsDescription,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Built-in shells
                  Text(
                    l10n.defaultShell,
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                  Gap(8.h),
                  ShadSelect<String>(
                    initialValue: settings.defaultShell == ShellType.custom
                        ? 'custom:${settings.selectedCustomShellId ?? ''}'
                        : settings.defaultShell.name,
                    placeholder: Text(l10n.defaultShell),
                    options: [
                      // Built-in shells (excluding custom and WSL on non-Windows)
                      ...ShellType.values
                          .where((s) => s != ShellType.custom)
                          .where(
                            (s) => s != ShellType.wsl || Platform.isWindows,
                          )
                          .map(
                            (s) => ShadOption(
                              value: s.name,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(getShellIcon(s.icon), size: 16.sp),
                                  Gap(8.w),
                                  Text(getShellTypeLocalizedName(s, l10n)),
                                ],
                              ),
                            ),
                          ),
                      // Custom shells
                      ...settings.customShells.map(
                        (shell) => ShadOption(
                          value: 'custom:${shell.id}',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.terminal, size: 16.sp),
                              Gap(8.w),
                              Text(shell.name),
                            ],
                          ),
                        ),
                      ),
                    ],
                    selectedOptionBuilder: (context, value) {
                      if (value.startsWith('custom:')) {
                        final shellId = value.substring(7);
                        final shell = settings.customShells
                            .where((s) => s.id == shellId)
                            .firstOrNull;
                        if (shell != null) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.terminal, size: 16.sp),
                              Gap(8.w),
                              Text(shell.name),
                            ],
                          );
                        }
                      }
                      final shellType = ShellType.values
                          .where((s) => s.name == value)
                          .firstOrNull;
                      if (shellType != null) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(getShellIcon(shellType.icon), size: 16.sp),
                            Gap(8.w),
                            Text(getShellTypeLocalizedName(shellType, l10n)),
                          ],
                        );
                      }
                      return Text(value);
                    },
                    onChanged: (value) {
                      if (value == null) return;
                      if (value.startsWith('custom:')) {
                        final shellId = value.substring(7);
                        context
                            .read<SettingsBloc>()
                            .add(SelectCustomShell(shellId));
                      } else {
                        final shellType =
                            ShellType.values.firstWhere((s) => s.name == value);
                        context
                            .read<SettingsBloc>()
                            .add(UpdateDefaultShell(shellType));
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      3 => CustomShellsContent(settings: settings),
      4 => AgentsContent(settings: settings),
      5 => const UpdateSettingsContent(),
      _ => const SizedBox.shrink(),
    };
  }

  Future<bool> _checkCommandInstalled(String command, AgentConfig agent) async {
    try {
      final isWsl = _isWslShell(agent.shellId);

      if (isWsl && Platform.isWindows) {
        // Run check inside WSL
        final result = await Process.run(
          'wsl',
          ['which', command],
          runInShell: true,
        );
        return result.exitCode == 0;
      }

      // Default Windows/Unix check
      final isWindows = Platform.isWindows;
      final result = await Process.run(
        isWindows ? 'where' : 'which',
        [command],
        runInShell: true,
      );
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  bool _isWslShell(String? shellId) {
    if (shellId == null) return false;
    return shellId == 'wsl' || shellId == ShellType.wsl.name;
  }

  Future<void> _verifyAgentInstallations() async {
    final settings = context.read<SettingsBloc>().state.settings;
    for (final agent in settings.agents) {
      if (agent.enabled) {
        final exists = await _checkCommandInstalled(agent.command, agent);
        if (!exists) {
          if (mounted) {
            context
                .read<SettingsBloc>()
                .add(UpdateAgentConfig(agent.copyWith(enabled: false)));
          }
        }
      }
    }
  }
}
