part of 'workspace_bloc.dart';

abstract class WorkspaceEvent extends Equatable {
  const WorkspaceEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkspaces extends WorkspaceEvent {}

class AddWorkspace extends WorkspaceEvent {
  final String path;
  final String name;

  const AddWorkspace({required this.path, required this.name});

  @override
  List<Object?> get props => [path, name];
}

class RemoveWorkspace extends WorkspaceEvent {
  final String id;

  const RemoveWorkspace(this.id);

  @override
  List<Object?> get props => [id];
}

class SelectWorkspace extends WorkspaceEvent {
  final String id;

  const SelectWorkspace(this.id);

  @override
  List<Object?> get props => [id];
}

class AddTerminalToWorkspace extends WorkspaceEvent {
  final String workspaceId;
  final TerminalConfig config;

  const AddTerminalToWorkspace(
      {required this.workspaceId, required this.config});

  @override
  List<Object?> get props => [workspaceId, config];
}

class RemoveTerminalFromWorkspace extends WorkspaceEvent {
  final String workspaceId;
  final String terminalId;

  const RemoveTerminalFromWorkspace(
      {required this.workspaceId, required this.terminalId});

  @override
  List<Object?> get props => [workspaceId, terminalId];
}

class UpdateTerminalInWorkspace extends WorkspaceEvent {
  final String workspaceId;
  final TerminalConfig config;

  const UpdateTerminalInWorkspace(
      {required this.workspaceId, required this.config});

  @override
  List<Object?> get props => [workspaceId, config];
}

class ReorderTerminalsInWorkspace extends WorkspaceEvent {
  final String workspaceId;
  final int oldIndex;
  final int newIndex;

  const ReorderTerminalsInWorkspace({
    required this.workspaceId,
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [workspaceId, oldIndex, newIndex];
}
