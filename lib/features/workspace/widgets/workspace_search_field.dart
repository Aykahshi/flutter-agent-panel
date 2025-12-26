import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/extensions/context_extension.dart';
import '../models/workspace.dart';

/// A search field with autocomplete for filtering workspaces.
/// Uses Flutter's native Autocomplete widget with responsive width.
class WorkspaceSearchField extends StatelessWidget {
  const WorkspaceSearchField({
    super.key,
    required this.workspaces,
    required this.onFilter,
  });

  final List<Workspace> workspaces;
  final ValueChanged<String> onFilter;

  Iterable<Workspace> _optionsBuilder(TextEditingValue textEditingValue) {
    if (textEditingValue.text.isEmpty) {
      return const Iterable<Workspace>.empty();
    }

    final query = textEditingValue.text.toLowerCase();
    return workspaces.where((workspace) {
      return workspace.name.toLowerCase().contains(query) ||
          workspace.tags.any((tag) => tag.toLowerCase().contains(query));
    }).take(5);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.t;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Autocomplete<Workspace>(
            optionsBuilder: _optionsBuilder,
            displayStringForOption: (workspace) => workspace.name,
            onSelected: (workspace) => onFilter(workspace.name),
            fieldViewBuilder: (
              context,
              textEditingController,
              focusNode,
              onFieldSubmitted,
            ) {
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: l10n.searchWorkspaces,
                  hintStyle: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                  prefixIcon: Icon(
                    LucideIcons.search,
                    size: 14,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  suffixIcon: textEditingController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            textEditingController.clear();
                            onFilter('');
                          },
                          child: Icon(
                            LucideIcons.x,
                            size: 14,
                            color: theme.colorScheme.mutedForeground,
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: theme.colorScheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: theme.colorScheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                style: theme.textTheme.small,
                onChanged: onFilter,
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              // Use parent width minus padding
              final optionsWidth = constraints.maxWidth - 16;
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(6),
                  color: theme.colorScheme.popover,
                  child: Container(
                    width: optionsWidth,
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: theme.colorScheme.border),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final workspace = options.elementAt(index);
                        return InkWell(
                          onTap: () => onSelected(workspace),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.folder,
                                  size: 14,
                                  color: theme.colorScheme.mutedForeground,
                                ),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    workspace.name,
                                    style: theme.textTheme.small,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
