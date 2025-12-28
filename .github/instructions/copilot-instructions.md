# Flutter Agent Panel Development Guidelines
*Core Principles for BLoC & Shadcn UI Development*

## Purpose & Scope
This document outlines the coding standards, architectural patterns, and development workflows for the `flutter_agent_panel` project. It serves as a guide for GitHub Copilot and developers to maintain consistency across the codebase.

---

## Naming Conventions
- **Feature-First**: Organise code by feature (e.g., `lib/features/terminal`).
- **Widgets**: Use classes for widgets (e.g., `class MyWidget extends StatelessWidget`) rather than helper methods (e.g., `Widget _buildMyWidget()`).
- **Files**: Use `snake_case` for filenames and `PascalCase` for class names.

## Code Style
- **Architecture**: Strictly follow the **Feature-First** architecture.
- **State Management**: Use `flutter_bloc` and `hydrated_bloc` for state. Business logic must be separated from UI logic.
- **UI Components**: Use `shadcn_ui` components and tokens. Access theme data via `context.theme`.
- **Layout**: Use `Gap` for spacing instead of `SizedBox`.
- **Responsiveness**: Use `flutter_screenutil` extensions (`.w`, `.h`, `.sp`, `.r`) for all fixed dimensions.
- **Localization**: All UI strings must be localized using `context.t` or `AppLocalizations.of(context)`. Hardcoded strings should be moved to ARB files.
- **Imports**: Use relative imports within the same feature folder; use absolute imports for `core/` or `shared/` packages.

## Error Handling
- Catch PTY and process-level errors in the service layer and propagate them to the UI via BLoC states.
- Use Toast notifications or error chips to inform the user of failures.

## Security
- Never hardcode API keys or sensitive agent configurations. Use the provided `UserConfigService` or environment variables.

---

## Code Examples
```dart
// Correct pattern: Using Gap, screenutil extensions, and localized strings
Column(
  children: [
    Text(
      context.t.welcomeMessage,
      style: TextStyle(fontSize: 18.sp, color: context.theme.colorScheme.foreground),
    ),
    const Gap(16),
    const UserProfileSection(),
  ],
)

// Incorrect pattern: Using SizedBox, hardcoded numbers, and non-localized strings
Column(
  children: [
    Text('Welcome'),
    SizedBox(height: 16),
    _buildProfile(), // Helper method instead of Widget class
  ],
)
```

---

## [Optional] Task-Specific or Advanced Sections

### Framework-Specific Rules
- **Terminal**: Low-level terminal logic is handled in `packages/flutter_pty` and `packages/xterm`.
- **Code Generation**: Always run `dart run lean_builder build --delete-conflicting-outputs` after modifying files that use `auto_route`.
- **Linting**: Adhere to `analysis_options.yaml`. Run `flutter analyze` before committing.

### Advanced Tips & Edge Cases
- When adding new agents, ensure they are registered in the `SettingsBloc` and support the default agent list.
- Use `HydratedBloc` for any state that needs to persist across app restarts.
