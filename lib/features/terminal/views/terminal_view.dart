import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart' as xterm;
import '../models/terminal_node.dart';
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

  @override
  void initState() {
    super.initState();
    _focusNode = widget.interactive
        ? FocusNode()
        : FocusNode(canRequestFocus: false);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.interactive) {
      // Ensure focus is requested after the first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      });

      // Fix Layout: Some xterm versions have a race condition on the first layout.
      // We trigger a manual resize check after a short delay as a safety net.
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          final terminal = widget.terminalNode.terminal;
          // If the terminal thinks it's still 80x24 but the view is large,
          // or if the PTY side hasn't been notified yet.
          // Note: Rendering logic in xterm should have updated terminal.viewWidth/Height
          // if autoResize is true. We just force a sync here.
          if (terminal.viewWidth > 0 && terminal.viewHeight > 0) {
            widget.terminalNode.resize(terminal.viewWidth, terminal.viewHeight);
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
        textStyle: const xterm.TerminalStyle(
          fontFamily: 'Consolas',
          fontSize: 14,
        ),
        theme: _getTheme(),
      );
    }

    // Interactive mode - use xterm's native input handling
    // This delegates ALL input (including IME) to xterm's proven implementation
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: xterm.TerminalView(
        widget.terminalNode.terminal,
        focusNode: _focusNode,
        autofocus: true,
        autoResize: true, // Let xterm handle PTY resize automatically
        textStyle: const xterm.TerminalStyle(
          fontFamily: 'Consolas',
          fontSize: 14,
        ),
        theme: _getTheme(),
        hardwareKeyboardOnly: false, // Enable full IME support
        keyboardType: TextInputType.text, // Better for general text input
      ),
    );
  }

  xterm.TerminalTheme _getTheme() {
    return const xterm.TerminalTheme(
      cursor: AppColors.primary,
      selection: Color(0xFF264F78),
      foreground: Color(0xFFCCCCCC),
      background: AppColors.terminalBackground,
      black: Color(0xFF000000),
      red: Color(0xFFCD3131),
      green: Color(0xFF0DBC79),
      yellow: Color(0xFFE5E510),
      blue: Color(0xFF2472C8),
      magenta: Color(0xFFBC3FBC),
      cyan: Color(0xFF11A8CD),
      white: Color(0xFFE5E5E5),
      brightBlack: Color(0xFF666666),
      brightRed: Color(0xFFF14C4C),
      brightGreen: Color(0xFF23D18B),
      brightYellow: Color(0xFFF5F543),
      brightBlue: Color(0xFF3B8EEA),
      brightMagenta: Color(0xFFD670D6),
      brightCyan: Color(0xFF29B8DB),
      brightWhite: Color(0xFFE5E5E5),
      searchHitBackground: Color(0xFFE5E510),
      searchHitBackgroundCurrent: Color(0xFF0DBC79),
      searchHitForeground: Color(0xFF000000),
    );
  }
}
