import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/types/typedefs.dart';
import '../../settings/bloc/settings_bloc.dart';
import '../../settings/models/app_settings.dart';

/// Shell selection popover for creating new terminals.
class ShellSelectionPopover extends StatelessWidget {
  const ShellSelectionPopover({
    super.key,
    required this.controller,
    required this.workspaceId,
    required this.onAddTerminal,
  });
  final ShadPopoverController controller;
  final String workspaceId;
  final AddTerminalCallback onAddTerminal;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return ShadPopover(
      controller: controller,
      padding: EdgeInsets.zero,
      child: ShadButton.outline(
        padding: EdgeInsets.zero,
        size: ShadButtonSize.sm,
        onPressed: () => controller.toggle(),
        child: Icon(
          LucideIcons.terminal,
          size: 16,
          color: theme.colorScheme.mutedForeground,
        ),
      ),
      popover: (context) => _buildPopoverContent(context, theme),
    );
  }

  Widget _buildPopoverContent(BuildContext context, ShadThemeData theme) {
    final l10n = context.t;
    final settings = context.read<SettingsBloc>().state.settings;

    return SizedBox(
      width: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              l10n.selectShell,
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.border),
          // Built-in shells (excluding custom type)
          ...ShellType.values
              .where((s) => s != ShellType.custom)
              .map((shell) => _buildShellItem(context, theme, shell, l10n)),
          // Custom shells from settings
          if (settings.customShells.isNotEmpty) ...[
            Divider(height: 1, color: theme.colorScheme.border),
            ...settings.customShells
                .map((shell) => _buildCustomShellItem(context, theme, shell)),
          ],
        ],
      ),
    );
  }

  Widget _buildShellItem(
    BuildContext context,
    ShadThemeData theme,
    ShellType shell,
    AppLocalizations l10n,
  ) {
    return InkWell(
      onTap: () {
        controller.hide();
        onAddTerminal(
          context,
          workspaceId,
          shellCmd: shell.command,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              _getShellIcon(shell.icon),
              size: 16,
            ),
            const Gap(8),
            Text(_getShellTypeLocalizedName(shell, l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomShellItem(
    BuildContext context,
    ShadThemeData theme,
    CustomShellConfig shell,
  ) {
    return InkWell(
      onTap: () {
        controller.hide();
        onAddTerminal(
          context,
          workspaceId,
          shellCmd: 'custom:${shell.id}',
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              LucideIcons.terminal,
              size: 16,
            ),
            const Gap(8),
            Text(shell.name),
          ],
        ),
      ),
    );
  }

  IconData _getShellIcon(String iconName) => switch (iconName) {
        'terminal' => LucideIcons.terminal,
        'command' => LucideIcons.squareTerminal,
        'server' => LucideIcons.server,
        'gitBranch' => LucideIcons.gitBranch,
        'box' => LucideIcons.box,
        'settings' => LucideIcons.settings,
        _ => LucideIcons.terminal,
      };

  String _getShellTypeLocalizedName(ShellType shell, AppLocalizations l10n) =>
      switch (shell) {
        ShellType.pwsh7 => l10n.pwsh7,
        ShellType.powershell => l10n.powershell,
        ShellType.cmd => l10n.cmd,
        ShellType.wsl => l10n.wsl,
        ShellType.gitBash => l10n.gitBash,
        ShellType.custom => l10n.custom,
      };
}
