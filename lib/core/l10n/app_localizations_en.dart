// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Agent Panel';

  @override
  String get workspace => 'Workspace';

  @override
  String get terminal => 'Terminal';

  @override
  String get newTerminal => 'New Terminal';

  @override
  String get settings => 'Settings';
}
