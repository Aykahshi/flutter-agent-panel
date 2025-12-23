import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Custom shell configuration for user-defined shells
class CustomShellConfig extends Equatable {
  const CustomShellConfig({
    required this.id,
    required this.name,
    required this.path,
    this.icon = 'terminal',
  });

  /// Create a new custom shell config with a generated ID
  factory CustomShellConfig.create({
    required String name,
    required String path,
    String icon = 'terminal',
  }) {
    return CustomShellConfig(
      id: const Uuid().v4(),
      name: name,
      path: path,
      icon: icon,
    );
  }

  factory CustomShellConfig.fromJson(Map<String, dynamic> json) {
    return CustomShellConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      icon: json['icon'] as String? ?? 'terminal',
    );
  }
  final String id;
  final String name;
  final String path;
  final String icon;

  CustomShellConfig copyWith({
    String? name,
    String? path,
    String? icon,
  }) {
    return CustomShellConfig(
      id: id,
      name: name ?? this.name,
      path: path ?? this.path,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'icon': icon,
    };
  }

  @override
  List<Object?> get props => [id, name, path, icon];
}
