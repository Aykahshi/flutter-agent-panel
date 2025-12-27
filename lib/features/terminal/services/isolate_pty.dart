import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_pty/flutter_pty.dart';

/// Commands sent to the isolate
sealed class _PtyCommand {}

class _ResizeCommand extends _PtyCommand {
  _ResizeCommand(this.rows, this.cols);
  final int rows;
  final int cols;
}

class _WriteCommand extends _PtyCommand {
  _WriteCommand(this.data);
  final String data;
}

class _KillCommand extends _PtyCommand {}

/// Events received from the isolate
sealed class _PtyEvent {}

class _OutputEvent extends _PtyEvent {
  _OutputEvent(this.data);
  final List<int> data;
}

class _ExitEvent extends _PtyEvent {
  _ExitEvent(this.exitCode);
  final int? exitCode;
}

/// A wrapper around Pty that runs the actual process in a separate Isolate
/// to prevent blocking the UI thread during heavy IO or startup.
class IsolatePty {
  IsolatePty._(
    this._isolate,
    this._commandPort,
    this._outputStream,
  );
  final Isolate _isolate;
  final SendPort _commandPort;
  final Stream<List<int>> _outputStream;
  final Completer<int?> _exitCompleter = Completer<int?>();

  /// Spawns a new PTY in a background isolate.
  static Future<IsolatePty> start(
    String executable, {
    List<String> arguments = const [],
    String? workingDirectory,
    Map<String, String>? environment,
    int rows = 24,
    int columns = 80,
  }) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      _ptyIsolateEntryPoint,
      _PtyConfig(
        sendPort: receivePort.sendPort,
        executable: executable,
        arguments: arguments,
        workingDirectory: workingDirectory,
        environment: environment,
        rows: rows,
        columns: columns,
      ),
    );

    final broadcastStream = receivePort.asBroadcastStream();

    // The first message is the command SendPort
    final commandPort = await broadcastStream.first as SendPort;

    // Filter output events for the stream
    final outputController = StreamController<List<int>>();

    broadcastStream.listen((message) {
      if (message is _OutputEvent) {
        outputController.add(message.data);
      } else if (message is _ExitEvent) {
        // We don't close the stream immediately/externally,
        // managing lifecycle is up to the consumer,
        // but we can signal exit.
      } else if (message is _ErrorEvent) {
        outputController.addError(message.error);
      }
    });

    // Handle the exit future separately if needed,
    // or just let the user listen to the stream end?
    // Usually Pty doesn't automatically close output stream on exit
    // depending on implementation, but let's keep it simple.

    return IsolatePty._(
      isolate,
      commandPort,
      outputController.stream,
    );
  }

  Stream<List<int>> get output => _outputStream;

  Future<int?> get exitCode => _exitCompleter.future;

  void resize(int rows, int cols) {
    _commandPort.send(_ResizeCommand(rows, cols));
  }

  void write(List<int> data) {
    // Pty.write takes Stream or List<int>? Actually flutter_pty writes string or bytes.
    // To minimize IPC copying, passing String is often easier if it's text,
    // but pure bytes is safest for terminal.
    // However, SendPort can send List<int> (transferable typed data is better but normal list works).
    // Let's optimize: The flutter_pty `write` takes `Uint8List` or `String`.
    // It's easier to pass string if we have it, but xterm gives us bytes.
    // We'll pass the bytes as a TransferableTypedData if we want to be fancy,
    // or just a list. List<int> is fine for now.

    // Wait, Isolate message passing:
    // If we receive data from xterm onInput, it's String usually.
    // xterm.onOutput sends String? No, xterm's onInput gives String.
    // But we might want to write bytes.
    // Let's change _WriteCommand to take dynamic and handle both.
    // For now, let's assume String since xterm gives String onInput.
    _commandPort.send(_WriteCommand(String.fromCharCodes(data)));
  }

  void writeString(String data) {
    _commandPort.send(_WriteCommand(data));
  }

  void kill() {
    _commandPort.send(_KillCommand());
    _isolate.kill();
  }
}

class _PtyConfig {
  _PtyConfig({
    required this.sendPort,
    required this.executable,
    this.arguments = const [],
    this.workingDirectory,
    this.environment,
    this.rows = 24,
    this.columns = 80,
  });
  final SendPort sendPort;
  final String executable;
  final List<String> arguments;
  final String? workingDirectory;
  final Map<String, String>? environment;
  final int rows;
  final int columns;
}

class _ErrorEvent extends _PtyEvent {
  _ErrorEvent(this.error);
  final String error;
}

Future<void> _ptyIsolateEntryPoint(_PtyConfig config) async {
  final commandPort = ReceivePort();
  config.sendPort.send(commandPort.sendPort);

  Pty pty;
  try {
    pty = Pty.start(
      config.executable,
      arguments: config.arguments,
      workingDirectory: config.workingDirectory,
      environment: config.environment,
      rows: config.rows,
      columns: config.columns,
    );
  } catch (e) {
    config.sendPort.send(_ErrorEvent(e.toString()));
    return;
  }

  // Determine standard shell encoding handling if needed.
  // Pty.output is Stream<Uint8List>.
  pty.output.listen((data) {
    config.sendPort.send(_OutputEvent(data));
  });

  pty.exitCode.then((code) {
    config.sendPort.send(_ExitEvent(code));
  });

  await for (final command in commandPort) {
    if (command is _ResizeCommand) {
      pty.resize(command.rows, command.cols);
    } else if (command is _WriteCommand) {
      pty.write(Uint8List.fromList(command.data.codeUnits));
    } else if (command is _KillCommand) {
      pty.kill();
      Isolate.current.kill();
    }
  }
}
