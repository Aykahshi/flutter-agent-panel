# lib/features/settings - AGENT GUIDE

## OVERVIEW
App configuration management: themes, fonts, shells, agents, localization.

## STRUCTURE
```
settings/
├── bloc/
│   ├── settings_bloc.dart     # HydratedBloc (persistent)
│   ├── settings_event.dart    # 15+ event types
│   └── settings_state.dart    # AppSettings wrapper
├── models/
│   ├── app_settings.dart      # Main config model (JSON serializable)
│   ├── agent_config.dart      # AI agent definitions
│   ├── custom_shell_config.dart
│   ├── terminal_font_settings.dart
│   ├── app_theme.dart         # Light/Dark enum
│   └── shell_type.dart        # PowerShell/Bash/WSL/Custom
├── views/
│   └── settings_dialog.dart   # 879-line tab dialog (COMPLEXITY HOTSPOT)
└── widgets/
    ├── agents_content.dart    # Agent management + installation
    ├── appearance_settings_content.dart
    ├── general_settings_content.dart
    ├── custom_shells_content.dart
    ├── update_settings_content.dart
    ├── agent_dialog.dart      # Add/edit agent
    ├── shell_dialog.dart      # Add/edit custom shell
    └── settings_section.dart  # Reusable layout wrapper
```

## WHERE TO LOOK

| Task | File | Notes |
|------|------|-------|
| Add new setting | `models/app_settings.dart` | Add field + copyWith + JSON |
| Add settings tab | `views/settings_dialog.dart` | `_buildContentForIndex()` switch |
| New agent preset | `models/app_settings.dart` | `getDefaultAgents()` static |
| Persist new field | `bloc/settings_bloc.dart` | Add event handler + fromJson/toJson |

## CONVENTIONS

- **Persistence**: HydratedBloc auto-saves to `storage/` directory
- **Clear nullable fields**: Use `clearX: true` pattern in copyWith
- **Tab content**: Each tab is a separate `*_content.dart` widget
- **Dialogs**: ShadDialog with ShadInput/ShadSelect components
- **Validation**: Inline in dialog widgets before emitting events

## ANTI-PATTERNS

| Forbidden | Do Instead |
|-----------|------------|
| Add logic to settings_dialog.dart | Create new widget in widgets/ |
| Direct AppSettings mutation | Emit SettingsEvent through Bloc |
| Hardcode agent commands | Use AgentConfig model with env vars |

## COMPLEXITY NOTES

`settings_dialog.dart` is 879 lines due to 6 tab sections. Each section handles:
- Async font/theme loading
- File picker for custom themes
- Agent installation with toast feedback
- JSON validation for custom terminal themes

Consider splitting if adding more tabs.
