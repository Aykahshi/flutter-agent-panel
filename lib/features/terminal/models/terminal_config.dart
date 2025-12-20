import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class TerminalConfig extends Equatable {
  final String id;
  final String title;
  final String cwd;
  final String shellCmd;
  final String? icon;

  const TerminalConfig({
    required this.id,
    required this.title,
    required this.cwd,
    this.shellCmd = 'pwsh',
    this.icon,
  });

  factory TerminalConfig.create({
    required String title,
    required String cwd,
    String shellCmd = 'pwsh',
    String? icon,
  }) {
    return TerminalConfig(
      id: const Uuid().v4(),
      title: title,
      cwd: cwd,
      shellCmd: shellCmd,
      icon: icon,
    );
  }

  TerminalConfig copyWith({
    String? id,
    String? title,
    String? cwd,
    String? shellCmd,
    String? icon,
  }) {
    return TerminalConfig(
      id: id ?? this.id,
      title: title ?? this.title,
      cwd: cwd ?? this.cwd,
      shellCmd: shellCmd ?? this.shellCmd,
      icon: icon ?? this.icon,
    );
  }

  factory TerminalConfig.fromJson(Map<String, dynamic> json) {
    return TerminalConfig(
      id: json['id'] as String,
      title: json['title'] as String,
      cwd: json['cwd'] as String,
      shellCmd: json['shellCmd'] as String? ?? 'pwsh',
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cwd': cwd,
      'shellCmd': shellCmd,
      'icon': icon,
    };
  }

  @override
  List<Object?> get props => [id, title, cwd, shellCmd, icon];
}
