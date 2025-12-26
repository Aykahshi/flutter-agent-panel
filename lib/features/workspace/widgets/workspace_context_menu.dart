import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/extensions/context_extension.dart';
import '../bloc/workspace_bloc.dart';
import '../models/workspace.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A widget that wraps a child with a context menu for workspace operations.
/// Uses ShadContextMenu for proper positioning aligned to the item.
class WorkspaceContextMenuWrapper extends StatelessWidget {
  const WorkspaceContextMenuWrapper({
    super.key,
    required this.workspace,
    required this.onEdit,
    required this.child,
    this.controller,
    this.onOpen,
  });

  final Workspace workspace;
  final VoidCallback onEdit;
  final Widget child;
  final ShadContextMenuController? controller;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.t;

    return ShadContextMenuRegion(
      controller: controller,
      constraints: const BoxConstraints(minWidth: 160),
      items: [
        // Edit
        ShadContextMenuItem(
          leading: Icon(
            LucideIcons.pencil,
            size: 16,
            color: theme.colorScheme.popoverForeground,
          ),
          onPressed: () => onEdit(),
          child: Text(l10n.editWorkspace),
        ),
        // Pin/Unpin
        ShadContextMenuItem(
          leading: Icon(
            workspace.isPinned ? LucideIcons.pinOff : LucideIcons.pin,
            size: 16,
            color: theme.colorScheme.popoverForeground,
          ),
          onPressed: () {
            context.read<WorkspaceBloc>().add(TogglePinWorkspace(workspace.id));
          },
          child: Text(
            workspace.isPinned ? l10n.unpinWorkspace : l10n.pinWorkspace,
          ),
        ),
        const Divider(height: 8),
        // Delete
        ShadContextMenuItem(
          leading: Icon(
            LucideIcons.trash2,
            size: 16,
            color: theme.colorScheme.destructive,
          ),
          onPressed: () => _showDeleteConfirmation(context, workspace),
          child: Text(
            l10n.deleteWorkspace,
            style: TextStyle(color: theme.colorScheme.destructive),
          ),
        ),
      ],
      // Wrap child with Listener to detect right-click (secondary button)
      // This allows us to notify the parent to close other menus BEFORE this one opens
      child: Listener(
        onPointerDown: (event) {
          if (event.buttons == kSecondaryButton) {
            onOpen?.call();
          }
        },
        child: child,
      ),
    );
  }
}

void _showDeleteConfirmation(BuildContext context, Workspace workspace) {
  final l10n = context.t;

  showShadDialog(
    context: context,
    builder: (context) => ShadDialog.alert(
      title: Text(l10n.deleteWorkspace),
      description: Text(l10n.confirmDeleteWorkspace),
      actions: [
        ShadButton.outline(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ShadButton.destructive(
          child: Text(l10n.delete),
          onPressed: () {
            context.read<WorkspaceBloc>().add(RemoveWorkspace(workspace.id));
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}
