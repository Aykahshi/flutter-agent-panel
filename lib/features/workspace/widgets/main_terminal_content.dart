import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../terminal/models/terminal_node.dart';
import '../../terminal/views/terminal_view.dart';
import 'package:gap/gap.dart';

/// Main terminal content widget that displays the active terminal or restarting state.
class MainTerminalContent extends StatelessWidget {
  final TerminalNode? activeNode;
  final bool isRestarting;

  const MainTerminalContent({
    super.key,
    required this.activeNode,
    this.isRestarting = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.t;

    // Show restarting state
    if (isRestarting || activeNode == null) {
      return Container(
        color: theme.colorScheme.background,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              const Gap(16),
              Text(
                isRestarting ? l10n.restartingTerminal : l10n.noTerminalsOpen,
                style: theme.textTheme.muted,
              ),
            ],
          ),
        ),
      );
    }

    // Show the terminal
    return TerminalView(
      key: ValueKey(activeNode!.id),
      terminalNode: activeNode!,
      interactive: true,
    );
  }
}
