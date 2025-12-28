// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get general => 'General';

  @override
  String get workspace => 'Workspace';

  @override
  String get terminal => 'Terminal';

  @override
  String get settings => 'Settings';

  @override
  String get selectWorkspacePrompt => 'Select or create a workspace to begin';

  @override
  String get noTerminalsOpen => 'No Terminals Open';

  @override
  String get selectShell => 'Select Shell';

  @override
  String get workspaces => 'Workspaces';

  @override
  String get noWorkspaces => 'No workspaces';

  @override
  String get addWorkspace => 'Add Workspace';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get pwsh7 => 'PowerShell 7';

  @override
  String get powershell => 'Windows PowerShell';

  @override
  String get cmd => 'Command Prompt';

  @override
  String get wsl => 'WSL';

  @override
  String get gitBash => 'Git Bash';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get appFontFamily => 'App Font Family';

  @override
  String get appFontFamilyDescription =>
      'Choose the global font family for the application.';

  @override
  String get defaultGeist => 'Default (Geist)';

  @override
  String get terminalSettings => 'Terminal Settings';

  @override
  String get fontFamily => 'Font Family';

  @override
  String get fontSize => 'Font Size';

  @override
  String get bold => 'Bold';

  @override
  String get italic => 'Italic';

  @override
  String get shellSettings => 'Shell Settings';

  @override
  String get defaultShell => 'Default Shell';

  @override
  String get customShellPath => 'Custom Shell Path';

  @override
  String get browse => 'Browse';

  @override
  String get custom => 'Custom';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get chineseHant => 'Traditional Chinese';

  @override
  String get chineseHans => 'Simplified Chinese';

  @override
  String get fontPreviewText => 'echo \"Hello World! 你好世界！\"';

  @override
  String get about => 'About';

  @override
  String get help => 'Help';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get restartingTerminal => 'Restarting Terminal...';

  @override
  String get cursorBlink => 'Cursor Blink';

  @override
  String get cursorBlinkDescription => 'Allow the terminal cursor to blink.';

  @override
  String get agents => 'Agents';

  @override
  String get agentsDescription => 'Manage AI agents and their configurations';

  @override
  String get agentName => 'Name';

  @override
  String get agentCommand => 'Command';

  @override
  String get agentArgs => 'Arguments';

  @override
  String get agentEnv => 'Environment Variables';

  @override
  String get installAgentTitle => 'Install Agent';

  @override
  String installAgentMessage(String name, String command) {
    return 'The agent \'$name\' is not installed.\nDo you want to install it using the following command?\n\n$command';
  }

  @override
  String get agentNotInstalled => 'Agent not installed';

  @override
  String get installingAgent => 'Installing Agent...';

  @override
  String get agentInstalled => 'Agent installed successfully';

  @override
  String get agentInstallFailed => 'Failed to install agent';

  @override
  String get noCustomAgents => 'No custom agents configured';

  @override
  String get customAgent => 'Custom Agent';

  @override
  String get addCustomAgent => 'Add Custom Agent';

  @override
  String get editCustomAgent => 'Edit Custom Agent';

  @override
  String get themeDescription => 'Select the application theme mode.';

  @override
  String get terminalSettingsDescription =>
      'Configure terminal appearance and behavior.';

  @override
  String get fontFamilyDescription =>
      'Choose which font to use in the terminal.';

  @override
  String get shellSettingsDescription => 'Select the default shell to use.';

  @override
  String get shellPathPlaceholder => 'e.g., C:\\path\\to\\shell.exe';

  @override
  String get customShells => 'Custom Shells';

  @override
  String get customShellsDescription => 'Manage custom shells, like fish, etc.';

  @override
  String get addCustomShell => 'Add Custom Shell';

  @override
  String get editCustomShell => 'Edit Custom Shell';

  @override
  String get deleteCustomShell => 'Delete Custom Shell';

  @override
  String get shellName => 'Shell Name';

  @override
  String get shellNamePlaceholder => 'e.g., fish';

  @override
  String get noCustomShells => 'No custom shells configured';

  @override
  String get addYourFirstCustomShell =>
      'Add your first custom shell to get started';

  @override
  String get confirmDeleteShell =>
      'Are you sure you want to delete this custom shell?';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get customTheme => 'Custom Theme';

  @override
  String get customThemeDescription =>
      'Paste a JSON theme configuration to customize terminal colors.';

  @override
  String get applyCustomTheme => 'Add Custom Theme';

  @override
  String get clearCustomTheme => 'Clear';

  @override
  String get customThemeFolderHint =>
      'Imported themes are saved to ~/.flutter-agent-panel/themes/';

  @override
  String get jsonMustBeObject => 'JSON must be an object';

  @override
  String missingRequiredField(Object field) {
    return 'Missing required field: $field';
  }

  @override
  String invalidJson(Object message) {
    return 'Invalid JSON: $message';
  }

  @override
  String errorParsingTheme(Object message) {
    return 'Error parsing theme: $message';
  }

  @override
  String get startingTerminal => 'Starting...';

  @override
  String get loading => 'Loading...';

  @override
  String get agentShell => 'Shell';

  @override
  String get agentShellDescription =>
      'Select the shell to use when opening this agent';

  @override
  String get defaultShellOption => 'Default (Global Settings)';

  @override
  String get globalEnvironmentVariables => 'Global Environment Variables';

  @override
  String get globalEnvironmentVariablesDescription =>
      'Environment variables applied to all terminals';

  @override
  String get editWorkspace => 'Edit Workspace';

  @override
  String get deleteWorkspace => 'Delete Workspace';

  @override
  String get pinWorkspace => 'Pin Workspace';

  @override
  String get unpinWorkspace => 'Unpin Workspace';

  @override
  String get searchWorkspaces => 'Search workspaces...';

  @override
  String get workspaceName => 'Workspace Name';

  @override
  String get workspaceIcon => 'Icon';

  @override
  String get workspacePath => 'Folder Path';

  @override
  String get workspaceTags => 'Tags';

  @override
  String get tagsPlaceholder => 'Enter tags separated by commas';

  @override
  String get confirmDeleteWorkspace =>
      'Are you sure you want to delete this workspace?';

  @override
  String get createWorkspace => 'Create Workspace';

  @override
  String get terminalSearchPlaceholder => 'Find';

  @override
  String get terminalSearchPrevious => 'Previous Match';

  @override
  String get terminalSearchNext => 'Next Match';

  @override
  String get terminalSearchCaseSensitive => 'Match Case';

  @override
  String get terminalSearchRegex => 'Use Regular Expression';

  @override
  String get close => 'Close';

  @override
  String get addTerminal => 'Add Terminal';

  @override
  String get addAgent => 'Add Agent';

  @override
  String get update => 'Update';

  @override
  String get updateDescription => 'Check for and install application updates';

  @override
  String get currentVersion => 'Current Version';

  @override
  String get checkForUpdates => 'Check for Updates';

  @override
  String get latestVersion => 'Latest Version';

  @override
  String get noUpdatesAvailable => 'You are using the latest version';

  @override
  String get updateAvailable => 'A new version is available';

  @override
  String get downloading => 'Downloading...';

  @override
  String get readyToInstall => 'Ready to Install';

  @override
  String get version => 'Version';

  @override
  String get checkingForUpdates => 'Checking...';

  @override
  String get installUpdate => 'Install Now';

  @override
  String get restartToInstall => 'Restart & Install';

  @override
  String get updateError => 'Error';

  @override
  String get updateErrorMessage =>
      'Failed to download or install update. Please try again later or download manually from the releases page.';

  @override
  String get later => 'Later';

  @override
  String get updateNow => 'Update Now';

  @override
  String updateAvailableDescription(
      String latestVersion, String currentVersion) {
    return 'A new version $latestVersion is available.\nCurrent version: $currentVersion';
  }
}
