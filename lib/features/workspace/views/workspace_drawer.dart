import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:gap/gap.dart';
import '../../../core/extensions/context_extension.dart';
import '../bloc/workspace_bloc.dart';
import '../models/workspace.dart';
import '../widgets/add_workspace_dialog.dart';
import '../widgets/workspace_context_menu.dart';
import '../widgets/workspace_search_field.dart';
import '../widgets/workspace_tag_chips.dart';

class WorkspaceDrawer extends StatefulWidget {
  const WorkspaceDrawer({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
    this.onWorkspaceSelected,
  });

  final bool isCollapsed;
  final VoidCallback onToggle;
  final void Function(String workspaceId)? onWorkspaceSelected;

  @override
  State<WorkspaceDrawer> createState() => _WorkspaceDrawerState();
}

class _WorkspaceDrawerState extends State<WorkspaceDrawer> {
  String _searchQuery = '';
  final Map<String, ShadContextMenuController> _contextMenuControllers = {};

  @override
  void dispose() {
    for (final controller in _contextMenuControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleContextMenuOpen(String openedWorkspaceId) {
    for (final entry in _contextMenuControllers.entries) {
      if (entry.key != openedWorkspaceId) {
        entry.value.hide();
      }
    }
  }

  List<Workspace> _filterWorkspaces(List<Workspace> workspaces) {
    if (_searchQuery.isEmpty) return workspaces;

    final query = _searchQuery.toLowerCase();
    return workspaces.where((w) {
      return w.name.toLowerCase().contains(query) ||
          w.tags.any((t) => t.toLowerCase().contains(query));
    }).toList();
  }

  void _selectWorkspace(BuildContext context, String workspaceId) {
    if (widget.onWorkspaceSelected != null) {
      widget.onWorkspaceSelected!(workspaceId);
    } else {
      context.read<WorkspaceBloc>().add(SelectWorkspace(workspaceId));
    }
  }

  void _showEditDialog(BuildContext context, Workspace workspace) {
    showAddWorkspaceDialog(
      context,
      workspaceId: workspace.id,
      initialName: workspace.name,
      initialPath: workspace.path,
      initialIcon: workspace.icon,
      initialTags: workspace.tags,
    );
  }

  static final Map<String, IconData> _iconMapping = {
    'folder': LucideIcons.folder,
    'briefcase': LucideIcons.briefcase,
    'code': LucideIcons.code,
    'database': LucideIcons.database,
    'globe': LucideIcons.globe,
    'house': LucideIcons.house,
    'layers': LucideIcons.layers,
    'package': LucideIcons.package,
    'server': LucideIcons.server,
    'shield': LucideIcons.shield,
    'star': LucideIcons.star,
    'zap': LucideIcons.zap,
    'smartphone': LucideIcons.smartphone,
    'notepadText': LucideIcons.notepadText,
    'appWindow': LucideIcons.appWindow,
    'bookmark': LucideIcons.bookmark,
    'bug': LucideIcons.bug,
    'cloud': LucideIcons.cloud,
    'fileCode': LucideIcons.fileCode,
    'flask': LucideIcons.flaskConical,
    'gamepad': LucideIcons.gamepad2,
    'laptop': LucideIcons.laptop,
    'rocket': LucideIcons.rocket,
    'settings': LucideIcons.settings,
  };

  IconData _getWorkspaceIcon(Workspace workspace) {
    if (workspace.icon == null) return LucideIcons.folder;
    return _iconMapping[workspace.icon] ?? LucideIcons.folder;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.t;

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
              alignment:
                  widget.isCollapsed ? Alignment.center : Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: widget.isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  if (!widget.isCollapsed) const Gap(8),
                  ShadButton.ghost(
                    padding: EdgeInsets.zero,
                    width: 32,
                    height: 32,
                    onPressed: widget.onToggle,
                    child: Icon(
                      LucideIcons.menu,
                      color: theme.colorScheme.foreground,
                      size: 18,
                    ),
                  ),
                  if (!widget.isCollapsed) ...[
                    const Gap(8),
                    Expanded(
                      child: Text(
                        l10n.workspaces,
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

            // Search Field (only when expanded)
            if (!widget.isCollapsed)
              BlocBuilder<WorkspaceBloc, WorkspaceState>(
                builder: (context, state) => WorkspaceSearchField(
                  workspaces: state.workspaces,
                  onFilter: (query) => setState(() => _searchQuery = query),
                ),
              ),

            // Workspace List
            Expanded(
              child: BlocBuilder<WorkspaceBloc, WorkspaceState>(
                builder: (context, state) {
                  final filteredWorkspaces =
                      _filterWorkspaces(state.workspaces);

                  if (filteredWorkspaces.isEmpty && !widget.isCollapsed) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.noWorkspaces,
                          style: theme.textTheme.muted.copyWith(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemCount: filteredWorkspaces.length,
                    onReorder: (oldIndex, newIndex) {
                      // Find the workspaces being moved
                      final movedWorkspace = filteredWorkspaces[oldIndex];

                      // Calculate boundary: find first unpinned index
                      final firstUnpinnedIndex =
                          filteredWorkspaces.indexWhere((w) => !w.isPinned);
                      final pinnedCount = firstUnpinnedIndex == -1
                          ? filteredWorkspaces.length
                          : firstUnpinnedIndex;

                      // For newIndex, adjust for the "remove then insert" behavior
                      var effectiveNewIndex =
                          oldIndex < newIndex ? newIndex - 1 : newIndex;

                      // Enforce constraints by clamping index
                      if (!movedWorkspace.isPinned) {
                        // Unpinned item: must stay in unpinned zone (>= pinnedCount)
                        if (effectiveNewIndex < pinnedCount) {
                          effectiveNewIndex = pinnedCount;
                        }
                      } else {
                        // Pinned item: must stay in pinned zone (< pinnedCount)
                        if (effectiveNewIndex >= pinnedCount) {
                          effectiveNewIndex =
                              pinnedCount > 0 ? pinnedCount - 1 : 0;
                        }
                      }

                      // Verify effectiveNewIndex is within bounds of filtered list
                      if (effectiveNewIndex < 0) effectiveNewIndex = 0;
                      if (effectiveNewIndex >= filteredWorkspaces.length) {
                        effectiveNewIndex = filteredWorkspaces.length - 1;
                      }

                      // Identify the item currently at effectiveNewIndex (in the conceptual list without moved item)
                      // Logic: we want to be at `effectiveNewIndex`.
                      // The item currently at `effectiveNewIndex` in the *full* filtered list (including moved)
                      // is either the one we want to be before, or something else.

                      // Simpler: Map to global index.
                      // Remove moved item from filtered list temporarily
                      final tempFiltered =
                          List<Workspace>.from(filteredWorkspaces)
                            ..removeAt(oldIndex);

                      int actualNewIndex;
                      if (tempFiltered.isEmpty) {
                        actualNewIndex = 0; // Should not happen if moving
                      } else if (effectiveNewIndex >= tempFiltered.length) {
                        // Insert after the last item
                        final lastItem = tempFiltered.last;
                        actualNewIndex = state.workspaces.indexOf(lastItem) + 1;
                      } else {
                        // Insert before the item at effectiveNewIndex
                        final targetNeighbor = tempFiltered[effectiveNewIndex];
                        actualNewIndex =
                            state.workspaces.indexOf(targetNeighbor);
                      }

                      // Ensure actualNewIndex is valid relative to original list state
                      // Note: state.workspaces still has the moved item.
                      // If inserting index is > oldIndex (global), we need to check adjustment?
                      // The standard BLoC event likely handles "remove at old, insert at new".
                      // If we use the index of neighbor, that is the index *before* removal if neighbor is *after* old?
                      // If neighbor is *before* old, index is stable.
                      // If neighbor is *after* old, removing old shifts neighbor down by 1.
                      // So `actualNewIndex` (target neighbor's current global index) is correct for insertion?
                      // Example: [A, B, C]. Move A to after B.
                      // Filtered: [A, B, C]. Old=0. Temp: [B, C].
                      // EffectiveNew=1 (after B). Neighbor=C (index 1 in temp).
                      // Neighbor C global index = 2.
                      // Result: Remove A (0), Insert at 2?
                      // [B, C]. Insert at 2 -> [B, C, A]. Correct.
                      // Wait, if neighbor is C (2), inserting at 2 puts it *before* C?
                      // Yes. [B, A, C].
                      // So if we want to be *after* B (index 1), we need to insert at 2.
                      // So finding neighbor at `effectiveNewIndex` (which is C) and using its index (2) works.

                      // Example 2: Move C to before B.
                      // [A, B, C]. Old=2. Temp=[A, B].
                      // Effective=1 (before B). Neighbor=B (index 1 in temp).
                      // Neighbor B global index = 1.
                      // Remove C (2). [A, B]. Insert at 1. [A, C, B]. Correct.

                      // So `state.workspaces.indexOf(targetNeighbor)` is correct.

                      // Edge case: adding to very end.
                      // `effectiveNewIndex >= tempFiltered.length`.
                      // `state.workspaces.indexOf(lastItem) + 1`.
                      // [A, B, C]. Move B to end.
                      // Old=1. Temp=[A, C].
                      // Effective=2.
                      // Last item C. Global index 2. New index = 2+1=3.
                      // Remove B (1). [A, C]. Insert at 3. [A, C, B]. Correct.

                      final oldWorkspace = filteredWorkspaces[oldIndex];
                      final actualOldIndex =
                          state.workspaces.indexOf(oldWorkspace);

                      context.read<WorkspaceBloc>().add(
                            ReorderWorkspaces(
                              oldIndex: actualOldIndex,
                              newIndex: actualNewIndex,
                            ),
                          );
                    },
                    itemBuilder: (context, index) {
                      final workspace = filteredWorkspaces[index];
                      final isSelected =
                          workspace.id == state.selectedWorkspaceId;

                      final controller = _contextMenuControllers.putIfAbsent(
                        workspace.id,
                        () => ShadContextMenuController(),
                      );

                      return ReorderableDragStartListener(
                        key: ValueKey(workspace.id),
                        index: index,
                        child: WorkspaceContextMenuWrapper(
                          controller: controller,
                          workspace: workspace,
                          onEdit: () => _showEditDialog(context, workspace),
                          onOpen: () => _handleContextMenuOpen(workspace.id),
                          child: ShadTooltip(
                            builder: (context) => Text(workspace.path),
                            child: InkWell(
                              onTap: () =>
                                  _selectWorkspace(context, workspace.id),
                              child: _WorkspaceListItem(
                                workspace: workspace,
                                isSelected: isSelected,
                                isCollapsed: widget.isCollapsed,
                                icon: _getWorkspaceIcon(workspace),
                              ),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: ShadButton.ghost(
                onPressed: () => showAddWorkspaceDialog(context),
                width: widget.isCollapsed ? 32 : null,
                height: 32,
                padding: widget.isCollapsed
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
                    if (!widget.isCollapsed) ...[
                      const Gap(8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text(
                          l10n.addWorkspace,
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

/// Individual workspace list item widget with Stack-based selection highlight.
class _WorkspaceListItem extends StatelessWidget {
  const _WorkspaceListItem({
    required this.workspace,
    required this.isSelected,
    required this.isCollapsed,
    required this.icon,
  });

  final Workspace workspace;
  final bool isSelected;
  final bool isCollapsed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    // Height adjusts based on tags presence
    final hasTags = workspace.tags.isNotEmpty && !isCollapsed;
    final itemHeight = hasTags ? 56.0 : 40.0;

    return SizedBox(
      height: itemHeight,
      child: Stack(
        children: [
          // Selection highlight background (positioned behind content)
          if (isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
          // Left border indicator for selection
          if (isSelected)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          // Content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 0 : 12,
                vertical: hasTags ? 6 : 0,
              ),
              child: isCollapsed
                  ? _buildCollapsedContent(theme)
                  : _buildExpandedContent(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedContent(ShadThemeData theme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          workspace.name.isNotEmpty ? workspace.name[0].toUpperCase() : '?',
          style: theme.textTheme.small.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.foreground,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (workspace.isPinned)
          Positioned(
            top: 2,
            right: 8,
            child: Icon(
              LucideIcons.pin,
              size: 8,
              color: theme.colorScheme.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildExpandedContent(ShadThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Icon
        Icon(
          icon,
          size: 16,
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.grey.withValues(alpha: 0.5),
        ),
        const Gap(8),
        // Right Column: Title + Tags
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title Row
              Row(
                children: [
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
                  if (workspace.isPinned)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        LucideIcons.pin,
                        size: 12,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        LucideIcons.check,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
              // Tags Row
              if (workspace.tags.isNotEmpty) ...[
                const Gap(4),
                WorkspaceTagChips(
                  tags: workspace.tags,
                  maxTags: 2,
                  isCompact: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
