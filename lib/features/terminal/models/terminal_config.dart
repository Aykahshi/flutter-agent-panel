import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class TerminalConfig extends Equatable {
  const TerminalConfig({
    required this.id,
    required this.title,
    required this.cwd,
    this.shellCmd = 'pwsh',
    this.icon,
    this.agentId,
    this.args = const [],
    this.env = const {},
    this.agentCommand,
  });

  factory TerminalConfig.create({
    required String title,
    required String cwd,
    String shellCmd = 'pwsh',
    String? icon,
    String? agentId,
    List<String> args = const [],
    Map<String, String> env = const {},
    String? agentCommand,
  }) {
    return TerminalConfig(
      id: const Uuid().v4(),
      title: title,
      cwd: cwd,
      shellCmd: shellCmd,
      icon: icon,
      agentId: agentId,
      args: args,
      env: env,
      agentCommand: agentCommand,
    );
  }

  factory TerminalConfig.fromJson(Map<String, dynamic> json) {
    return TerminalConfig(
      id: json['id'] as String,
      title: json['title'] as String,
      cwd: json['cwd'] as String,
      shellCmd: json['shellCmd'] as String? ?? 'pwsh',
      icon: json['icon'] as String?,
      agentId: json['agentId'] as String?,
      args:
          (json['args'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      env: (json['env'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as String),
          ) ??
          const {},
      agentCommand: json['agentCommand'] as String?,
    );
  }
  final String id;
  final String title;
  final String cwd;
  final String shellCmd;
  final String? icon;
  final String? agentId;
  final List<String> args;
  final Map<String, String> env;
  final String? agentCommand;

  TerminalConfig copyWith({
    String? id,
    String? title,
    String? cwd,
    String? shellCmd,
    String? icon,
    String? agentId,
    List<String>? args,
    Map<String, String>? env,
    String? agentCommand,
  }) {
    return TerminalConfig(
      id: id ?? this.id,
      title: title ?? this.title,
      cwd: cwd ?? this.cwd,
      shellCmd: shellCmd ?? this.shellCmd,
      icon: icon ?? this.icon,
      agentId: agentId ?? this.agentId,
      args: args ?? this.args,
      env: env ?? this.env,
      agentCommand: agentCommand ?? this.agentCommand,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cwd': cwd,
      'shellCmd': shellCmd,
      'icon': icon,
      'agentId': agentId,
      'args': args,
      'env': env,
      'agentCommand': agentCommand,
    };
  }

  @override
  List<Object?> get props =>
      [id, title, cwd, shellCmd, icon, agentId, args, env, agentCommand];
}
