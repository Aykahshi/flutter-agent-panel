import 'package:collection/collection.dart';
import 'package:signals/signals_flutter.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import '../../../../core/viewmodels/base_viewmodel.dart';
import '../models/workspace.dart';

class WorkspaceViewModel extends BaseViewModel {
  // Singleton pattern for global state
  static final WorkspaceViewModel _instance = WorkspaceViewModel._internal();
  factory WorkspaceViewModel() => _instance;
  WorkspaceViewModel._internal();

  final _workspaces = signal<IList<Workspace>>(IList<Workspace>());
  ReadonlySignal<IList<Workspace>> get workspaces => _workspaces;

  final _activeWorkspaceId = signal<String?>(null);
  ReadonlySignal<String?> get activeWorkspaceId => _activeWorkspaceId;

  // Derived signal for active workspace
  late final activeWorkspace = computed(() {
    final id = _activeWorkspaceId.value;
    if (id == null) return null;
    return _workspaces.value.firstWhereOrNull((w) => w.id == id);
  });

  void addWorkspace(String name, String path) {
    final newWorkspace = Workspace.create(name: name, path: path);
    _workspaces.value = _workspaces.value.add(newWorkspace);

    // If it's the first workspace, make it active
    if (_workspaces.value.length == 1) {
      _activeWorkspaceId.value = newWorkspace.id;
    }
  }

  void setActiveWorkspace(String id) {
    _activeWorkspaceId.value = id;
  }

  void removeWorkspace(String id) {
    _workspaces.value = _workspaces.value.removeWhere((w) => w.id == id);
    if (_activeWorkspaceId.value == id) {
      _activeWorkspaceId.value = _workspaces.value.isNotEmpty
          ? _workspaces.value.first.id
          : null;
    }
  }
}
