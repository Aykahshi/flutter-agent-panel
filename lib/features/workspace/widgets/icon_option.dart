import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../bloc/workspace_bloc.dart';
import '../models/workspace.dart';
import '../../terminal/models/terminal_node.dart';

/// A reusable icon option widget for terminal icon selection.
class IconOption extends StatelessWidget {
  const IconOption({
    super.key,
    required this.iconName,
    required this.node,
    required this.workspace,
    this.onClose,
    required this.iconMapping,
  });
  final String iconName;
  final TerminalNode node;
  final Workspace workspace;
  final VoidCallback? onClose;
  final Map<String, IconData> iconMapping;

  @override
  Widget build(BuildContext context) {
    final iconData = iconMapping[iconName] ?? LucideIcons.terminal;

    return ShadButton.ghost(
      padding: EdgeInsets.zero,
      width: 40,
      height: 40,
      onPressed: () {
        final config = workspace.terminals.firstWhere((t) => t.id == node.id);
        context.read<WorkspaceBloc>().add(
              UpdateTerminalInWorkspace(
                workspaceId: workspace.id,
                config: config.copyWith(icon: iconName),
              ),
            );
        onClose?.call();
      },
      child: Icon(iconData, size: 20),
    );
  }
}
