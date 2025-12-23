import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../terminal/models/terminal_node.dart';
import '../../terminal/views/terminal_view.dart';
import 'package:gap/gap.dart';

/// Main terminal content widget that displays the active terminal or restarting state.
class MainTerminalContent extends StatelessWidget {
  const MainTerminalContent({
    super.key,
    required this.activeNode,
    this.isRestarting = false,
  });
  final TerminalNode? activeNode;
  final bool isRestarting;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.t;

    // Show restarting state or loading state for new agent terminal
    // We check hasOutput to see if the process has started sending data
    final shouldShowLoading =
        isRestarting || activeNode == null || !activeNode!.hasOutput;

    if (shouldShowLoading) {
      return Container(
        color: theme.colorScheme.background,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isRestarting
                    ? l10n.restartingTerminal
                    : (activeNode != null && !activeNode!.hasOutput
                        ? l10n.startingTerminal
                        : l10n.noTerminalsOpen),
                style: theme.textTheme.large,
              ),
              if (isRestarting ||
                  (activeNode != null && !activeNode!.hasOutput)) ...[
                const Gap(16),
                CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Show the terminal with RepaintBoundary to isolate repaints
    return RepaintBoundary(
      child: TerminalView(
        key: ValueKey(activeNode!.id),
        terminalNode: activeNode!,
        interactive: true,
      ),
    );
  }
}
