import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/context_extension.dart';
import '../../workspace/widgets/main_terminal_content.dart';
import '../bloc/terminal_bloc.dart';

/// Terminal page that displays a single terminal based on route parameter.
@RoutePage()
class TerminalView extends StatelessWidget {
  const TerminalView({
    super.key,
    @pathParam required this.terminalId,
  });

  final String terminalId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TerminalBloc, TerminalState>(
      builder: (context, state) {
        final node = state.terminals[terminalId];
        final isRestarting = state.restartingIds.contains(terminalId);
        final isPending = state.pendingIds.contains(terminalId);

        // Show loading if pending or no node yet
        if (isPending || node == null) {
          final theme = context.theme;
          final l10n = context.t;
          return Container(
            color: theme.colorScheme.background,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.startingTerminal,
                    style: theme.textTheme.large,
                  ),
                  const SizedBox(height: 16),
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          );
        }

        return MainTerminalContent(
          activeNode: node,
          isRestarting: isRestarting,
        );
      },
    );
  }
}
