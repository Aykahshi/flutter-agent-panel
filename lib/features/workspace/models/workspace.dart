import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../terminal/models/terminal_config.dart';

class Workspace extends Equatable {
  const Workspace({
    required this.id,
    required this.path,
    required this.name,
    this.terminals = const [],
    this.icon,
    this.tags = const [],
    this.isPinned = false,
  });

  factory Workspace.create({
    required String path,
    required String name,
    String? icon,
    List<String> tags = const [],
  }) {
    return Workspace(
      id: const Uuid().v4(),
      path: path,
      name: name,
      icon: icon,
      tags: tags,
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
      icon: json['icon'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  final String id;
  final String path;
  final String name;
  final List<TerminalConfig> terminals;
  final String? icon;
  final List<String> tags;
  final bool isPinned;

  Workspace copyWith({
    String? id,
    String? path,
    String? name,
    List<TerminalConfig>? terminals,
    String? icon,
    List<String>? tags,
    bool? isPinned,
  }) {
    return Workspace(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      terminals: terminals ?? this.terminals,
      icon: icon ?? this.icon,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'name': name,
      'terminals': terminals.map((e) => e.toJson()).toList(),
      'icon': icon,
      'tags': tags,
      'isPinned': isPinned,
    };
  }

  @override
  List<Object?> get props => [id, path, name, terminals, icon, tags, isPinned];
}
