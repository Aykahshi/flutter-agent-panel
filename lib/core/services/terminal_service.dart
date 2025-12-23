import 'dart:io';
import 'package:flutter_pty/flutter_pty.dart';

abstract class TerminalService {
  Pty startPty(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  });
}

class TerminalServiceImpl implements TerminalService {
  @override
  Pty startPty(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) {
    String shell = executable;
    List<String> shellArgs = [...arguments];

    if (shell.isEmpty) {
      if (Platform.isWindows) {
        // Try to find full path of PowerShell 7 (pwsh) or fallback to Windows PowerShell
        shell = 'pwsh.exe';
        try {
          final result = Process.runSync('where', [shell]);
          if (result.exitCode == 0) {
            shell = result.stdout.toString().split('\r\n').first.trim();
          } else {
            shell = 'powershell.exe';
            final fallbackResult = Process.runSync('where', [shell]);
            if (fallbackResult.exitCode == 0) {
              shell =
                  fallbackResult.stdout.toString().split('\r\n').first.trim();
            }
          }
        } catch (_) {
          shell = 'powershell.exe';
        }

        shellArgs = ['-NoLogo', '-ExecutionPolicy', 'Bypass'];
      } else {
        shell = Platform.environment['SHELL'] ?? '/bin/bash';
      }
    }

    // Ensure TERM environment variable is set
    final env = Map<String, String>.from(Platform.environment);
    env['TERM'] = 'xterm-256color';
    // Ensure UTF-8 env vars
    env['LANG'] = 'en_US.UTF-8';
    env['LC_ALL'] = 'en_US.UTF-8';

    return Pty.start(
      shell,
      arguments: shellArgs,
      workingDirectory: workingDirectory,
      environment: env,
    );
  }
}
