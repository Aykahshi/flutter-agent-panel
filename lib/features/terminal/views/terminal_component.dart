import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart' as xterm;
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/extensions/context_extension.dart';
import '../models/terminal_node.dart';
import '../models/terminal_theme_data.dart';
import '../services/terminal_theme_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../settings/bloc/settings_bloc.dart';

class TerminalComponent extends StatefulWidget {
  const TerminalComponent({
    super.key,
    required this.terminalNode,
    this.interactive = true,
  });
  final TerminalNode terminalNode;
  final bool interactive;

  @override
  State<TerminalComponent> createState() => _TerminalComponentState();
}

class _TerminalComponentState extends State<TerminalComponent> {
  late final FocusNode _focusNode;
  int? _lastCols;
  int? _lastRows;
  xterm.TerminalTheme? _cachedTheme;
  String? _lastThemeName;
  String? _lastCustomJson;
  Brightness? _lastBrightness;

  @override
  void initState() {
    super.initState();
    _focusNode =
        widget.interactive ? FocusNode() : FocusNode(canRequestFocus: false);

    if (widget.interactive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final settings = state.settings;
        final fontSettings = settings.fontSettings;

        final terminalStyle = xterm.TerminalStyle(
          fontFamily: fontSettings.fontFamily,
          fontSize: fontSettings.fontSize,
          fontWeight: fontSettings.isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle:
              fontSettings.isItalic ? FontStyle.italic : FontStyle.normal,
          height: 1.0,
        );

        // Check if we need to reload the theme
        final needsReload = _cachedTheme == null ||
            _lastThemeName != settings.terminalThemeName ||
            _lastCustomJson != settings.customTerminalThemeJson ||
            _lastBrightness != theme.brightness;

        if (needsReload) {
          _lastThemeName = settings.terminalThemeName;
          _lastCustomJson = settings.customTerminalThemeJson;
          _lastBrightness = theme.brightness;
          _loadTheme(
            settings.terminalThemeName,
            settings.customTerminalThemeJson,
            theme.brightness,
          );
        }

        // Use cached theme or fallback to default
        final xtermTheme = _cachedTheme ?? _getDefaultTheme(theme);

        if (settings.terminalCursorBlink !=
            widget.terminalNode.terminal.cursorBlinkMode) {
          widget.terminalNode.terminal
              .setCursorBlinkMode(settings.terminalCursorBlink);
        }

        if (widget.interactive) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              final terminal = widget.terminalNode.terminal;
              if (terminal.viewWidth > 0 && terminal.viewHeight > 0) {
                if (_lastCols != terminal.viewWidth ||
                    _lastRows != terminal.viewHeight) {
                  _lastCols = terminal.viewWidth;
                  _lastRows = terminal.viewHeight;
                  widget.terminalNode
                      .resize(terminal.viewWidth, terminal.viewHeight);
                }
              }
            }
          });
        }

        // Non-interactive (thumbnail) mode - minimal rendering
        if (!widget.interactive) {
          return xterm.TerminalView(
            widget.terminalNode.terminal,
            autofocus: false,
            readOnly: true,
            autoResize: false,
            textStyle: terminalStyle,
            theme: xtermTheme,
          );
        }

        // Interactive mode - use xterm's native input handling
        return Container(
          color: xtermTheme.background,
          padding: const EdgeInsets.all(5),
          child: GestureDetector(
            onTap: () => _focusNode.requestFocus(),
            child: xterm.TerminalView(
              widget.terminalNode.terminal,
              autofocus: true,
              autoResize: true,
              focusNode: _focusNode,
              hardwareKeyboardOnly: false,
              keyboardType: TextInputType.text,
              textStyle: terminalStyle,
              theme: xtermTheme,
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadTheme(
    String themeName,
    String? customJson,
    Brightness brightness,
  ) async {
    TerminalThemeData? themeData;

    // Try custom JSON first
    if (customJson != null && customJson.isNotEmpty) {
      try {
        final json = jsonDecode(customJson) as Map<String, dynamic>;
        themeData = TerminalThemeData.fromJson(json);
      } catch (_) {
        // Fall through to named theme
      }
    }

    // Load named theme based on brightness
    if (themeData == null) {
      final service = TerminalThemeService.instance;
      if (brightness == Brightness.light) {
        themeData = await service.getLightThemeByName(themeName) ??
            await service.getDefaultLightTheme();
      } else {
        themeData = await service.getDarkThemeByName(themeName) ??
            await service.getDefaultDarkTheme();
      }
    }

    if (mounted) {
      setState(() {
        _cachedTheme = themeData!.toXtermTheme();
      });
    }
  }

  xterm.TerminalTheme _getDefaultTheme(ShadThemeData theme) {
    // Return a simple default theme while loading
    final isLight = theme.brightness == Brightness.light;
    return xterm.TerminalTheme(
      cursor: theme.colorScheme.primary,
      selection: theme.colorScheme.primary.withValues(alpha: 0.3),
      background: isLight ? const Color(0xFFFAFAFA) : const Color(0xFF1E1E1E),
      foreground: isLight ? const Color(0xFF383A42) : const Color(0xFFCCCCCC),
      black: const Color(0xFF000000),
      red: const Color(0xFFCD3131),
      green: const Color(0xFF0DBC79),
      yellow: const Color(0xFFE5E510),
      blue: const Color(0xFF2472C8),
      magenta: const Color(0xFFBC3FBC),
      cyan: const Color(0xFF11A8CD),
      white: const Color(0xFFE5E5E5),
      brightBlack: const Color(0xFF666666),
      brightRed: const Color(0xFFF14C4C),
      brightGreen: const Color(0xFF23D18B),
      brightYellow: const Color(0xFFF5F543),
      brightBlue: const Color(0xFF3B8EEA),
      brightMagenta: const Color(0xFFD670D6),
      brightCyan: const Color(0xFF29B8DB),
      brightWhite: const Color(0xFFE5E5E5),
      searchHitBackground: const Color(0xFFE5E510),
      searchHitBackgroundCurrent: const Color(0xFF0DBC79),
      searchHitForeground: const Color(0xFF000000),
    );
  }
}
