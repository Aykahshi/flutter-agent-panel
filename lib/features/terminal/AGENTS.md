# lib/features/terminal - AGENT GUIDE

## OVERVIEW
PTY lifecycle management with cross-platform shell support and terminal theming.

## STRUCTURE
```
terminal/
├── bloc/
│   ├── terminal_bloc.dart     # PTY creation, shell resolution (434 lines)
│   ├── terminal_event.dart    # Create/Kill/Restart/Resize events
│   └── terminal_state.dart    # TerminalNode map management
├── models/
│   ├── terminal_node.dart     # PTY + Terminal + Controller bundle
│   ├── terminal_config.dart   # Shell type, working dir, env vars
│   ├── terminal_theme_data.dart
│   └── built_in_themes.dart   # 20+ predefined color schemes
├── services/
│   ├── isolate_pty.dart       # Background PTY I/O handling
│   └── terminal_theme_service.dart  # Theme JSON parsing
├── views/
│   ├── terminal_view.dart     # BlocBuilder + TerminalComponent
│   └── terminal_component.dart # xterm TerminalView wrapper
└── widgets/
    ├── terminal_search_bar.dart  # Regex search with navigation
    ├── activity_indicator.dart   # Output activity pulse
    └── glowing_icon.dart         # Agent status indicator
```

## WHERE TO LOOK

| Task | File | Notes |
|------|------|-------|
| Add shell type | `terminal_bloc.dart` | `_createTerminalNode()` switch |
| Custom theme | `terminal_theme_service.dart` | JSON parsing logic |
| PTY resize | `terminal_bloc.dart` | `_onResizeTerminal()` |
| Search feature | `widgets/terminal_search_bar.dart` | TerminalSearchController |

## CONVENTIONS

- **TerminalNode**: Bundles Pty + Terminal + TerminalController
- **Shell resolution**: Try pwsh → powershell → bash fallback
- **Environment**: Always set `TERM=xterm-256color`, `LANG=en_US.UTF-8`
- **Isolates**: PTY output streams on dedicated isolates

## PLATFORM-SPECIFIC LOGIC

```dart
// Windows shells
'powershell.exe' → ['-NoLogo', '-ExecutionPolicy', 'Bypass']
'pwsh.exe'       → ['-NoLogo', '-ExecutionPolicy', 'Bypass']
'cmd.exe'        → []
'wsl.exe'        → ['--', 'bash', '-l']

// Unix shells
'/bin/bash'      → ['-l']
'/bin/zsh'       → ['-l']
```

## ANTI-PATTERNS

| Forbidden | Reason |
|-----------|--------|
| PTY calls on main isolate | UI jank - use IsolatePty |
| Direct Terminal state access | Use TerminalController |
| Hardcoded theme colors | Use TerminalThemeData model |

## INTER-FEATURE DEPENDENCIES

- **Imports from settings**: `TerminalFontSettings`, `AppSettings.terminalThemeName`
- **Used by workspace**: `TerminalConfig` stored in Workspace model
- **Uses packages**: `flutter_pty` (PTY), `xterm` (rendering)
