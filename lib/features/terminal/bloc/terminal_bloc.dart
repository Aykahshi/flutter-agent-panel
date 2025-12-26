import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xterm/xterm.dart';

import '../../../shared/utils/platform_utils.dart';
import '../models/terminal_config.dart';
import '../models/terminal_node.dart';
import '../services/isolate_pty.dart';

part 'terminal_event.dart';
part 'terminal_state.dart';

/// Bloc to manage terminal instances independently from UI widgets.
/// This ensures terminal PTY connections persist across route changes.
class TerminalBloc extends Bloc<TerminalEvent, TerminalState> {
  TerminalBloc() : super(const TerminalState()) {
    on<CreateTerminal>(_onCreateTerminal);
    on<DisposeTerminal>(_onDisposeTerminal);
    on<RestartTerminal>(_onRestartTerminal);
    on<SyncWorkspaceTerminals>(_onSyncWorkspaceTerminals);
    on<TerminalOutputReceived>(_onTerminalOutputReceived);
    on<ClearRestartingState>(_onClearRestartingState);
  }

  Future<void> _onCreateTerminal(
    CreateTerminal event,
    Emitter<TerminalState> emit,
  ) async {
    final config = event.config;
    final workspaceId = event.workspaceId;

    // Skip if already exists or pending
    if (state.terminals.containsKey(config.id) ||
        state.pendingIds.contains(config.id)) {
      return;
    }

    // Mark as pending
    emit(
      state.copyWith(
        pendingIds: {...state.pendingIds, config.id},
      ),
    );

    try {
      final node = await _createTerminalNode(config, workspaceId);
      if (node != null) {
        emit(
          state.copyWith(
            terminals: {...state.terminals, config.id: node},
            pendingIds: state.pendingIds.where((id) => id != config.id).toSet(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to create terminal: $e');
      emit(
        state.copyWith(
          pendingIds: state.pendingIds.where((id) => id != config.id).toSet(),
        ),
      );
    }
  }

  void _onDisposeTerminal(
    DisposeTerminal event,
    Emitter<TerminalState> emit,
  ) {
    final node = state.terminals[event.terminalId];
    if (node != null) {
      node.dispose();
      final newTerminals = Map<String, TerminalNode>.from(state.terminals)
        ..remove(event.terminalId);
      emit(state.copyWith(terminals: newTerminals));
    }
  }

  Future<void> _onRestartTerminal(
    RestartTerminal event,
    Emitter<TerminalState> emit,
  ) async {
    // Mark as restarting
    emit(
      state.copyWith(
        restartingIds: {...state.restartingIds, event.terminalId},
      ),
    );

    // Dispose old node
    final oldNode = state.terminals[event.terminalId];
    if (oldNode != null) {
      oldNode.dispose();
      final newTerminals = Map<String, TerminalNode>.from(state.terminals)
        ..remove(event.terminalId);
      emit(state.copyWith(terminals: newTerminals));
    }

    // Delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 500));

    // Create new node
    try {
      final node = await _createTerminalNode(event.config, event.workspaceId);
      if (node != null) {
        emit(
          state.copyWith(
            terminals: {...state.terminals, event.terminalId: node},
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to restart terminal: $e');
      emit(
        state.copyWith(
          restartingIds:
              state.restartingIds.where((id) => id != event.terminalId).toSet(),
        ),
      );
    }
  }

  Future<void> _onSyncWorkspaceTerminals(
    SyncWorkspaceTerminals event,
    Emitter<TerminalState> emit,
  ) async {
    // Remove terminals that no longer exist in any workspace
    final currentTerminals = Map<String, TerminalNode>.from(state.terminals);
    final toRemove = <String>[];

    for (final id in currentTerminals.keys) {
      if (!event.allTerminalIds.contains(id)) {
        currentTerminals[id]?.dispose();
        toRemove.add(id);
        debugPrint('Disposing terminal $id (removed from config)');
      }
    }

    for (final id in toRemove) {
      currentTerminals.remove(id);
    }

    if (toRemove.isNotEmpty) {
      emit(state.copyWith(terminals: currentTerminals));
    }

    // Create terminals for current workspace that don't exist yet
    for (final config in event.configs) {
      if (!state.terminals.containsKey(config.id) &&
          !state.pendingIds.contains(config.id)) {
        add(CreateTerminal(config: config, workspaceId: event.workspaceId));
      } else {
        // Update title/icon if changed
        final node = state.terminals[config.id];
        if (node != null) {
          if (node.title != config.title) {
            node.title = config.title;
          }
          if (node.icon != config.icon) {
            node.icon = config.icon;
          }
        }
      }
    }
  }

  void _onTerminalOutputReceived(
    TerminalOutputReceived event,
    Emitter<TerminalState> emit,
  ) {
    final node = state.terminals[event.terminalId];
    if (node != null && !node.hasOutput) {
      node.hasOutput = true;
      // Clear restarting state when output is received
      if (state.restartingIds.contains(event.terminalId)) {
        emit(
          state.copyWith(
            restartingIds: state.restartingIds
                .where((id) => id != event.terminalId)
                .toSet(),
          ),
        );
      } else {
        // Force a state update to trigger UI rebuild
        emit(
          state.copyWith(
            terminals: Map<String, TerminalNode>.from(state.terminals),
          ),
        );
      }
    }
  }

  void _onClearRestartingState(
    ClearRestartingState event,
    Emitter<TerminalState> emit,
  ) {
    if (state.restartingIds.contains(event.terminalId)) {
      emit(
        state.copyWith(
          restartingIds:
              state.restartingIds.where((id) => id != event.terminalId).toSet(),
        ),
      );
    }
  }

  Future<TerminalNode?> _createTerminalNode(
    TerminalConfig config,
    String workspaceId,
  ) async {
    final terminal = Terminal(maxLines: 10000);

    // Determine shell and arguments
    String shell;
    List<String> ptyArgs;

    if (config.agentId != null && config.agentId!.isNotEmpty) {
      // Agent terminal: wrap command in shell
      shell = PlatformUtils.isWindows ? 'pwsh.exe' : '/bin/bash';
      if (PlatformUtils.isWindows) {
        ptyArgs = [
          '-NoLogo',
          '-NoExit',
          '-Command',
          config.shellCmd,
          ...config.args,
        ];
      } else {
        ptyArgs = ['-c', config.shellCmd, ...config.args];
      }
    } else {
      // Normal terminal
      shell = config.shellCmd.isNotEmpty
          ? config.shellCmd
          : (PlatformUtils.isWindows ? 'pwsh.exe' : '/bin/bash');
      ptyArgs = config.args;
    }

    final cwd = config.cwd.isNotEmpty ? config.cwd : Directory.current.path;

    final pty = await IsolatePty.start(
      shell,
      arguments: ptyArgs,
      workingDirectory: cwd,
      environment: {
        'TERM': 'xterm-256color',
        'COLORTERM': 'truecolor',
        ...Platform.environment,
      },
    );

    final node = TerminalNode(
      id: config.id,
      workspaceId: workspaceId,
      title: config.title,
      terminal: terminal,
      pty: pty,
      icon: config.icon,
      onStatusChanged: () {
        // Emit state change to trigger UI updates
        // This is handled via stream listeners in the widget
      },
    );

    // Setup PTY -> Terminal (Output)
    pty.output
        .cast<List<int>>()
        .transform(const Utf8Decoder(allowMalformed: true))
        .listen((data) {
      terminal.write(data);
      if (data.isNotEmpty) {
        if (!node.hasOutput) {
          add(TerminalOutputReceived(terminalId: config.id));
        }
        node.markActivity();
      }
    });

    // Setup Terminal -> PTY (Input)
    terminal.onOutput = (data) {
      pty.write(const Utf8Encoder().convert(data));
    };

    return node;
  }

  @override
  Future<void> close() {
    // Dispose all terminals when bloc is closed
    for (final node in state.terminals.values) {
      node.dispose();
    }
    return super.close();
  }
}
