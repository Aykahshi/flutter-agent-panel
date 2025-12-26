import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../models/workspace.dart';
import '../../terminal/models/terminal_config.dart';

part 'workspace_event.dart';
part 'workspace_state.dart';

class WorkspaceBloc extends HydratedBloc<WorkspaceEvent, WorkspaceState> {
  WorkspaceBloc() : super(const WorkspaceState()) {
    on<AddWorkspace>(_onAddWorkspace);
    on<RemoveWorkspace>(_onRemoveWorkspace);
    on<SelectWorkspace>(_onSelectWorkspace);
    on<AddTerminalToWorkspace>(_onAddTerminal);
    on<RemoveTerminalFromWorkspace>(_onRemoveTerminal);
    on<UpdateTerminalInWorkspace>(_onUpdateTerminal);
    on<ReorderTerminalsInWorkspace>(_onReorderTerminals);
    on<UpdateWorkspace>(_onUpdateWorkspace);
    on<TogglePinWorkspace>(_onTogglePinWorkspace);
    on<ReorderWorkspaces>(_onReorderWorkspaces);
  }

  void _onAddWorkspace(AddWorkspace event, Emitter<WorkspaceState> emit) {
    final newWorkspace = Workspace.create(
      path: event.path,
      name: event.name,
      icon: event.icon,
      tags: event.tags,
    );
    final updatedWorkspaces = List<Workspace>.from(state.workspaces)
      ..add(newWorkspace);

    emit(
      state.copyWith(
        workspaces: updatedWorkspaces,
        selectedWorkspaceId: state.selectedWorkspaceId ??
            newWorkspace.id, // Auto-select if none selected
      ),
    );
  }

  void _onRemoveWorkspace(RemoveWorkspace event, Emitter<WorkspaceState> emit) {
    final updatedWorkspaces =
        state.workspaces.where((w) => w.id != event.id).toList();
    String? newSelectedId = state.selectedWorkspaceId;
    if (state.selectedWorkspaceId == event.id) {
      newSelectedId =
          updatedWorkspaces.isNotEmpty ? updatedWorkspaces.first.id : null;
    }
    emit(
      WorkspaceState(
        workspaces: updatedWorkspaces,
        selectedWorkspaceId: newSelectedId,
      ),
    );
  }

  void _onSelectWorkspace(SelectWorkspace event, Emitter<WorkspaceState> emit) {
    if (state.workspaces.any((w) => w.id == event.id)) {
      emit(
        WorkspaceState(
          workspaces: state.workspaces,
          selectedWorkspaceId: event.id,
        ),
      );
    }
  }

  void _onAddTerminal(
    AddTerminalToWorkspace event,
    Emitter<WorkspaceState> emit,
  ) {
    _updateWorkspace(event.workspaceId, emit, (workspace) {
      final updatedTerminals = List<TerminalConfig>.from(workspace.terminals)
        ..add(event.config);
      return workspace.copyWith(terminals: updatedTerminals);
    });
  }

  void _onRemoveTerminal(
    RemoveTerminalFromWorkspace event,
    Emitter<WorkspaceState> emit,
  ) {
    _updateWorkspace(event.workspaceId, emit, (workspace) {
      final updatedTerminals =
          workspace.terminals.where((t) => t.id != event.terminalId).toList();
      return workspace.copyWith(terminals: updatedTerminals);
    });
  }

  void _onUpdateTerminal(
    UpdateTerminalInWorkspace event,
    Emitter<WorkspaceState> emit,
  ) {
    _updateWorkspace(event.workspaceId, emit, (workspace) {
      final updatedTerminals = workspace.terminals.map((t) {
        return t.id == event.config.id ? event.config : t;
      }).toList();
      return workspace.copyWith(terminals: updatedTerminals);
    });
  }

  void _onReorderTerminals(
    ReorderTerminalsInWorkspace event,
    Emitter<WorkspaceState> emit,
  ) {
    _updateWorkspace(event.workspaceId, emit, (workspace) {
      final terminals = List<TerminalConfig>.from(workspace.terminals);
      var newIndex = event.newIndex;
      if (event.oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = terminals.removeAt(event.oldIndex);
      terminals.insert(newIndex, item);
      return workspace.copyWith(terminals: terminals);
    });
  }

  void _onUpdateWorkspace(
    UpdateWorkspace event,
    Emitter<WorkspaceState> emit,
  ) {
    final index = state.workspaces.indexWhere((w) => w.id == event.id);
    if (index == -1) return;

    final workspaces = List<Workspace>.from(state.workspaces);
    final current = workspaces[index];
    workspaces[index] = current.copyWith(
      name: event.name ?? current.name,
      icon: event.icon ?? current.icon,
      tags: event.tags ?? current.tags,
    );

    emit(state.copyWith(workspaces: workspaces));
  }

  void _onTogglePinWorkspace(
    TogglePinWorkspace event,
    Emitter<WorkspaceState> emit,
  ) {
    final index = state.workspaces.indexWhere((w) => w.id == event.id);
    if (index == -1) return;

    final workspaces = List<Workspace>.from(state.workspaces);
    final current = workspaces[index];
    workspaces[index] = current.copyWith(isPinned: !current.isPinned);

    // Sort: pinned items first, maintain relative order within groups
    workspaces.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });

    emit(state.copyWith(workspaces: workspaces));
  }

  void _onReorderWorkspaces(
    ReorderWorkspaces event,
    Emitter<WorkspaceState> emit,
  ) {
    final workspaces = List<Workspace>.from(state.workspaces);
    var newIndex = event.newIndex;
    if (event.oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = workspaces.removeAt(event.oldIndex);
    workspaces.insert(newIndex, item);
    emit(state.copyWith(workspaces: workspaces));
  }

  void _updateWorkspace(
    String workspaceId,
    Emitter<WorkspaceState> emit,
    Workspace Function(Workspace) updater,
  ) {
    final index = state.workspaces.indexWhere((w) => w.id == workspaceId);
    if (index == -1) return;

    final workspaces = List<Workspace>.from(state.workspaces);
    workspaces[index] = updater(workspaces[index]);

    emit(state.copyWith(workspaces: workspaces));
  }

  @override
  WorkspaceState? fromJson(Map<String, dynamic> json) {
    return WorkspaceState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(WorkspaceState state) {
    return state.toJson();
  }
}
