# AGENTS.md

**Generated:** 2026-01-08
**Version:** 0.0.7+1

## OVERVIEW
Dart FFI bindings and isolate-based pseudo-terminal (PTY) management.

## STRUCTURE
```
packages/flutter_pty/
├── lib/
│   ├── flutter_pty.dart                   # Entry point
│   └── src/
│       ├── flutter_pty_bindings_generated.dart  # FFI bindings (auto-generated)
│       └── template.dart                  # Helper classes
├── src/
│   ├── include/                           # C headers for bindings
│   ├── flutter_pty_unix.c                 # PTY logic for Unix-like systems
│   ├── flutter_pty_win.c                  # PTY logic for Windows
│   └── forkpty.c                          # Unix PTY spawn function
```

## WHERE TO LOOK
- **FFI Bindings**: `lib/src/flutter_pty_bindings_generated.dart`
- **Isolate Management**: `lib/src/isolate_pty.dart`
- **Native Logic**: `src/flutter_pty_win.c` (Windows ConPTY) / `src/flutter_pty_unix.c` (POSIX)

## CONVENTIONS
- **FFI Safety**: Validate pointers before access.
- **Isolate Usage**: Use dedicated isolates for PTY I/O to prevent UI blocking.
- **Regeneration**: Use `ffigen` with `ffigen.yaml` for binding updates.

## ANTI-PATTERNS
- **Manual Edits**: NEVER modify `flutter_pty_bindings_generated.dart` directly.
- **Blocking**: NEVER execute long-running native calls on the main isolate.
- **Mixed OS Logic**: Keep platform-specific C code in respective source files.
