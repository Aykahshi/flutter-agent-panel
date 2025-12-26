import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/extensions/context_extension.dart';
import '../models/app_settings.dart';
import 'settings_section.dart';
import 'shell_dialog.dart';

/// Custom shells settings content widget.
class CustomShellsContent extends StatelessWidget {
  const CustomShellsContent({
    super.key,
    required this.settings,
  });

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.t;
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSection(
          title: l10n.customShells,
          description: l10n.customShellsDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShadButton.outline(
                onPressed: () => showAddEditShellDialog(context, l10n, theme),
                leading: Icon(LucideIcons.plus, size: 16.sp),
                child: Text(l10n.addCustomShell),
              ),
              Gap(16.h),
              if (settings.customShells.isEmpty)
                _buildEmptyState(context)
              else
                ...settings.customShells.map(
                  (shell) => _buildShellItem(context, shell),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = context.t;
    final theme = context.theme;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              LucideIcons.terminal,
              size: 48.sp,
              color: theme.colorScheme.mutedForeground,
            ),
            Gap(12.h),
            Text(l10n.noCustomShells, style: theme.textTheme.large),
            Gap(4.h),
            Text(
              l10n.addYourFirstCustomShell,
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShellItem(BuildContext context, CustomShellConfig shell) {
    final l10n = context.t;
    final theme = context.theme;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.terminal,
            size: 24.sp,
            color: theme.colorScheme.primary,
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(shell.name, style: theme.textTheme.p),
                  ],
                ),
                Gap(2.h),
                Text(
                  shell.path,
                  style: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ShadButton.ghost(
            padding: EdgeInsets.zero,
            width: 32.w,
            height: 32.h,
            onPressed: () => showAddEditShellDialog(
              context,
              l10n,
              theme,
              existingShell: shell,
            ),
            child: Icon(LucideIcons.pencil, size: 16.sp),
          ),
          ShadButton.ghost(
            padding: EdgeInsets.zero,
            width: 32.w,
            height: 32.h,
            onPressed: () => confirmDeleteShell(context, shell, l10n),
            child: Icon(
              LucideIcons.trash2,
              size: 16.sp,
              color: theme.colorScheme.destructive,
            ),
          ),
        ],
      ),
    );
  }
}
