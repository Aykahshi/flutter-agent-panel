import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart' as xterm;
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/terminal_node.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../settings/bloc/settings_bloc.dart';
import '../../settings/models/app_settings.dart';
import '../../../../shared/constants/app_colors.dart';

class TerminalView extends StatefulWidget {
  final TerminalNode terminalNode;
  final bool interactive;

  const TerminalView({
    super.key,
    required this.terminalNode,
    this.interactive = true,
  });

  @override
  State<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> {
  late final FocusNode _focusNode;
  int? _lastCols;
  int? _lastRows;

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
    final theme = ShadTheme.of(context);

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
          // Note: fontWeight and fontStyle are now used globally by TerminalStyle
        );

        final xtermTheme = _getTerminalTheme(settings.terminalTheme, theme);

        if (widget.interactive) {
          // Fix Layout: Some xterm versions have a race condition on the first layout.
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
            autoResize: false, // CRITICAL: Thumbnail must not resize PTY
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

  xterm.TerminalTheme _getTerminalTheme(
      TerminalTheme themeType, ShadThemeData theme) {
    // Shared common colors
    const defaultSearchHit = Color(0xFFE5E510);
    const defaultSearchHitCurrent = Color(0xFF0DBC79);
    const defaultSearchHitForeground = Color(0xFF000000);

    switch (themeType) {
      case TerminalTheme.oneDark:
        return xterm.TerminalTheme(
          cursor: theme.colorScheme.primary,
          selection: theme.colorScheme.primary.withValues(alpha: 0.3),
          background: const Color(0xFF282C34),
          foreground: const Color(0xFFABB2BF),
          black: const Color(0xFF282C34),
          red: const Color(0xFFE06C75),
          green: const Color(0xFF98C379),
          yellow: const Color(0xFFE5C07B),
          blue: const Color(0xFF61AFEF),
          magenta: const Color(0xFFC678DD),
          cyan: const Color(0xFF56B6C2),
          white: const Color(0xFFABB2BF),
          brightBlack: const Color(0xFF5C6370),
          brightRed: const Color(0xFFE06C75),
          brightGreen: const Color(0xFF98C379),
          brightYellow: const Color(0xFFE5C07B),
          brightBlue: const Color(0xFF61AFEF),
          brightMagenta: const Color(0xFFC678DD),
          brightCyan: const Color(0xFF56B6C2),
          brightWhite: const Color(0xFFFFFFFF),
          searchHitBackground: defaultSearchHit,
          searchHitBackgroundCurrent: defaultSearchHitCurrent,
          searchHitForeground: defaultSearchHitForeground,
        );
      case TerminalTheme.dracula:
        return xterm.TerminalTheme(
          cursor: theme.colorScheme.primary,
          selection: theme.colorScheme.primary.withValues(alpha: 0.3),
          background: const Color(0xFF282A36),
          foreground: const Color(0xFFF8F8F2),
          black: const Color(0xFF21222C),
          red: const Color(0xFFFF5544),
          green: const Color(0xFF50FA7B),
          yellow: const Color(0xFFF1FA8C),
          blue: const Color(0xFFBD93F9),
          magenta: const Color(0xFFFF79C6),
          cyan: const Color(0xFF8BE9FD),
          white: const Color(0xFFF8F8F2),
          brightBlack: const Color(0xFF6272A4),
          brightRed: const Color(0xFFFF6E6E),
          brightGreen: const Color(0xFF69FF94),
          brightYellow: const Color(0xFFFFFFA5),
          brightBlue: const Color(0xFFD6ACFF),
          brightMagenta: const Color(0xFFFF92DF),
          brightCyan: const Color(0xFFA4FFFF),
          brightWhite: const Color(0xFFFFFFFF),
          searchHitBackground: defaultSearchHit,
          searchHitBackgroundCurrent: defaultSearchHitCurrent,
          searchHitForeground: defaultSearchHitForeground,
        );
      case TerminalTheme.monokai:
        return xterm.TerminalTheme(
          cursor: theme.colorScheme.primary,
          selection: theme.colorScheme.primary.withValues(alpha: 0.3),
          background: const Color(0xFF272822),
          foreground: const Color(0xFFF8F8F2),
          black: const Color(0xFF272822),
          red: const Color(0xFFF92672),
          green: const Color(0xFFA6E22E),
          yellow: const Color(0xFFF4BF75),
          blue: const Color(0xFF66D9EF),
          magenta: const Color(0xFFAE81FF),
          cyan: const Color(0xFFA1EFE4),
          white: const Color(0xFFF8F8F2),
          brightBlack: const Color(0xFF75715E),
          brightRed: const Color(0xFFF92672),
          brightGreen: const Color(0xFFA6E22E),
          brightYellow: const Color(0xFFE6DB74),
          brightBlue: const Color(0xFF66D9EF),
          brightMagenta: const Color(0xFFAE81FF),
          brightCyan: const Color(0xFFA1EFE4),
          brightWhite: const Color(0xFFF8F8F2),
          searchHitBackground: defaultSearchHit,
          searchHitBackgroundCurrent: defaultSearchHitCurrent,
          searchHitForeground: defaultSearchHitForeground,
        );
      default:
        // Default One Dark variation
        return xterm.TerminalTheme(
          cursor: theme.colorScheme.primary,
          selection: theme.colorScheme.primary.withOpacity(0.3),
          foreground: const Color(0xFFCCCCCC),
          background: AppColors.terminalBackground,
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
          searchHitBackground: defaultSearchHit,
          searchHitBackgroundCurrent: defaultSearchHitCurrent,
          searchHitForeground: defaultSearchHitForeground,
        );
    }
  }
}
