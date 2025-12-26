import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/services/user_config_service.dart';
import '../../../../shared/utils/platform_utils.dart';
import '../../../shared/utils/system_fonts.dart';
import '../bloc/settings_bloc.dart';
import '../models/app_settings.dart';
import '../widgets/settings_section.dart';
import '../../terminal/models/terminal_theme_data.dart';
import '../../terminal/services/terminal_theme_service.dart';

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
  late ScrollController _sidebarScrollController;
  List<String> _uniqueFamilies = [];
  int _selectedIndex = 0;
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
    } catch (_) {
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
      0 => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsSection(
              title: l10n.language,
              description: l10n.selectLanguage,
              child: ShadSelect<String>(
                initialValue: settings.locale,
                placeholder: Text(l10n.selectLanguage),
                options: [
                  ShadOption(value: 'en', child: Text(l10n.english)),
                  ShadOption(value: 'zh', child: Text(l10n.chineseHans)),
                  ShadOption(value: 'zh_Hant', child: Text(l10n.chineseHant)),
                ],
                selectedOptionBuilder: (context, value) {
                  if (value == 'en') return Text(l10n.english);
                  if (value == 'zh') return Text(l10n.chineseHans);
                  if (value == 'zh_Hant') return Text(l10n.chineseHant);
                  return Text(value);
                },
                onChanged: (value) {
                  if (value != null) {
                    context.read<SettingsBloc>().add(UpdateLocale(value));
                  }
                },
              ),
            ),
          ],
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
                    child: Text(_getAppThemeLocalizedName(theme, l10n)),
                  ),
                ),
                selectedOptionBuilder: (context, theme) =>
                    Text(_getAppThemeLocalizedName(theme, l10n)),
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
                                    (f) => ShadOption(value: f, child: Text(f)))
                                .toList(),
                    selectedOptionBuilder: (context, value) => Text(value),
                    onChanged: (value) async {
                      if (value != null) {
                        // Load font first so preview updates correctly
                        await SystemFonts().loadFont(value);
                        if (!context.mounted) return;
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
                      // Built-in shells (excluding custom)
                      ...ShellType.values
                          .where((s) => s != ShellType.custom)
                          .map(
                            (s) => ShadOption(
                              value: s.name,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_getShellIcon(s.icon), size: 16.sp),
                                  Gap(8.w),
                                  Text(_getShellTypeLocalizedName(s, l10n)),
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
                            Icon(_getShellIcon(shellType.icon), size: 16.sp),
                            Gap(8.w),
                            Text(_getShellTypeLocalizedName(shellType, l10n)),
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
      3 => _buildCustomShellsContent(settings, l10n, theme),
      4 => _buildAgentsContent(settings, l10n, theme),
      _ => const SizedBox.shrink(),
    };
  }

  Future<bool> _checkCommandInstalled(String command) async {
    try {
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

  Future<bool> _installAgent(
    String installCommand,
    void Function(String) onLog,
  ) async {
    try {
      final parts = installCommand.split(' ');
      if (parts.isEmpty) return false;

      final process = await Process.start(
        parts.first,
        parts.sublist(1),
        runInShell: true,
      );

      // Stream stdout/stderr to log
      process.stdout.transform(utf8.decoder).listen(onLog);
      process.stderr.transform(utf8.decoder).listen(onLog);

      final exitCode = await process.exitCode;
      return exitCode == 0;
    } catch (e) {
      onLog('Error: $e');
      return false;
    }
  }

  Widget _buildAgentsContent(
    AppSettings settings,
    AppLocalizations l10n,
    ShadThemeData theme,
  ) {
    // Separate presets and custom
    final presetAgents =
        settings.agents.where((a) => a.preset != AgentPreset.custom).toList();
    final customAgents =
        settings.agents.where((a) => a.preset == AgentPreset.custom).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Presets
        SettingsSection(
          title: l10n.agents,
          description: l10n.agentsDescription,
          child: Column(
            children: [
              ...presetAgents.map((agent) {
                final color = _getAgentColor(agent.preset);
                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.border),
                    borderRadius: BorderRadius.circular(8.r),
                    color: agent.enabled
                        ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 32.sp,
                        height: 32.sp,
                        padding: EdgeInsets.all(4.sp),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.background,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Builder(
                          builder: (context) {
                            var iconPath = agent.preset.iconAssetPath!;
                            ColorFilter? colorFilter;

                            if (agent.preset == AgentPreset.opencode &&
                                Theme.of(context).brightness ==
                                    Brightness.dark) {
                              iconPath = Assets.opencodeDarkLogo;
                            }

                            if (agent.preset == AgentPreset.codex ||
                                agent.preset == AgentPreset.githubCopilot) {
                              colorFilter = ColorFilter.mode(
                                theme.colorScheme.foreground,
                                BlendMode.srcIn,
                              );
                            }

                            return SvgPicture.asset(
                              iconPath,
                              colorFilter: colorFilter,
                              placeholderBuilder: (context) =>
                                  const Icon(LucideIcons.bot),
                            );
                          },
                        ),
                      ),
                      Gap(12.w),
                      // Name & Command
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              agent.name,
                              style: theme.textTheme.p.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              agent.command,
                              style: theme.textTheme.small.copyWith(
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Edit Args/Env
                      ShadButton.ghost(
                        padding: EdgeInsets.zero,
                        width: 32.w,
                        height: 32.h,
                        onPressed: () => _showAddEditAgentDialog(
                          context,
                          l10n,
                          theme,
                          existingAgent: agent,
                        ),
                        child: Icon(LucideIcons.settings, size: 16.sp),
                      ),
                      Gap(8.w),
                      // Toggle
                      ShadSwitch(
                        value: agent.enabled,
                        onChanged: (value) =>
                            _toggleAgent(agent, value, l10n, theme),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        Divider(height: 32.h, color: theme.colorScheme.border),

        // Custom Agents
        SettingsSection(
          title: l10n.customAgent,
          description:
              l10n.agentsDescription, // Reuse description or make new one
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShadButton.outline(
                onPressed: () => _showAddEditAgentDialog(
                  context,
                  l10n,
                  theme,
                  isCustom: true,
                ),
                leading: Icon(LucideIcons.plus, size: 16.sp),
                child: Text(l10n.addCustomAgent),
              ),
              Gap(16.h),
              if (customAgents.isEmpty)
                Text(
                  l10n.noCustomAgents, // Fixed L10n key
                  style: theme.textTheme.muted,
                ) // Reuse 'no custom' string for simplicity or generic
              else
                ...customAgents.map(
                  (agent) => Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.border),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.bot,
                          size: 24.sp,
                        ), // Default icon for custom
                        Gap(12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(agent.name, style: theme.textTheme.p),
                              Text(
                                agent.command,
                                style: theme.textTheme.small.copyWith(
                                  color: theme.colorScheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ShadButton.ghost(
                          padding: EdgeInsets.zero,
                          width: 32.w,
                          height: 32.h,
                          onPressed: () => _showAddEditAgentDialog(
                            context,
                            l10n,
                            theme,
                            existingAgent: agent,
                            isCustom: true,
                          ),
                          child: Icon(LucideIcons.pencil, size: 16.sp),
                        ),
                        ShadButton.ghost(
                          padding: EdgeInsets.zero,
                          width: 32.w,
                          height: 32.h,
                          onPressed: () => context
                              .read<SettingsBloc>()
                              .add(RemoveAgentConfig(agent.id)),
                          child: Icon(
                            LucideIcons.trash2,
                            size: 16.sp,
                            color: theme.colorScheme.destructive,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Color? _getAgentColor(AgentPreset preset) => switch (preset) {
        AgentPreset.claude => const Color(0xFFD97757),
        AgentPreset.qwen => const Color(0xFF615CED),
        AgentPreset.codex => const Color(0xFF10A37F),
        AgentPreset.gemini => const Color(0xFF4E87F6),
        AgentPreset.opencode => Colors.blueGrey,
        _ => null,
      };

  Future<void> _toggleAgent(
    AgentConfig agent,
    bool value,
    AppLocalizations l10n,
    ShadThemeData theme,
  ) async {
    if (!value) {
      context
          .read<SettingsBloc>()
          .add(UpdateAgentConfig(agent.copyWith(enabled: false)));
      return;
    }

    // Optimistic Update: toggle ON immediately
    context
        .read<SettingsBloc>()
        .add(UpdateAgentConfig(agent.copyWith(enabled: true)));

    // Check availability asynchronously
    final exists = await _checkCommandInstalled(agent.command);
    if (!mounted) return;

    if (exists) {
      // Confirmed installed, keep it enabled.
      return;
    }

    // Agent not found, revert optimistic update
    context
        .read<SettingsBloc>()
        .add(UpdateAgentConfig(agent.copyWith(enabled: false)));

    // Prompt Install
    final installCmd = agent.preset.defaultInstallCommand;
    if (installCmd.isEmpty) {
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: Text(l10n.agentNotInstalled),
          description: Text(l10n.agentInstallFailed),
        ),
      );
      return;
    }

    // Show Dialog
    final shouldInstall = await showShadDialog<bool>(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: Text(l10n.installAgentTitle),
        description: Text(l10n.installAgentMessage(agent.name, installCmd)),
        actions: [
          ShadButton.ghost(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ShadButton(
            child: const Text('Install'), // l10n.install
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (shouldInstall == true) {
      if (!mounted) return;

      // Show progress toast
      final logNotifier = ValueNotifier<String>('');

      ShadToaster.of(context).show(
        ShadToast(
          title: Text(l10n.installingAgent),
          description: ValueListenableBuilder<String>(
            valueListenable: logNotifier,
            builder: (context, log, child) {
              if (log.isEmpty) return const LinearProgressIndicator();

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LinearProgressIndicator(),
                  const Gap(4),
                  Text(
                    log.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.small.copyWith(
                      fontFamily: 'Consolas',
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );

      final success = await _installAgent(installCmd, (line) {
        if (line.trim().isNotEmpty) {
          logNotifier.value = line;
        }
      });

      // Dialog was not shown, so no pop needed.
      // Progress Toast will eventually timeout or be pushed up by Success Toast.

      if (!mounted) return;
      if (success) {
        ShadToaster.of(context).show(
          ShadToast(
            title: Text(l10n.agentInstalled),
            backgroundColor: Colors.green.withValues(alpha: 0.2),
          ),
        );
        context
            .read<SettingsBloc>()
            .add(UpdateAgentConfig(agent.copyWith(enabled: true)));
      } else {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: Text(l10n.agentInstallFailed),
          ),
        );
      }
    }
  }

  void _showAddEditAgentDialog(
    BuildContext context,
    AppLocalizations l10n,
    ShadThemeData theme, {
    AgentConfig? existingAgent,
    bool isCustom = false,
  }) {
    final nameController =
        TextEditingController(text: existingAgent?.name ?? '');
    final commandController =
        TextEditingController(text: existingAgent?.command ?? '');
    final argsController =
        TextEditingController(text: existingAgent?.args.join(' ') ?? '');
    final envController = TextEditingController(
      text: existingAgent?.env.entries
              .map((e) => '${e.key}=${e.value}')
              .join('\n') ??
          '',
    );

    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog(
        title: Text(isCustom ? l10n.addCustomAgent : l10n.editCustomAgent),
        child: SizedBox(
          width: 400.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCustom) ...[
                Text(l10n.agentName),
                ShadInput(controller: nameController),
                Gap(8.h),
                Text(l10n.agentCommand),
                ShadInput(controller: commandController),
                Gap(8.h),
              ],
              Text(l10n.agentArgs),
              ShadInput(controller: argsController),
              Gap(8.h),
              Text(l10n.agentEnv),
              ShadInput(
                controller: envController,
                maxLines: 3,
                placeholder: const Text('KEY=VALUE'),
              ),
              Gap(16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ShadButton.ghost(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(l10n.cancel),
                  ),
                  ShadButton(
                    onPressed: () {
                      // Save
                      final args = argsController.text
                          .trim()
                          .split(' ')
                          .where((s) => s.isNotEmpty)
                          .toList();
                      final envLines = envController.text.trim().split('\n');
                      final env = <String, String>{};
                      for (var line in envLines) {
                        final parts = line.split('=');
                        if (parts.length >= 2) {
                          env[parts[0].trim()] =
                              parts.sublist(1).join('=').trim();
                        }
                      }

                      if (isCustom) {
                        final newAgent = AgentConfig(
                          id: existingAgent?.id ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          preset: AgentPreset.custom,
                          name: nameController.text, // Validation needed
                          command: commandController.text,
                          args: args,
                          env: env,
                          enabled: true,
                        );
                        if (existingAgent != null) {
                          context
                              .read<SettingsBloc>()
                              .add(UpdateAgentConfig(newAgent));
                        } else {
                          context
                              .read<SettingsBloc>()
                              .add(AddAgentConfig(newAgent));
                        }
                      } else {
                        // Update preset args/env/enabled only
                        final updated = existingAgent!.copyWith(
                          args: args,
                          env: env,
                        );
                        context
                            .read<SettingsBloc>()
                            .add(UpdateAgentConfig(updated));
                      }
                      Navigator.of(ctx).pop();
                    },
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomShellsContent(
    AppSettings settings,
    AppLocalizations l10n,
    ShadThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSection(
          title: l10n.customShells,
          description: l10n.customShellsDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add new custom shell button
              ShadButton.outline(
                onPressed: () => _showAddEditShellDialog(context, l10n, theme),
                leading: Icon(LucideIcons.plus, size: 16.sp),
                child: Text(l10n.addCustomShell),
              ),
              Gap(16.h),
              // List of custom shells
              if (settings.customShells.isEmpty)
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.border),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.terminal,
                          size: 48.sp,
                          color: theme.colorScheme.mutedForeground,
                        ),
                        Gap(12.h),
                        Text(l10n.noCustomShells, style: theme.textTheme.large),
                        Gap(4.h),
                        Text(
                          l10n.addYourFirstCustomShell,
                          style: theme.textTheme.small.copyWith(
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...settings.customShells.map(
                  (shell) => Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.border),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.terminal,
                          size: 24.sp,
                          color: theme.colorScheme.primary,
                        ),
                        Gap(12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(shell.name, style: theme.textTheme.p),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                shell.path,
                                style: theme.textTheme.small.copyWith(
                                  color: theme.colorScheme.mutedForeground,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Edit button
                        ShadButton.ghost(
                          padding: EdgeInsets.zero,
                          width: 32.w,
                          height: 32.h,
                          onPressed: () => _showAddEditShellDialog(
                            context,
                            l10n,
                            theme,
                            existingShell: shell,
                          ),
                          child: Icon(LucideIcons.pencil, size: 16.sp),
                        ),
                        // Delete button
                        ShadButton.ghost(
                          padding: EdgeInsets.zero,
                          width: 32.w,
                          height: 32.h,
                          onPressed: () =>
                              _confirmDeleteShell(context, shell, l10n),
                          child: Icon(
                            LucideIcons.trash2,
                            size: 16.sp,
                            color: theme.colorScheme.destructive,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddEditShellDialog(
    BuildContext context,
    AppLocalizations l10n,
    ShadThemeData theme, {
    CustomShellConfig? existingShell,
  }) {
    final nameController =
        TextEditingController(text: existingShell?.name ?? '');
    final pathController =
        TextEditingController(text: existingShell?.path ?? '');

    showShadDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return ShadDialog(
            title: Text(
              existingShell != null
                  ? l10n.editCustomShell
                  : l10n.addCustomShell,
            ),
            description: const SizedBox.shrink(),
            child: Container(
              width: 400.w,
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shell Name
                  Text(l10n.shellName, style: theme.textTheme.small),
                  Gap(8.h),
                  ShadInput(
                    controller: nameController,
                    placeholder: Text(l10n.shellNamePlaceholder),
                  ),
                  Gap(16.h),

                  // Shell Path
                  Text(l10n.customShellPath, style: theme.textTheme.small),
                  Gap(8.h),
                  Row(
                    children: [
                      Expanded(
                        child: ShadInput(
                          controller: pathController,
                          placeholder: Text(l10n.shellPathPlaceholder),
                        ),
                      ),
                      Gap(8.w),
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
                            pathController.text = result.files.single.path!;
                          }
                        },
                        child: Text(l10n.browse),
                      ),
                    ],
                  ),
                  Gap(16.h),

                  Gap(24.h),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.ghost(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.cancel),
                      ),
                      Gap(8.w),
                      ShadButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final path = pathController.text.trim();
                          if (name.isEmpty || path.isEmpty) return;

                          if (existingShell != null) {
                            context.read<SettingsBloc>().add(
                                  UpdateCustomShell(
                                    existingShell.copyWith(
                                      name: name,
                                      path: path,
                                    ),
                                  ),
                                );
                          } else {
                            context.read<SettingsBloc>().add(
                                  AddCustomShell(
                                    CustomShellConfig.create(
                                      name: name,
                                      path: path,
                                    ),
                                  ),
                                );
                          }
                          Navigator.of(context).pop();
                        },
                        child: Text(l10n.save),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteShell(
    BuildContext context,
    CustomShellConfig shell,
    AppLocalizations l10n,
  ) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: Text(l10n.deleteCustomShell),
        description: Text(l10n.confirmDeleteShell),
        actions: [
          ShadButton.ghost(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ShadButton.destructive(
            onPressed: () {
              context.read<SettingsBloc>().add(RemoveCustomShell(shell.id));
              Navigator.of(context).pop();
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  String _getAppThemeLocalizedName(AppTheme theme, AppLocalizations l10n) =>
      switch (theme) {
        AppTheme.dark => l10n.dark,
        AppTheme.light => l10n.light,
      };

  String _getShellTypeLocalizedName(ShellType shell, AppLocalizations l10n) =>
      switch (shell) {
        ShellType.pwsh7 => l10n.pwsh7,
        ShellType.powershell => l10n.powershell,
        ShellType.cmd => l10n.cmd,
        ShellType.wsl => l10n.wsl,
        ShellType.gitBash => l10n.gitBash,
        ShellType.custom => l10n.custom,
      };

  IconData _getShellIcon(String iconName) => switch (iconName) {
        'terminal' => LucideIcons.terminal,
        'command' => LucideIcons.squareTerminal,
        'server' => LucideIcons.server,
        'gitBranch' => LucideIcons.gitBranch,
        'settings' => LucideIcons.settings,
        _ => LucideIcons.terminal,
      };

  Future<void> _verifyAgentInstallations() async {
    final settings = context.read<SettingsBloc>().state.settings;
    for (final agent in settings.agents) {
      if (agent.enabled) {
        final exists = await _checkCommandInstalled(agent.command);
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
