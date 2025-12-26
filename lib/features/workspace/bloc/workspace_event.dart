part of 'workspace_bloc.dart';

abstract class WorkspaceEvent extends Equatable {
  const WorkspaceEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkspaces extends WorkspaceEvent {}

class AddWorkspace extends WorkspaceEvent {
  const AddWorkspace({
    required this.path,
    required this.name,
    this.icon,
    this.tags = const [],
  });
  final String path;
  final String name;
  final String? icon;
  final List<String> tags;

  @override
  List<Object?> get props => [path, name, icon, tags];
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

class UpdateWorkspace extends WorkspaceEvent {
  const UpdateWorkspace({
    required this.id,
    this.name,
    this.icon,
    this.tags,
  });
  final String id;
  final String? name;
  final String? icon;
  final List<String>? tags;

  @override
  List<Object?> get props => [id, name, icon, tags];
}

class TogglePinWorkspace extends WorkspaceEvent {
  const TogglePinWorkspace(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class ReorderWorkspaces extends WorkspaceEvent {
  const ReorderWorkspaces({
    required this.oldIndex,
    required this.newIndex,
  });
  final int oldIndex;
  final int newIndex;

  @override
  List<Object?> get props => [oldIndex, newIndex];
}
