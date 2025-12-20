import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Agent Panel'**
  String get appTitle;

  /// No description provided for @workspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspace;

  /// No description provided for @terminal.
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get terminal;

  /// No description provided for @newTerminal.
  ///
  /// In en, this message translates to:
  /// **'New Terminal'**
  String get newTerminal;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @selectWorkspacePrompt.
  ///
  /// In en, this message translates to:
  /// **'Select or create a workspace to begin'**
  String get selectWorkspacePrompt;

  /// No description provided for @noTerminalsOpen.
  ///
  /// In en, this message translates to:
  /// **'No Terminals Open'**
  String get noTerminalsOpen;

  /// No description provided for @selectShell.
  ///
  /// In en, this message translates to:
  /// **'Select Shell'**
  String get selectShell;

  /// No description provided for @workspaces.
  ///
  /// In en, this message translates to:
  /// **'Workspaces'**
  String get workspaces;

  /// No description provided for @noWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'No workspaces'**
  String get noWorkspaces;

  /// No description provided for @addWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Add Workspace'**
  String get addWorkspace;

  /// No description provided for @slateDark.
  ///
  /// In en, this message translates to:
  /// **'Slate Dark'**
  String get slateDark;

  /// No description provided for @zincDark.
  ///
  /// In en, this message translates to:
  /// **'Zinc Dark'**
  String get zincDark;

  /// No description provided for @neutralDark.
  ///
  /// In en, this message translates to:
  /// **'Neutral Dark'**
  String get neutralDark;

  /// No description provided for @stoneDark.
  ///
  /// In en, this message translates to:
  /// **'Stone Dark'**
  String get stoneDark;

  /// No description provided for @grayDark.
  ///
  /// In en, this message translates to:
  /// **'Gray Dark'**
  String get grayDark;

  /// No description provided for @oneDark.
  ///
  /// In en, this message translates to:
  /// **'One Dark'**
  String get oneDark;

  /// No description provided for @dracula.
  ///
  /// In en, this message translates to:
  /// **'Dracula'**
  String get dracula;

  /// No description provided for @monokai.
  ///
  /// In en, this message translates to:
  /// **'Monokai'**
  String get monokai;

  /// No description provided for @nord.
  ///
  /// In en, this message translates to:
  /// **'Nord'**
  String get nord;

  /// No description provided for @solarizedDark.
  ///
  /// In en, this message translates to:
  /// **'Solarized Dark'**
  String get solarizedDark;

  /// No description provided for @githubDark.
  ///
  /// In en, this message translates to:
  /// **'GitHub Dark'**
  String get githubDark;

  /// No description provided for @pwsh7.
  ///
  /// In en, this message translates to:
  /// **'PowerShell 7'**
  String get pwsh7;

  /// No description provided for @powershell.
  ///
  /// In en, this message translates to:
  /// **'Windows PowerShell'**
  String get powershell;

  /// No description provided for @cmd.
  ///
  /// In en, this message translates to:
  /// **'Command Prompt'**
  String get cmd;

  /// No description provided for @wsl.
  ///
  /// In en, this message translates to:
  /// **'WSL (Default)'**
  String get wsl;

  /// No description provided for @gitBash.
  ///
  /// In en, this message translates to:
  /// **'Git Bash'**
  String get gitBash;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @terminalSettings.
  ///
  /// In en, this message translates to:
  /// **'Terminal Settings'**
  String get terminalSettings;

  /// No description provided for @fontFamily.
  ///
  /// In en, this message translates to:
  /// **'Font Family'**
  String get fontFamily;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// No description provided for @italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italic;

  /// No description provided for @shellSettings.
  ///
  /// In en, this message translates to:
  /// **'Shell Settings'**
  String get shellSettings;

  /// No description provided for @defaultShell.
  ///
  /// In en, this message translates to:
  /// **'Default Shell'**
  String get defaultShell;

  /// No description provided for @customShellPath.
  ///
  /// In en, this message translates to:
  /// **'Custom Shell Path'**
  String get customShellPath;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chineseHant.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get chineseHant;

  /// No description provided for @chineseHans.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get chineseHans;

  /// No description provided for @fontPreview.
  ///
  /// In en, this message translates to:
  /// **'Font Preview'**
  String get fontPreview;

  /// No description provided for @fontPreviewText.
  ///
  /// In en, this message translates to:
  /// **'Build beautiful, natively compiled applications from a single codebase.'**
  String get fontPreviewText;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @configureAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure application preferences'**
  String get configureAppDescription;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @restartingTerminal.
  ///
  /// In en, this message translates to:
  /// **'Restarting Terminal...'**
  String get restartingTerminal;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
