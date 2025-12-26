import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/constants/assets.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/types/typedefs.dart';
import '../../settings/models/agent_config.dart';
import '../../terminal/models/terminal_node.dart';
import '../../terminal/widgets/activity_indicator.dart';
import '../models/workspace.dart';
import 'icon_option.dart';

/// Top bar showing the active terminal's title, icon, and controls.
class TerminalTopBar extends StatelessWidget {
  const TerminalTopBar({
    super.key,
    required this.activeNode,
    required this.agentConfig,
    required this.workspace,
    required this.agentColor,
    required this.topBarColor,
    required this.topBarBorderColor,
    required this.titleController,
    required this.iconPopoverController,
    required this.iconMapping,
    required this.onRefresh,
    required this.onClose,
    required this.onUpdateTitle,
    required this.getIconData,
  });
  final TerminalNode? activeNode;
  final AgentConfig? agentConfig;
  final Workspace workspace;
  final Color? agentColor;
  final Color topBarColor;
  final Color topBarBorderColor;
  final TextEditingController titleController;
  final ShadPopoverController iconPopoverController;
  final Map<String, IconData> iconMapping;
  final VoidCallback onRefresh;
  final VoidCallback onClose;
  final UpdateTitleCallback onUpdateTitle;
  final GetIconDataCallback getIconData;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: topBarColor,
        border: Border(
          bottom: BorderSide(
            color: topBarBorderColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Row(
        children: [
          if (activeNode != null)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (agentConfig != null) ...[
                    _buildAgentIcon(context, theme),
                    const Gap(8),
                    _buildAgentTitle(theme),
                  ] else ...[
                    _buildIconSelector(context, theme),
                    const Gap(4),
                    _buildTitleInput(theme),
                  ],
                  const Gap(24),
                  ActivityIndicator(
                    status: activeNode!.status,
                    size: 8,
                  ),
                  const Gap(16),
                  _buildRefreshButton(theme),
                  _buildCloseButton(theme),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAgentIcon(BuildContext context, ShadThemeData theme) {
    return Container(
      width: 32,
      height: 32,
      padding: const EdgeInsets.all(
        4,
      ),
      child: agentConfig!.preset.iconAssetPath != null
          ? Builder(
              builder: (context) {
                var iconPath = agentConfig!.preset.iconAssetPath!;
                ColorFilter? colorFilter;

                if (agentConfig!.preset == AgentPreset.opencode &&
                    Theme.of(context).brightness == Brightness.dark) {
                  iconPath = Assets.opencodeDarkLogo;
                }

                if (agentConfig!.preset == AgentPreset.codex ||
                    agentConfig!.preset == AgentPreset.githubCopilot) {
                  colorFilter = ColorFilter.mode(
                    theme.colorScheme.foreground,
                    BlendMode.srcIn,
                  );
                }

                return SvgPicture.asset(
                  iconPath,
                  colorFilter: colorFilter,
                );
              },
            )
          : Icon(
              LucideIcons.bot,
              color: agentColor ?? theme.colorScheme.primary,
            ),
    );
  }

  Widget _buildAgentTitle(ShadThemeData theme) {
    return Expanded(
      child: Text(
        activeNode!.title,
        style: theme.textTheme.large.copyWith(
          color: agentColor ?? theme.colorScheme.foreground,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIconSelector(BuildContext context, ShadThemeData theme) {
    return ShadPopover(
      controller: iconPopoverController,
      popover: (context) => Container(
        width: 300,
        height: 300,
        padding: const EdgeInsets.all(
          8,
        ),
        child: GridView.count(
          crossAxisCount: 5,
          children: [
            ...iconMapping.keys.map(
              (iconName) => IconOption(
                iconName: iconName,
                node: activeNode!,
                workspace: workspace,
                iconMapping: iconMapping,
                onClose: () => iconPopoverController.toggle(),
              ),
            ),
          ],
        ),
      ),
      child: ShadButton.ghost(
        padding: EdgeInsets.zero,
        width: 32,
        height: 32,
        onPressed: () => iconPopoverController.toggle(),
        child: Icon(
          getIconData(
            activeNode!.id,
            workspace,
          ),
          size: 18,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTitleInput(ShadThemeData theme) {
    return Expanded(
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            onUpdateTitle(activeNode!, workspace);
          }
        },
        child: ShadInput(
          key: ValueKey(activeNode!.id),
          controller: titleController..text = activeNode!.title,
          style: theme.textTheme.large,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: const ShadDecoration(
            border: ShadBorder.none,
            focusedBorder: ShadBorder.none,
            errorBorder: ShadBorder.none,
            secondaryBorder: ShadBorder.none,
            secondaryFocusedBorder: ShadBorder.none,
          ),
          onSubmitted: (value) => onUpdateTitle(
            activeNode!,
            workspace,
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshButton(ShadThemeData theme) {
    return ShadButton.ghost(
      width: 32,
      height: 32,
      padding: EdgeInsets.zero,
      onPressed: onRefresh,
      child: Icon(
        LucideIcons.refreshCw,
        size: 16,
        color: theme.colorScheme.mutedForeground,
      ),
    );
  }

  Widget _buildCloseButton(ShadThemeData theme) {
    return ShadButton.ghost(
      width: 32,
      height: 32,
      padding: EdgeInsets.zero,
      onPressed: onClose,
      child: Icon(
        LucideIcons.x,
        size: 16,
        color: theme.colorScheme.mutedForeground,
      ),
    );
  }
}
