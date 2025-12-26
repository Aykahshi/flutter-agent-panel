part of 'terminal_bloc.dart';

class TerminalState extends Equatable {
  const TerminalState({
    this.terminals = const {},
    this.restartingIds = const {},
    this.pendingIds = const {},
  });

  /// Map of terminal ID to TerminalNode
  final Map<String, TerminalNode> terminals;

  /// Set of terminal IDs currently restarting
  final Set<String> restartingIds;

  /// Set of terminal IDs pending creation
  final Set<String> pendingIds;

  TerminalState copyWith({
    Map<String, TerminalNode>? terminals,
    Set<String>? restartingIds,
    Set<String>? pendingIds,
  }) {
    return TerminalState(
      terminals: terminals ?? this.terminals,
      restartingIds: restartingIds ?? this.restartingIds,
      pendingIds: pendingIds ?? this.pendingIds,
    );
  }

  @override
  List<Object?> get props => [
        terminals.keys.toList(),
        restartingIds,
        pendingIds,
      ];
}
