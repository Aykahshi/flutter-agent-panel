import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:signals/signals_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:xterm/xterm.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import '../../../../core/viewmodels/base_viewmodel.dart';
import '../../../../core/services/terminal_service.dart';
import '../models/terminal_node.dart';

class TerminalViewModel extends BaseViewModel {
  // We can make this a singleton for Global terminal management or scoped.
  // Given the requirement "persistent sessions", global seems appropriate
  // or attached to Workspace scope. For simplicity, let's make it Singleton linked to workspaces later.
  static final TerminalViewModel _instance = TerminalViewModel._internal();
  factory TerminalViewModel() => _instance;
  TerminalViewModel._internal();

  final TerminalService _terminalService = TerminalServiceImpl();

  final _terminals = signal<IList<TerminalNode>>(IList<TerminalNode>());
  ReadonlySignal<IList<TerminalNode>> get terminals => _terminals;

  final _activeTerminalId = signal<String?>(null);
  ReadonlySignal<String?> get activeTerminalId => _activeTerminalId;

  void createTerminal({
    required String workspaceId,
    String? workingDirectory,
    String title = 'Terminal',
  }) {
    final id = const Uuid().v4();
    final terminal = Terminal(maxLines: 10000);

    // Start PTY
    // Input/Output handling is usually connected in the View or here.
    // Ideally View connects Terminal widget to Pty.
    // But model needs to hold the Pty to keep it alive.

    final pty = _terminalService.startPty(
      '',
      [],
      workingDirectory: workingDirectory,
    );

    // Synchronize initial size
    // We wait a tiny bit for the shell to start before first resize
    Future.delayed(const Duration(milliseconds: 50), () {
      if (terminal.viewWidth > 0 && terminal.viewHeight > 0) {
        pty.resize(terminal.viewHeight, terminal.viewWidth);
      }
    });

    // Pipe PTY output to Terminal
    pty.output.listen(
      (data) {
        terminal.write(const Utf8Decoder(allowMalformed: true).convert(data));
      },
      onError: (e) {
        debugPrint('PTY Error: $e');
        terminal.write('\r\n[PTY Error: $e]\r\n');
      },
      onDone: () {
        debugPrint('PTY Closed');
        terminal.write('\r\n[PTY Closed]\r\n');
      },
    );

    // Pipe Terminal input to PTY
    terminal.onOutput = (data) {
      pty.write(const Utf8Encoder().convert(data));
    };

    // Fix Layout: Sync Terminal resize with PTY
    terminal.onResize = (width, height, pixelWidth, pixelHeight) {
      debugPrint('Terminal Resize: $width x $height');
      pty.resize(height, width); // flutter_pty uses (rows, cols)
    };

    final node = TerminalNode(
      id: id,
      workspaceId: workspaceId,
      title: title,
      pty: pty,
      terminal: terminal,
    );

    _terminals.value = _terminals.value.add(node);
    setActiveTerminal(id);
  }

  void setActiveTerminal(String id) {
    _activeTerminalId.value = id;
  }

  IList<TerminalNode> getWorkspaceTerminals(String workspaceId) {
    return _terminals.value
        .where((t) => t.workspaceId == workspaceId)
        .toIList();
  }

  void closeTerminal(String id) {
    final node = _terminals.value.firstWhereOrNull((t) => t.id == id);
    if (node != null) {
      node.dispose();
      _terminals.value = _terminals.value.removeWhere((t) => t.id == id);
      if (_activeTerminalId.value == id) {
        _activeTerminalId.value = _terminals.value.isNotEmpty
            ? _terminals.value.last.id
            : null;
      }
    }
  }
}
