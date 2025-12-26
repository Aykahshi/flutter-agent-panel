part of 'terminal_bloc.dart';

abstract class TerminalEvent extends Equatable {
  const TerminalEvent();

  @override
  List<Object?> get props => [];
}

/// Request to create a new terminal for a workspace
class CreateTerminal extends TerminalEvent {
  const CreateTerminal({
    required this.config,
    required this.workspaceId,
  });

  final TerminalConfig config;
  final String workspaceId;

  @override
  List<Object?> get props => [config, workspaceId];
}

/// Request to dispose a terminal
class DisposeTerminal extends TerminalEvent {
  const DisposeTerminal({required this.terminalId});

  final String terminalId;

  @override
  List<Object?> get props => [terminalId];
}

/// Request to restart a terminal
class RestartTerminal extends TerminalEvent {
  const RestartTerminal({
    required this.terminalId,
    required this.config,
    required this.workspaceId,
  });

  final String terminalId;
  final TerminalConfig config;
  final String workspaceId;

  @override
  List<Object?> get props => [terminalId, config, workspaceId];
}

/// Sync terminal nodes with workspace state
class SyncWorkspaceTerminals extends TerminalEvent {
  const SyncWorkspaceTerminals({
    required this.workspaceId,
    required this.configs,
    required this.allTerminalIds,
  });

  final String workspaceId;
  final List<TerminalConfig> configs;
  final Set<String> allTerminalIds;

  @override
  List<Object?> get props => [workspaceId, configs, allTerminalIds];
}

/// Mark terminal as having output (ready)
class TerminalOutputReceived extends TerminalEvent {
  const TerminalOutputReceived({required this.terminalId});

  final String terminalId;

  @override
  List<Object?> get props => [terminalId];
}

/// Clear restarting state for a terminal
class ClearRestartingState extends TerminalEvent {
  const ClearRestartingState({required this.terminalId});

  final String terminalId;

  @override
  List<Object?> get props => [terminalId];
}
