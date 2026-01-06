import 'dart:io' show Platform, Process;

/// Shell types available for terminal creation
enum ShellType {
  // Unix shells (macOS/Linux)
  zsh('Zsh', 'zsh', 'terminal'),
  bash('Bash', 'bash', 'terminal'),

  // Windows shells
  pwsh7('PowerShell 7', 'pwsh', 'terminal'),
  powershell('Windows PowerShell', 'powershell', 'terminal'),
  cmd('Command Prompt', 'cmd', 'command'),
  wsl('WSL', 'wsl', 'server'),
  gitBash('Git Bash', 'C:\\Program Files\\Git\\bin\\bash.exe', 'gitBranch'),

  // Platform-agnostic
  custom('Custom...', '', 'settings');

  const ShellType(this.displayName, this.command, this.icon);

  final String displayName;
  final String command;
  final String icon;

  /// Returns whether this shell is available on the current platform.
  bool get isAvailableOnCurrentPlatform {
    if (Platform.isWindows) {
      // Windows: pwsh7, powershell, cmd, wsl, gitBash, custom
      return this == ShellType.pwsh7 ||
          this == ShellType.powershell ||
          this == ShellType.cmd ||
          this == ShellType.wsl ||
          this == ShellType.gitBash ||
          this == ShellType.custom;
    } else if (Platform.isMacOS || Platform.isLinux) {
      // macOS/Linux: zsh, bash, custom
      return this == ShellType.zsh ||
          this == ShellType.bash ||
          this == ShellType.custom;
    }
    // Fallback: show all except platform-specific ones
    return this == ShellType.custom;
  }

  /// Returns the default shell for the current platform.
  /// On Windows, provides fallback: pwsh7 > powershell > cmd
  static Future<ShellType> getPlatformDefault() async {
    if (Platform.isMacOS) return ShellType.zsh;
    if (Platform.isLinux) return ShellType.bash;

    // Windows: try pwsh7 first, then powershell, then cmd
    if (await _isCommandAvailable('pwsh')) {
      return ShellType.pwsh7;
    }
    if (await _isCommandAvailable('powershell')) {
      return ShellType.powershell;
    }
    return ShellType.cmd; // Always available on Windows
  }

  /// Synchronous version that returns pwsh7 as default for Windows.
  /// Use getPlatformDefault() for actual availability check.
  /// Returns the default shell for the current platform.
  static ShellType get platformDefault {
    if (Platform.isMacOS) return ShellType.zsh;
    if (Platform.isLinux) return ShellType.bash;
    return ShellType.pwsh7; // Windows default (will fallback at runtime)
  }

  /// Resolves the actual executable for a command name on Windows,
  /// implementing a fallback if the primary command is not found.
  /// Order: pwsh > powershell > cmd
  static String resolveWindowsCommand(String command) {
    if (!Platform.isWindows) return command;

    final shell = command.toLowerCase();
    if (shell == 'pwsh' || shell == 'pwsh.exe') {
      try {
        final result = Process.runSync('where', ['pwsh'], runInShell: true);
        if (result.exitCode == 0) return 'pwsh';
      } catch (_) {}
      // Fallback to powershell
      return resolveWindowsCommand('powershell');
    }

    if (shell == 'powershell' || shell == 'powershell.exe') {
      try {
        final result =
            Process.runSync('where', ['powershell'], runInShell: true);
        if (result.exitCode == 0) return 'powershell';
      } catch (_) {}
      // Fallback to cmd
      return 'cmd';
    }

    return command;
  }

  /// Check if a command is available in the system PATH.
  static Future<bool> _isCommandAvailable(String command) async {
    try {
      final result = await Process.run(
        'where',
        [command],
        runInShell: true,
      );
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
