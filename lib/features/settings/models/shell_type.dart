/// Shell types available for terminal creation
enum ShellType {
  pwsh7('PowerShell 7', 'pwsh', 'terminal'),
  powershell('Windows PowerShell', 'powershell', 'terminal'),
  cmd('Command Prompt', 'cmd', 'command'),
  wsl('WSL (Default)', 'wsl', 'server'),
  gitBash('Git Bash', 'C:\\Program Files\\Git\\bin\\bash.exe', 'gitBranch'),
  custom('Custom...', '', 'settings');

  final String displayName;
  final String command;
  final String icon;
  const ShellType(this.displayName, this.command, this.icon);
}
