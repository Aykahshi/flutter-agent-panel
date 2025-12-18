// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Flutter Agent Panel';

  @override
  String get workspace => '工作區';

  @override
  String get terminal => '終端機';

  @override
  String get newTerminal => '新增終端機';

  @override
  String get settings => '設定';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'Flutter Agent Panel';

  @override
  String get workspace => '工作區';

  @override
  String get terminal => '終端機';

  @override
  String get newTerminal => '新增終端機';

  @override
  String get settings => '設定';
}
