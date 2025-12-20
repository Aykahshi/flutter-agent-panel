import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../workspace/bloc/workspace_bloc.dart';

class WorkspaceDrawer extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const WorkspaceDrawer({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
  });

  Future<void> _addWorkspace(BuildContext context) async {
    final String? selectedDirectory =
        await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      final name = selectedDirectory.split(RegExp(r'[/\\]')).last;

      if (context.mounted) {
        final l10n = context.t;
        context.read<WorkspaceBloc>().add(AddWorkspace(
              path: selectedDirectory,
              name: name.isEmpty ? l10n.workspace : name,
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

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
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            alignment: isCollapsed ? Alignment.center : Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                if (!isCollapsed) SizedBox(width: 8.w),
                ShadButton.ghost(
                  padding: EdgeInsets.zero,
                  width: 32.w,
                  height: 32.h,
                  onPressed: onToggle,
                  child: Icon(LucideIcons.menu,
                      color: theme.colorScheme.foreground, size: 18.sp),
                ),
                if (!isCollapsed) ...[
                  SizedBox(width: 8.w),
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
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        context.t.noWorkspaces,
                        style: theme.textTheme.muted.copyWith(fontSize: 12.sp),
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
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : null,
                            border: isSelected
                                ? Border(
                                    left: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 2.w,
                                    ),
                                  )
                                : null,
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: isCollapsed ? 0 : 12.w),
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
                                    Icon(LucideIcons.folder,
                                        size: 16.sp,
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : Colors.grey
                                                .withValues(alpha: 0.5)),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        workspace.name,
                                        style: theme.textTheme.small.copyWith(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.foreground,
                                          fontSize: 14.sp,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    if (isSelected)
                                      Padding(
                                        padding: EdgeInsets.only(left: 4.w),
                                        child: Icon(LucideIcons.check,
                                            size: 14.sp,
                                            color: theme.colorScheme.primary),
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
            padding: EdgeInsets.symmetric(vertical: 8.h),
            alignment: Alignment.center,
            child: ShadButton.ghost(
              onPressed: () => _addWorkspace(context),
              width: isCollapsed ? 32.w : null,
              height: 32.h,
              padding: isCollapsed
                  ? EdgeInsets.zero
                  : EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(LucideIcons.plus,
                      color: theme.colorScheme.primary, size: 18.sp),
                  if (!isCollapsed) ...[
                    SizedBox(width: 8.w),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: 1.h), // Tiny adjustment for alignment
                      child: Text(
                        context.t.addWorkspace,
                        style: theme.textTheme.small.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: 8.h),
        ],
      ),
    ));
  }
}
