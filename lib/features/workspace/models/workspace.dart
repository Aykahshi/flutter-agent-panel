import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../terminal/models/terminal_config.dart';

class Workspace extends Equatable {
  const Workspace({
    required this.id,
    required this.path,
    required this.name,
    this.terminals = const [],
  });

  factory Workspace.create({required String path, required String name}) {
    return Workspace(
      id: const Uuid().v4(),
      path: path,
      name: name,
    );
  }

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] as String,
      path: json['path'] as String,
      name: json['name'] as String,
      terminals: (json['terminals'] as List<dynamic>?)
              ?.map((e) => TerminalConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
  final String id;
  final String path;
  final String name;
  final List<TerminalConfig> terminals;

  Workspace copyWith({
    String? id,
    String? path,
    String? name,
    List<TerminalConfig>? terminals,
  }) {
    return Workspace(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      terminals: terminals ?? this.terminals,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'name': name,
      'terminals': terminals.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, path, name, terminals];
}
