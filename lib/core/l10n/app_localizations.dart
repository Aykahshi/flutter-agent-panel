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

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

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

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

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
  /// **'WSL'**
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

  /// No description provided for @cursorBlink.
  ///
  /// In en, this message translates to:
  /// **'Cursor Blink'**
  String get cursorBlink;

  /// No description provided for @cursorBlinkDescription.
  ///
  /// In en, this message translates to:
  /// **'Allow the terminal cursor to blink.'**
  String get cursorBlinkDescription;

  /// Agents settings section title
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get agents;

  /// Description for agents settings
  ///
  /// In en, this message translates to:
  /// **'Manage AI agents and their configurations'**
  String get agentsDescription;

  /// No description provided for @agentName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get agentName;

  /// No description provided for @agentCommand.
  ///
  /// In en, this message translates to:
  /// **'Command'**
  String get agentCommand;

  /// No description provided for @agentArgs.
  ///
  /// In en, this message translates to:
  /// **'Arguments'**
  String get agentArgs;

  /// No description provided for @agentEnv.
  ///
  /// In en, this message translates to:
  /// **'Environment Variables'**
  String get agentEnv;

  /// No description provided for @installAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Install Agent'**
  String get installAgentTitle;

  /// No description provided for @installAgentMessage.
  ///
  /// In en, this message translates to:
  /// **'The agent \'{name}\' is not installed.\nDo you want to install it using the following command?\n\n{command}'**
  String installAgentMessage(String name, String command);

  /// No description provided for @agentNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Agent not installed'**
  String get agentNotInstalled;

  /// No description provided for @enableAgent.
  ///
  /// In en, this message translates to:
  /// **'Enable Agent'**
  String get enableAgent;

  /// No description provided for @installingAgent.
  ///
  /// In en, this message translates to:
  /// **'Installing Agent...'**
  String get installingAgent;

  /// No description provided for @startingAgent.
  ///
  /// In en, this message translates to:
  /// **'Starting Agent...'**
  String get startingAgent;

  /// No description provided for @agentInstalled.
  ///
  /// In en, this message translates to:
  /// **'Agent installed successfully'**
  String get agentInstalled;

  /// No description provided for @agentInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to install agent'**
  String get agentInstallFailed;

  /// No description provided for @noCustomAgents.
  ///
  /// In en, this message translates to:
  /// **'No custom agents configured'**
  String get noCustomAgents;

  /// No description provided for @customAgent.
  ///
  /// In en, this message translates to:
  /// **'Custom Agent'**
  String get customAgent;

  /// No description provided for @addCustomAgent.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Agent'**
  String get addCustomAgent;

  /// No description provided for @editCustomAgent.
  ///
  /// In en, this message translates to:
  /// **'Edit Custom Agent'**
  String get editCustomAgent;

  /// No description provided for @themeDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the application theme mode.'**
  String get themeDescription;

  /// No description provided for @terminalSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure terminal appearance and behavior.'**
  String get terminalSettingsDescription;

  /// No description provided for @fontFamilyDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose which font to use in the terminal.'**
  String get fontFamilyDescription;

  /// No description provided for @shellSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the default shell to use.'**
  String get shellSettingsDescription;

  /// No description provided for @shellPathPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g., C:\\path\\to\\shell.exe'**
  String get shellPathPlaceholder;

  /// No description provided for @customShells.
  ///
  /// In en, this message translates to:
  /// **'Custom Shells'**
  String get customShells;

  /// No description provided for @customShellsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage custom shell configurations for external terminal apps.'**
  String get customShellsDescription;

  /// No description provided for @manageCustomShells.
  ///
  /// In en, this message translates to:
  /// **'Manage Custom Shells'**
  String get manageCustomShells;

  /// No description provided for @addCustomShell.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Shell'**
  String get addCustomShell;

  /// No description provided for @editCustomShell.
  ///
  /// In en, this message translates to:
  /// **'Edit Custom Shell'**
  String get editCustomShell;

  /// No description provided for @deleteCustomShell.
  ///
  /// In en, this message translates to:
  /// **'Delete Custom Shell'**
  String get deleteCustomShell;

  /// No description provided for @shellName.
  ///
  /// In en, this message translates to:
  /// **'Shell Name'**
  String get shellName;

  /// No description provided for @shellNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g., Warp Terminal'**
  String get shellNamePlaceholder;

  /// No description provided for @shellIcon.
  ///
  /// In en, this message translates to:
  /// **'Shell Icon'**
  String get shellIcon;

  /// No description provided for @isExternalTerminal.
  ///
  /// In en, this message translates to:
  /// **'External Terminal App'**
  String get isExternalTerminal;

  /// No description provided for @isExternalTerminalDescription.
  ///
  /// In en, this message translates to:
  /// **'Launch as a separate window (for apps like Warp, Windows Terminal)'**
  String get isExternalTerminalDescription;

  /// No description provided for @noCustomShells.
  ///
  /// In en, this message translates to:
  /// **'No custom shells configured'**
  String get noCustomShells;

  /// No description provided for @addYourFirstCustomShell.
  ///
  /// In en, this message translates to:
  /// **'Add your first custom shell to get started'**
  String get addYourFirstCustomShell;

  /// No description provided for @confirmDeleteShell.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this custom shell?'**
  String get confirmDeleteShell;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @customTheme.
  ///
  /// In en, this message translates to:
  /// **'Custom Theme'**
  String get customTheme;

  /// No description provided for @customThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Paste a JSON theme configuration to customize terminal colors.'**
  String get customThemeDescription;

  /// No description provided for @applyCustomTheme.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Theme'**
  String get applyCustomTheme;

  /// No description provided for @clearCustomTheme.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearCustomTheme;

  /// No description provided for @customThemeFolderHint.
  ///
  /// In en, this message translates to:
  /// **'Imported themes are saved to ~/.flutter-agent-panel/themes/'**
  String get customThemeFolderHint;

  /// No description provided for @jsonMustBeObject.
  ///
  /// In en, this message translates to:
  /// **'JSON must be an object'**
  String get jsonMustBeObject;

  /// No description provided for @missingRequiredField.
  ///
  /// In en, this message translates to:
  /// **'Missing required field: {field}'**
  String missingRequiredField(Object field);

  /// No description provided for @invalidJson.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON: {message}'**
  String invalidJson(Object message);

  /// No description provided for @errorParsingTheme.
  ///
  /// In en, this message translates to:
  /// **'Error parsing theme: {message}'**
  String errorParsingTheme(Object message);

  /// No description provided for @startingTerminal.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get startingTerminal;

  /// No description provided for @initializingShell.
  ///
  /// In en, this message translates to:
  /// **'Initializing shell environment...'**
  String get initializingShell;
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
