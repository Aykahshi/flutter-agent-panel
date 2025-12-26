import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/utils/platform_utils.dart';
import '../bloc/settings_bloc.dart';
import '../models/app_settings.dart';

/// Shows add/edit shell dialog.
void showAddEditShellDialog(
  BuildContext context,
  AppLocalizations l10n,
  ShadThemeData theme, {
  CustomShellConfig? existingShell,
}) {
  final nameController = TextEditingController(text: existingShell?.name ?? '');
  final pathController = TextEditingController(text: existingShell?.path ?? '');

  showShadDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return ShadDialog(
          title: Text(
            existingShell != null ? l10n.editCustomShell : l10n.addCustomShell,
          ),
          description: const SizedBox.shrink(),
          child: Container(
            width: 400.w,
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.shellName, style: theme.textTheme.small),
                Gap(8.h),
                ShadInput(
                  controller: nameController,
                  placeholder: Text(l10n.shellNamePlaceholder),
                ),
                Gap(16.h),
                Text(l10n.customShellPath, style: theme.textTheme.small),
                Gap(8.h),
                Row(
                  children: [
                    Expanded(
                      child: ShadInput(
                        controller: pathController,
                        placeholder: Text(l10n.shellPathPlaceholder),
                      ),
                    ),
                    Gap(8.w),
                    ShadButton.outline(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: PlatformUtils.isWindows
                              ? ['exe', 'bat', 'cmd']
                              : [],
                        );
                        if (result != null &&
                            result.files.single.path != null) {
                          pathController.text = result.files.single.path!;
                        }
                      },
                      child: Text(l10n.browse),
                    ),
                  ],
                ),
                Gap(16.h),
                Gap(24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ShadButton.ghost(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                    Gap(8.w),
                    ShadButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final path = pathController.text.trim();
                        if (name.isEmpty || path.isEmpty) return;

                        if (existingShell != null) {
                          context.read<SettingsBloc>().add(
                                UpdateCustomShell(
                                  existingShell.copyWith(
                                    name: name,
                                    path: path,
                                  ),
                                ),
                              );
                        } else {
                          context.read<SettingsBloc>().add(
                                AddCustomShell(
                                  CustomShellConfig.create(
                                    name: name,
                                    path: path,
                                  ),
                                ),
                              );
                        }
                        Navigator.of(context).pop();
                      },
                      child: Text(l10n.save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Shows delete confirmation dialog for a shell.
void confirmDeleteShell(
  BuildContext context,
  CustomShellConfig shell,
  AppLocalizations l10n,
) {
  showShadDialog(
    context: context,
    builder: (context) => ShadDialog.alert(
      title: Text(l10n.deleteCustomShell),
      description: Text(l10n.confirmDeleteShell),
      actions: [
        ShadButton.ghost(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ShadButton.destructive(
          onPressed: () {
            context.read<SettingsBloc>().add(RemoveCustomShell(shell.id));
            Navigator.of(context).pop();
          },
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
}
