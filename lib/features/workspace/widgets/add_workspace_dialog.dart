import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:gap/gap.dart';

import '../../../core/extensions/context_extension.dart';
import '../bloc/workspace_bloc.dart';

/// Dialog for creating or editing a workspace.
class AddWorkspaceDialog extends StatefulWidget {
  const AddWorkspaceDialog({
    super.key,
    this.initialName,
    this.initialPath,
    this.initialIcon,
    this.initialTags,
    this.workspaceId,
  });

  /// If workspaceId is provided, the dialog is in edit mode.
  final String? workspaceId;
  final String? initialName;
  final String? initialPath;
  final String? initialIcon;
  final List<String>? initialTags;

  bool get isEditMode => workspaceId != null;

  @override
  State<AddWorkspaceDialog> createState() => _AddWorkspaceDialogState();
}

class _AddWorkspaceDialogState extends State<AddWorkspaceDialog> {
  final _nameController = TextEditingController();
  final _pathController = TextEditingController();
  final _tagsController = TextEditingController();
  String? _selectedIcon;

  static const _availableIcons = [
    'folder',
    'briefcase',
    'code',
    'database',
    'globe',
    'house',
    'layers',
    'package',
    'server',
    'shield',
    'star',
    'zap',
    'smartphone',
    'notepadText',
    'appWindow',
    'bookmark',
    'bug',
    'cloud',
    'fileCode',
    'flask',
    'gamepad',
    'laptop',
    'rocket',
    'settings',
  ];

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

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _pathController.text = widget.initialPath ?? '';
    _selectedIcon = widget.initialIcon;
    _tagsController.text = widget.initialTags?.join(', ') ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickDirectory() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      _pathController.text = path;
      // Auto-fill name if empty
      if (_nameController.text.isEmpty) {
        final name = path.split(RegExp(r'[/\\]')).last;
        _nameController.text = name;
      }
      setState(() {});
    }
  }

  List<String> _parseTags() {
    final text = _tagsController.text.trim();
    if (text.isEmpty) return [];
    return text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final path = _pathController.text.trim();

    if (name.isEmpty || path.isEmpty) return;

    final tags = _parseTags();

    if (widget.isEditMode) {
      context.read<WorkspaceBloc>().add(
            UpdateWorkspace(
              id: widget.workspaceId!,
              name: name,
              icon: _selectedIcon,
              tags: tags,
            ),
          );
    } else {
      context.read<WorkspaceBloc>().add(
            AddWorkspace(
              path: path,
              name: name,
              icon: _selectedIcon,
              tags: tags,
            ),
          );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.t;

    return ShadDialog(
      title:
          Text(widget.isEditMode ? l10n.editWorkspace : l10n.createWorkspace),
      description: const SizedBox.shrink(),
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Picker
            Text(
              l10n.workspaceIcon,
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((iconName) {
                final isSelected = _selectedIcon == iconName;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = iconName),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : theme.colorScheme.muted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      _iconMapping[iconName] ?? LucideIcons.folder,
                      size: 20,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.mutedForeground,
                    ),
                  ),
                );
              }).toList(),
            ),
            const Gap(16),

            // Name Field
            Text(
              l10n.workspaceName,
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(8),
            ShadInput(
              controller: _nameController,
              placeholder: Text(l10n.workspaceName),
            ),
            const Gap(16),

            // Path Field
            if (!widget.isEditMode) ...[
              Text(
                l10n.workspacePath,
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(8),
              Row(
                children: [
                  Expanded(
                    child: ShadInput(
                      controller: _pathController,
                      placeholder: Text(l10n.workspacePath),
                      readOnly: true,
                    ),
                  ),
                  const Gap(8),
                  ShadButton.outline(
                    onPressed: _pickDirectory,
                    child: Text(l10n.browse),
                  ),
                ],
              ),
              const Gap(16),
            ],

            // Tags Field
            Text(
              l10n.workspaceTags,
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(8),
            ShadInput(
              controller: _tagsController,
              placeholder: Text(l10n.tagsPlaceholder),
            ),
            const Gap(24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ShadButton.outline(
                  child: Text(l10n.cancel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Gap(8),
                ShadButton(
                  onPressed: _submit,
                  child: Text(l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the add/edit workspace dialog.
void showAddWorkspaceDialog(
  BuildContext context, {
  String? workspaceId,
  String? initialName,
  String? initialPath,
  String? initialIcon,
  List<String>? initialTags,
}) {
  showShadDialog(
    context: context,
    builder: (context) => AddWorkspaceDialog(
      workspaceId: workspaceId,
      initialName: initialName,
      initialPath: initialPath,
      initialIcon: initialIcon,
      initialTags: initialTags,
    ),
  );
}
