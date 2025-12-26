import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Custom shell configuration for user-defined shells
class CustomShellConfig extends Equatable {
  const CustomShellConfig({
    required this.id,
    required this.name,
    required this.path,
  });

  /// Create a new custom shell config with a generated ID
  factory CustomShellConfig.create({
    required String name,
    required String path,
  }) {
    return CustomShellConfig(
      id: const Uuid().v4(),
      name: name,
      path: path,
    );
  }

  factory CustomShellConfig.fromJson(Map<String, dynamic> json) {
    return CustomShellConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
    );
  }
  final String id;
  final String name;
  final String path;

  CustomShellConfig copyWith({
    String? name,
    String? path,
  }) {
    return CustomShellConfig(
      id: id,
      name: name ?? this.name,
      path: path ?? this.path,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
    };
  }

  @override
  List<Object?> get props => [id, name, path];
}
