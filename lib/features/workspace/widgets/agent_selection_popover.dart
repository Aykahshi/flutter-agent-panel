import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/constants/assets.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/types/typedefs.dart';
import '../../settings/models/agent_config.dart';

/// Agent selection popover for creating new agent terminals.
class AgentSelectionPopover extends StatelessWidget {
  const AgentSelectionPopover({
    super.key,
    required this.controller,
    required this.workspaceId,
    required this.enabledAgents,
    required this.onAddTerminal,
  });
  final ShadPopoverController controller;
  final String workspaceId;
  final List<AgentConfig> enabledAgents;
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
          LucideIcons.bot,
          size: 16,
          color: theme.colorScheme.mutedForeground,
        ),
      ),
      popover: (context) => _buildPopoverContent(context, theme),
    );
  }

  Widget _buildPopoverContent(BuildContext context, ShadThemeData theme) {
    return SizedBox(
      width: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              context.t.agents,
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.border),
          ...enabledAgents
              .map((agent) => _buildAgentItem(context, theme, agent)),
        ],
      ),
    );
  }

  Widget _buildAgentItem(
    BuildContext context,
    ShadThemeData theme,
    AgentConfig agent,
  ) {
    return InkWell(
      onTap: () {
        controller.toggle();
        onAddTerminal(
          context,
          workspaceId,
          agentId: agent.id,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: agent.preset.iconAssetPath != null
                  ? Builder(
                      builder: (context) {
                        var iconPath = agent.preset.iconAssetPath!;
                        ColorFilter? colorFilter;

                        // Adapt Opencode icon for dark mode
                        if (agent.preset == AgentPreset.opencode &&
                            Theme.of(context).brightness == Brightness.dark) {
                          iconPath = Assets.opencodeDarkLogo;
                        }

                        // Adapt Codex and Github Copilot icon color
                        if (agent.preset == AgentPreset.codex ||
                            agent.preset == AgentPreset.githubCopilot) {
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
                  : const Icon(
                      LucideIcons.bot,
                      size: 16,
                    ),
            ),
            const Gap(8),
            Text(agent.name),
          ],
        ),
      ),
    );
  }
}
