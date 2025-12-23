part of 'workspace_bloc.dart';

abstract class WorkspaceEvent extends Equatable {
  const WorkspaceEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkspaces extends WorkspaceEvent {}

class AddWorkspace extends WorkspaceEvent {
  const AddWorkspace({required this.path, required this.name});
  final String path;
  final String name;

  @override
  List<Object?> get props => [path, name];
}

class RemoveWorkspace extends WorkspaceEvent {
  const RemoveWorkspace(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class SelectWorkspace extends WorkspaceEvent {
  const SelectWorkspace(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class AddTerminalToWorkspace extends WorkspaceEvent {
  const AddTerminalToWorkspace({
    required this.workspaceId,
    required this.config,
  });
  final String workspaceId;
  final TerminalConfig config;

  @override
  List<Object?> get props => [workspaceId, config];
}

class RemoveTerminalFromWorkspace extends WorkspaceEvent {
  const RemoveTerminalFromWorkspace({
    required this.workspaceId,
    required this.terminalId,
  });
  final String workspaceId;
  final String terminalId;

  @override
  List<Object?> get props => [workspaceId, terminalId];
}

class UpdateTerminalInWorkspace extends WorkspaceEvent {
  const UpdateTerminalInWorkspace({
    required this.workspaceId,
    required this.config,
  });
  final String workspaceId;
  final TerminalConfig config;

  @override
  List<Object?> get props => [workspaceId, config];
}

class ReorderTerminalsInWorkspace extends WorkspaceEvent {
  const ReorderTerminalsInWorkspace({
    required this.workspaceId,
    required this.oldIndex,
    required this.newIndex,
  });
  final String workspaceId;
  final int oldIndex;
  final int newIndex;

  @override
  List<Object?> get props => [workspaceId, oldIndex, newIndex];
}
