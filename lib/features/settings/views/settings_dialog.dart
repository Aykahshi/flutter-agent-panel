import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:system_fonts/system_fonts.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/services/user_config_service.dart';
import '../../../../shared/utils/platform_utils.dart';
import '../bloc/settings_bloc.dart';
import '../models/app_settings.dart';
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

  @override
  void initState() {
    super.initState();
    _sidebarScrollController = ScrollController();
    _loadSystemFonts();
    TerminalThemeService.instance.clearCache();
    _loadTerminalThemes();
  }

  Future<void> _loadSystemFonts() async {
    final systemFonts = SystemFonts();
    final fonts = systemFonts.getFontList();
    if (mounted) {
      setState(() {
        _uniqueFamilies = fonts..sort();
      });
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
    final theme = ShadTheme.of(context);
    final l10n = context.t;

    // Define categories - Custom Shells as independent category
    final categories = [
      {'icon': LucideIcons.settings, 'label': l10n.general},
      {'icon': LucideIcons.palette, 'label': l10n.appearance},
      {'icon': LucideIcons.terminal, 'label': l10n.terminalSettings},
      {'icon': LucideIcons.squareTerminal, 'label': l10n.customShells},
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
                        right: BorderSide(color: theme.colorScheme.border),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            controller: _sidebarScrollController,
                            padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 0),
                            itemCount: categories.length,
                            separatorBuilder: (_, __) => SizedBox(height: 4.h),
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
                                  setState(() {
                                    _selectedIndex = index;
                                  });
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
                            horizontal: 32.w, vertical: 24.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: theme.colorScheme.border),
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
                          padding: EdgeInsets.all(32.w),
                          child: _buildContentForIndex(
                              _selectedIndex, settings, l10n, theme),
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

  Widget _buildContentForIndex(int index, AppSettings settings,
      AppLocalizations l10n, ShadThemeData theme) {
    switch (index) {
      case 0: // General
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
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
        );
      case 1: // Appearance
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
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
        );
      case 2: // Terminal
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
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
                  SizedBox(height: 24.h),

                  // Custom Theme JSON
                  Text(l10n.customTheme, style: theme.textTheme.large),
                  SizedBox(height: 8.h),
                  Text(
                    l10n.customThemeDescription,
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    l10n.customThemeFolderHint,
                    style: theme.textTheme.muted.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ShadInput(
                    controller: _customThemeJsonController,
                    placeholder: const Text(
                        '{"name": "Custom", "background": "#1e1e1e", ...}'),
                    minLines: 3,
                    maxLines: 6,
                  ),
                  if (_customThemeError != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      _customThemeError!,
                      style: theme.textTheme.small.copyWith(
                        color: theme.colorScheme.destructive,
                      ),
                    ),
                  ],
                  SizedBox(height: 12.h),
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
                            String errorMessage;
                            switch (errorType) {
                              case 'jsonMustBeObject':
                                errorMessage = l10n.jsonMustBeObject;
                              case 'missingRequiredField':
                                errorMessage =
                                    l10n.missingRequiredField(details ?? '');
                              case 'invalidJson':
                                errorMessage = l10n.invalidJson(details ?? '');
                              case 'errorParsingTheme':
                                errorMessage =
                                    l10n.errorParsingTheme(details ?? '');
                              default:
                                errorMessage = details ?? errorType;
                            }
                            setState(() => _customThemeError = errorMessage);
                            return;
                          }

                          // Save theme to user folder
                          final isDark = settings.appTheme == AppTheme.dark;
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
                              context.read<SettingsBloc>().add(
                                    UpdateTerminalTheme(themeName),
                                  );
                            } catch (_) {}

                            _customThemeJsonController.clear();
                            setState(() => _customThemeError = null);
                          }
                        },
                        child: Text(l10n.applyCustomTheme),
                      ),
                      SizedBox(width: 12.w),
                      ShadButton.ghost(
                        onPressed: () {
                          _customThemeJsonController.clear();
                          setState(() => _customThemeError = null);
                        },
                        child: Text(l10n.clearCustomTheme),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Cursor Blink
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.cursorBlink,
                                style: theme.textTheme.large),
                            Text(l10n.cursorBlinkDescription,
                                style: theme.textTheme.small.copyWith(
                                    color: theme.colorScheme.mutedForeground)),
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
            Divider(height: 48.h, color: theme.colorScheme.border),
            _buildSection(
              title: l10n.fontFamily,
              description: l10n.fontFamilyDescription,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShadSelect<String>(
                    initialValue: settings.fontSettings.fontFamily,
                    placeholder: Text(l10n.fontFamily),
                    options: _uniqueFamilies.isEmpty
                        ? [
                            ShadOption(
                                value: settings.fontSettings.fontFamily,
                                child: Text(settings.fontSettings.fontFamily))
                          ]
                        : _uniqueFamilies
                            .map((f) => ShadOption(value: f, child: Text(f)))
                            .toList(),
                    selectedOptionBuilder: (context, value) => Text(value),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsBloc>().add(UpdateFontSettings(
                              settings.fontSettings.copyWith(fontFamily: value),
                            ));
                      }
                    },
                  ),
                  SizedBox(height: 16.h),
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
                  SizedBox(height: 16.h),
                  // Bold/Italic
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
                  SizedBox(height: 16.h),
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
            Divider(height: 48.h, color: theme.colorScheme.border),
            _buildSection(
                title: l10n.shellSettings,
                description: l10n.shellSettingsDescription,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Built-in shells
                    Text(l10n.defaultShell,
                        style: theme.textTheme.small.copyWith(
                            color: theme.colorScheme.mutedForeground)),
                    SizedBox(height: 8.h),
                    ShadSelect<String>(
                      initialValue: settings.defaultShell == ShellType.custom
                          ? 'custom:${settings.selectedCustomShellId ?? ''}'
                          : settings.defaultShell.name,
                      placeholder: Text(l10n.defaultShell),
                      options: [
                        // Built-in shells (excluding custom)
                        ...ShellType.values
                            .where((s) => s != ShellType.custom)
                            .map((s) => ShadOption(
                                  value: s.name,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_getShellIcon(s.icon), size: 16.sp),
                                      SizedBox(width: 8.w),
                                      Text(_getShellTypeLocalizedName(s, l10n)),
                                    ],
                                  ),
                                )),
                        // Custom shells
                        ...settings.customShells.map((shell) => ShadOption(
                              value: 'custom:${shell.id}',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_getShellIcon(shell.icon), size: 16.sp),
                                  SizedBox(width: 8.w),
                                  Text(shell.name),
                                ],
                              ),
                            )),
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
                                Icon(_getShellIcon(shell.icon), size: 16.sp),
                                SizedBox(width: 8.w),
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
                              SizedBox(width: 8.w),
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
                          final shellType = ShellType.values
                              .firstWhere((s) => s.name == value);
                          context
                              .read<SettingsBloc>()
                              .add(UpdateDefaultShell(shellType));
                        }
                      },
                    ),
                  ],
                )),
          ],
        );
      case 3: // Custom Shells
        return _buildCustomShellsContent(settings, l10n, theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCustomShellsContent(
      AppSettings settings, AppLocalizations l10n, ShadThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
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
              SizedBox(height: 16.h),
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
                        Icon(LucideIcons.terminal,
                            size: 48.sp,
                            color: theme.colorScheme.mutedForeground),
                        SizedBox(height: 12.h),
                        Text(l10n.noCustomShells, style: theme.textTheme.large),
                        SizedBox(height: 4.h),
                        Text(l10n.addYourFirstCustomShell,
                            style: theme.textTheme.small.copyWith(
                                color: theme.colorScheme.mutedForeground)),
                      ],
                    ),
                  ),
                )
              else
                ...settings.customShells.map((shell) => Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.border),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(_getShellIcon(shell.icon),
                              size: 24.sp, color: theme.colorScheme.primary),
                          SizedBox(width: 12.w),
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
                                Text(shell.path,
                                    style: theme.textTheme.small.copyWith(
                                        color:
                                            theme.colorScheme.mutedForeground),
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          // Edit button
                          ShadButton.ghost(
                            padding: EdgeInsets.zero,
                            width: 32.w,
                            height: 32.h,
                            onPressed: () => _showAddEditShellDialog(
                                context, l10n, theme,
                                existingShell: shell),
                            child: Icon(LucideIcons.pencil, size: 16.sp),
                          ),
                          // Delete button
                          ShadButton.ghost(
                            padding: EdgeInsets.zero,
                            width: 32.w,
                            height: 32.h,
                            onPressed: () =>
                                _confirmDeleteShell(context, shell, l10n),
                            child: Icon(LucideIcons.trash2,
                                size: 16.sp,
                                color: theme.colorScheme.destructive),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddEditShellDialog(
      BuildContext context, AppLocalizations l10n, ShadThemeData theme,
      {CustomShellConfig? existingShell}) {
    final nameController =
        TextEditingController(text: existingShell?.name ?? '');
    final pathController =
        TextEditingController(text: existingShell?.path ?? '');
    String selectedIcon = existingShell?.icon ?? 'terminal';

    showShadDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return ShadDialog(
            title: Text(existingShell != null
                ? l10n.editCustomShell
                : l10n.addCustomShell),
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
                  SizedBox(height: 8.h),
                  ShadInput(
                    controller: nameController,
                    placeholder: Text(l10n.shellNamePlaceholder),
                  ),
                  SizedBox(height: 16.h),

                  // Shell Path
                  Text(l10n.customShellPath, style: theme.textTheme.small),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: ShadInput(
                          controller: pathController,
                          placeholder: Text(l10n.shellPathPlaceholder),
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
                            pathController.text = result.files.single.path!;
                          }
                        },
                        child: Text(l10n.browse),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Shell Icon
                  Text(l10n.shellIcon, style: theme.textTheme.small),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 4.w,
                    runSpacing: 4.h,
                    children: [
                      'terminal',
                      'command',
                      'server',
                      'gitBranch',
                      'code',
                      'box',
                      'zap',
                      'monitor',
                    ]
                        .map((icon) => ShadButton(
                              padding: EdgeInsets.all(8.w),
                              backgroundColor: selectedIcon == icon
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              onPressed: () {
                                setDialogState(() => selectedIcon = icon);
                              },
                              child: Icon(
                                _getShellIcon(icon),
                                size: 20.sp,
                                color: selectedIcon == icon
                                    ? theme.colorScheme.primaryForeground
                                    : theme.colorScheme.foreground,
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 24.h),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.ghost(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.cancel),
                      ),
                      SizedBox(width: 8.w),
                      ShadButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final path = pathController.text.trim();
                          if (name.isEmpty || path.isEmpty) return;

                          if (existingShell != null) {
                            context.read<SettingsBloc>().add(UpdateCustomShell(
                                  existingShell.copyWith(
                                    name: name,
                                    path: path,
                                    icon: selectedIcon,
                                  ),
                                ));
                          } else {
                            context.read<SettingsBloc>().add(AddCustomShell(
                                  CustomShellConfig.create(
                                    name: name,
                                    path: path,
                                    icon: selectedIcon,
                                  ),
                                ));
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
      BuildContext context, CustomShellConfig shell, AppLocalizations l10n) {
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

  Widget _buildSection(
      {required String title, String? description, required Widget child}) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.large),
        if (description != null)
          Text(description,
              style: theme.textTheme.small
                  .copyWith(color: theme.colorScheme.mutedForeground)),
        SizedBox(height: 16.h),
        child,
      ],
    );
  }

  String _getAppThemeLocalizedName(AppTheme theme, AppLocalizations l10n) {
    switch (theme) {
      case AppTheme.dark:
        return l10n.dark;

      case AppTheme.light:
        return l10n.light;
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
