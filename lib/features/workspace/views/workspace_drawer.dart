import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:gap/gap.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../workspace/bloc/workspace_bloc.dart';

class WorkspaceDrawer extends StatelessWidget {
  const WorkspaceDrawer({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
  });
  final bool isCollapsed;
  final VoidCallback onToggle;

  Future<void> _addWorkspace(BuildContext context) async {
    final String? selectedDirectory =
        await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      final name = selectedDirectory.split(RegExp(r'[/\\]')).last;

      if (context.mounted) {
        final l10n = context.t;
        context.read<WorkspaceBloc>().add(
              AddWorkspace(
                path: selectedDirectory,
                name: name.isEmpty ? l10n.workspace : name,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return ClipRect(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          border: Border(
            right: BorderSide(color: theme.colorScheme.border),
          ),
        ),
        child: Column(
          children: [
            // Header / Toggle
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: isCollapsed ? Alignment.center : Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  if (!isCollapsed) const Gap(8),
                  ShadButton.ghost(
                    padding: EdgeInsets.zero,
                    width: 32,
                    height: 32,
                    onPressed: onToggle,
                    child: Icon(
                      LucideIcons.menu,
                      color: theme.colorScheme.foreground,
                      size: 18,
                    ),
                  ),
                  if (!isCollapsed) ...[
                    const Gap(8),
                    Expanded(
                      child: Text(
                        context.t.workspaces,
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.foreground,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Divider(color: theme.colorScheme.border, height: 1),

            // Workspace List
            Expanded(
              child: BlocBuilder<WorkspaceBloc, WorkspaceState>(
                builder: (context, state) {
                  if (state.workspaces.isEmpty && !isCollapsed) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          context.t.noWorkspaces,
                          style: theme.textTheme.muted.copyWith(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.workspaces.length,
                    itemBuilder: (context, index) {
                      final workspace = state.workspaces[index];
                      final isSelected =
                          workspace.id == state.selectedWorkspaceId;

                      return ShadTooltip(
                        builder: (context) => Text(workspace.name),
                        child: InkWell(
                          onTap: () {
                            context
                                .read<WorkspaceBloc>()
                                .add(SelectWorkspace(workspace.id));
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.1)
                                  : null,
                              border: isSelected
                                  ? Border(
                                      left: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      ),
                                    )
                                  : null,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isCollapsed ? 0 : 12,
                            ),
                            alignment: isCollapsed
                                ? Alignment.center
                                : Alignment.centerLeft,
                            child: isCollapsed
                                ? Text(
                                    workspace.name.isNotEmpty
                                        ? workspace.name[0].toUpperCase()
                                        : '?',
                                    style: theme.textTheme.small.copyWith(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.foreground,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Icon(
                                        LucideIcons.folder,
                                        size: 16,
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : Colors.grey
                                                .withValues(alpha: 0.5),
                                      ),
                                      const Gap(8),
                                      Expanded(
                                        child: Text(
                                          workspace.name,
                                          style: theme.textTheme.small.copyWith(
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.foreground,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      if (isSelected)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 4),
                                          child: Icon(
                                            LucideIcons.check,
                                            size: 14,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Add Workspace Button
            // Add Workspace Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: ShadButton.ghost(
                onPressed: () => _addWorkspace(context),
                width: isCollapsed ? 32 : null,
                height: 32,
                padding: isCollapsed
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.plus,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                    if (!isCollapsed) ...[
                      const Gap(8),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 1,
                        ), // Tiny adjustment for alignment
                        child: Text(
                          context.t.addWorkspace,
                          style: theme.textTheme.small.copyWith(
                            color: theme.colorScheme.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Gap(8),
          ],
        ),
      ),
    );
  }
}
