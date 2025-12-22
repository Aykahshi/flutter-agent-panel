import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../l10n/app_localizations.dart';

/// Extension on BuildContext for easy access to localization and theme.
extension AppContext on BuildContext {
  /// Get the localization instance.
  AppLocalizations get t => AppLocalizations.of(this)!;

  /// Get the ShadTheme data (replaces ShadTheme.of(context)).
  ShadThemeData get theme => ShadTheme.of(this);

  /// Get the color scheme directly.
  ShadColorScheme get colorScheme => ShadTheme.of(this).colorScheme;

  /// Get the text theme directly.
  ShadTextTheme get textTheme => ShadTheme.of(this).textTheme;
}
