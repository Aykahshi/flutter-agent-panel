part of 'workspace_bloc.dart';

class WorkspaceState extends Equatable {
  final List<Workspace> workspaces;
  final String? selectedWorkspaceId;

  const WorkspaceState({
    this.workspaces = const [],
    this.selectedWorkspaceId,
  });

  Workspace? get selectedWorkspace {
    if (selectedWorkspaceId == null) return null;
    try {
      return workspaces.firstWhere((w) => w.id == selectedWorkspaceId);
    } catch (_) {
      return null;
    }
  }

  WorkspaceState copyWith({
    List<Workspace>? workspaces,
    String? selectedWorkspaceId,
  }) {
    return WorkspaceState(
      workspaces: workspaces ?? this.workspaces,
      selectedWorkspaceId: selectedWorkspaceId ?? this.selectedWorkspaceId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workspaces': workspaces.map((e) => e.toJson()).toList(),
      'selectedWorkspaceId': selectedWorkspaceId,
    };
  }

  factory WorkspaceState.fromJson(Map<String, dynamic> json) {
    return WorkspaceState(
      workspaces: (json['workspaces'] as List<dynamic>?)
              ?.map((e) => Workspace.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      selectedWorkspaceId: json['selectedWorkspaceId'] as String?,
    );
  }

  @override
  List<Object?> get props => [workspaces, selectedWorkspaceId];
}
