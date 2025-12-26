/// Shell types available for terminal creation
enum ShellType {
  pwsh7('PowerShell 7', 'pwsh', 'terminal'),
  powershell('Windows PowerShell', 'powershell', 'terminal'),
  cmd('Command Prompt', 'cmd', 'command'),
  wsl('WSL', 'wsl', 'server'),
  gitBash('Git Bash', 'C:\\Program Files\\Git\\bin\\bash.exe', 'gitBranch'),
  custom('Custom...', '', 'settings');

  const ShellType(this.displayName, this.command, this.icon);

  final String displayName;
  final String command;
  final String icon;
}
