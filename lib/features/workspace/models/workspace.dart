import 'package:uuid/uuid.dart';

class Workspace {
  final String id;
  final String name;
  final String path;

  Workspace({required this.id, required this.name, required this.path});

  factory Workspace.create({required String name, required String path}) {
    return Workspace(id: const Uuid().v4(), name: name, path: path);
  }

  // Support for equality and copyWith if needed
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Workspace && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
