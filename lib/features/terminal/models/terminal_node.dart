import 'dart:async';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';

/// Terminal activity status for visual indicators
enum TerminalStatus {
  /// Command is executing (orange glow)
  running,

  /// Shell is ready for input (green glow)
  idle,

  /// Last command returned non-zero exit code (red glow)
  error,

  /// Terminal process terminated (gray)
  disconnected,

  /// Terminal is restarting (blue glow)
  restarting,
}

class TerminalNode {
  final String id;
  final String workspaceId;
  String title;
  String? icon;
  final Pty pty;
  final Terminal terminal;
  bool isDisposed = false;

  /// Current activity status
  TerminalStatus status = TerminalStatus.idle;

  /// Timestamp of last output activity
  DateTime lastActivity = DateTime.now();

  /// Timer to reset status to idle
  Timer? _activityTimer;

  /// Callback for UI updates when status changes
  void Function()? onStatusChanged;

  TerminalNode({
    required this.id,
    required this.workspaceId,
    required this.title,
    required this.pty,
    required this.terminal,
    this.icon,
    this.onStatusChanged,
  });

  void resize(int cols, int rows) {
    pty.resize(rows, cols);
  }

  /// Mark terminal as having output activity
  void markActivity([Duration idleTimeout = const Duration(seconds: 2)]) {
    lastActivity = DateTime.now();

    final oldStatus = status;
    status = TerminalStatus.running;

    if (oldStatus != TerminalStatus.running) {
      onStatusChanged?.call();
    }

    _activityTimer?.cancel();
    _activityTimer = Timer(idleTimeout, () {
      markIdle();
    });
  }

  /// Mark terminal as idle (no output for a while)
  void markIdle() {
    if (status == TerminalStatus.running) {
      status = TerminalStatus.idle;
      _activityTimer?.cancel();
      _activityTimer = null;
      onStatusChanged?.call();
    }
  }

  void dispose() {
    if (isDisposed) return;
    isDisposed = true;
    _activityTimer?.cancel();
    status = TerminalStatus.disconnected;
    pty.kill();
    // terminal doesn't necessarily need dispose if managed by widget, but clear is good
    terminal.buffer.clear();
  }
}
