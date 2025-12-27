# Repository Custom Instructions for GitHub Copilot

## Project Overview
- **Name**: `flutter_agent_panel`
- **Type**: Flutter Application (Desktop Focus)
- **Description**: A cross-platform terminal aggregator and AI agent panel. Features multi-workspace support, terminal emulation, and integration with AI agents.
- **Tech Stack**:
    - Flutter SDK `^3.6.0`, currently using `3.38.4`
    - Dart SDK depends on Flutter SDK, currently using `3.10.3`
    - State Management: `flutter_bloc`, `hydrated_bloc`
    - Navigation: `auto_route`
    - UI Components: `shadcn_ui`
    - Responsive Design: `flutter_screenutil`
    - Internal Packages: `packages/xterm`, `packages/flutter_pty`

## Coding Standards
- **Architecture**: Follow a **Feature-First** architecture.
- **State Management**: Use the **BLoC pattern**. UI talks to BLoC, BLoC talks to Services/Repositories.
- **UI & Layout**:
    - Use `ShadThemeData` from `shadcn_ui` (via `context.theme`).
    - **Spacing**: Use `Gap` instead of `SizedBox` for spacing in `Column`, `Row`, and `ListView`.
    - **Responsive**: Use `flutter_screenutil` extensions (`.w`, `.h`, `.sp`, `.r`).
    - **Widgets over Methods**: Prefer creating a `Widget` class over a `_buildWidget` helper method.
- **Localization**: Use `context.t` or `AppLocalizations.of(context)` for strings. All UI text should be localized.
- **Imports**: Prefer relative imports within features, absolute imports for core/shared.

## Build and Validation
- **Run Application**: `flutter run`
- **Code Generation**: `dart run lean_builder build --delete-conflicting-outputs` (Required for `auto_route` and `hydrated_bloc` serialization).
- **Run Tests**: `flutter test`
- **Linting**: `flutter analyze`
- **Formatting**: `dart format .`
- **Fixes**: `dart fix --apply`

## Copilot Code Review Focus
When performing code reviews, please prioritize the following:
1. **Adherence to BLoC pattern**: Ensure logic is separated from UI.
2. **Design Consistency**: Verify that new UI components use `shadcn_ui` and follow existing theme tokens.
3. **Responsive Utilities**: Check for proper use of `flutter_screenutil` for all fixed dimensions.
4. **Spacing**: Flag use of `SizedBox` for spacing; suggest `Gap` instead.
5. **Localization**: Ensure new hardcoded strings are moved to ARB files.
