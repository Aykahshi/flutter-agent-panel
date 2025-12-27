[Setup]
AppId={{2A66236B-3C21-48C0-8583-049830F25835}
AppName=Flutter Agent Panel
AppVersion=1.0.0
AppPublisher=Aykahshi
AppPublisherURL=https://github.com/Aykahshi/flutter-agent-panel
AppSupportURL=https://github.com/Aykahshi/flutter-agent-panel/issues
AppUpdatesURL=https://github.com/Aykahshi/flutter-agent-panel/releases
DefaultDirName={autopf}\FlutterAgentPanel
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=..\build\windows\x64\runner\Release\Output
OutputBaseFilename=flutter_agent_panel_setup
SetupIconFile=runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\Flutter Agent Panel"; Filename: "{app}\flutter_agent_panel.exe"
Name: "{autodesktop}\Flutter Agent Panel"; Filename: "{app}\flutter_agent_panel.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\flutter_agent_panel.exe"; Description: "{cm:LaunchProgram,Flutter Agent Panel}"; Flags: nowait postinstall skipifsilent
