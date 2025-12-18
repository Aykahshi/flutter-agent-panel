import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';

class TerminalNode {
  final String id;
  final String workspaceId;
  String title;
  final Pty pty;
  final Terminal terminal;
  bool isDisposed = false;

  TerminalNode({
    required this.id,
    required this.workspaceId,
    required this.title,
    required this.pty,
    required this.terminal,
  });

  void resize(int cols, int rows) {
    pty.resize(rows, cols);
  }

  void dispose() {
    if (isDisposed) return;
    isDisposed = true;
    pty.kill();
    // terminal doesn't necessarily need dispose if managed by widget, but clear is good
    terminal.buffer.clear();
  }
}
