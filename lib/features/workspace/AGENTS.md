# lib/features/workspace - AGENT GUIDE

## OVERVIEW
Handles workspace management and terminal persistence.

## STRUCTURE
```
workspace
├── bloc/                # Workspace Bloc (state management)
│   ├── workspace_bloc.dart
│   ├── workspace_event.dart
│   └── workspace_state.dart
├── models/             # Workspace data models
│   └── workspace.dart
├── views/              # Screens and layouts
│   ├── workspace_view.dart
│   ├── workspace_wrapper_view.dart
│   └── workspace_drawer.dart
└── widgets/            # Modular UI components
    ├── main_terminal_content.dart
    ├── workspace_search_field.dart
    ├── thumbnail_bar.dart
    ├── add_workspace_dialog.dart
    ├── terminal_top_bar.dart
    ├── workspace_context_menu.dart
    └── workspace_tag_chips.dart
```

## WHERE TO LOOK
- **State Management**: `bloc/workspace_bloc.dart`
  - Manages all workspace events (adding, reordering, persistence).
- **Terminal UI**: `widgets/main_terminal_content.dart`
  - Displays active terminal or restarting/loading views.

## CONVENTIONS
- **Persistence**: Use `HydratedBloc` for workspace storage.
  - JSON serialization via `WorkspaceState.toJson` and `WorkspaceState.fromJson`.
- **Reordering**: Drag-and-drop updates for terminals in workspace.
  - Terminals: `workspace_bloc.dart -> _onReorderTerminals`
  - Workspaces: `workspace_bloc.dart -> _onReorderWorkspaces`
- **Context Extensions**:
  - Theme via `context.theme`.
  - Localizations via `context.t`.

## ANTI-PATTERNS
- **Direct State Mutation**: Avoid mutating lists directly. Always update with `.copyWith`.
- **Complex Build Logic**: No heavy computations in `StatelessWidget.build`. Use Bloc.
- **Manual Sorting**: Never sort lists inline. Delegate to events.
- **Hardcoded Strings**: Always use `context.t` localized strings.
