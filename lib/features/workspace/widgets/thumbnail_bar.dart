import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:gap/gap.dart';
import '../../../core/constants/assets.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/types/typedefs.dart';
import '../../../shared/constants/app_colors.dart';
import '../../settings/models/app_settings.dart';
import '../../terminal/models/terminal_config.dart';
import '../../terminal/models/terminal_node.dart';
import '../../terminal/widgets/glowing_icon.dart';
import '../bloc/workspace_bloc.dart';
import '../models/workspace.dart';
import 'agent_selection_popover.dart';
import 'shell_selection_popover.dart';

class ThumbnailBar extends StatelessWidget {
  const ThumbnailBar({
    super.key,
    required this.workspace,
    required this.settings,
    required this.terminals,
    required this.activeTerminalId,
    required this.onTerminalSelected,
    required this.onTerminalClosed,
    required this.onAddTerminal,
    required this.popoverController,
    required this.agentPopoverController,
  });

  final Workspace workspace;
  final AppSettings settings;
  final Map<String, TerminalNode> terminals;
  final String? activeTerminalId;
  final ValueChanged<String> onTerminalSelected;
  final TerminalIdCallback onTerminalClosed;
  final AddTerminalCallback onAddTerminal;
  final ShadPopoverController popoverController;
  final ShadPopoverController agentPopoverController;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(
          top: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        children: [
          SizedBox(
            height: 104,
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              buildDefaultDragHandles: false,
              itemCount: workspace.terminals.length,
              onReorder: (oldIndex, newIndex) {
                context.read<WorkspaceBloc>().add(
                      ReorderTerminalsInWorkspace(
                        workspaceId: workspace.id,
                        oldIndex: oldIndex,
                        newIndex: newIndex,
                      ),
                    );
              },
              itemBuilder: (context, index) {
                final config = workspace.terminals[index];
                final node = terminals[config.id];
                final isActive = config.id == activeTerminalId;

                return ReorderableDragStartListener(
                  key: ValueKey(config.id),
                  index: index,
                  child: GestureDetector(
                    onTap: () => onTerminalSelected(config.id),
                    child: _ThumbnailItem(
                      config: config,
                      node: node,
                      isActive: isActive,
                      workspace: workspace,
                      settings: settings,
                      onClose: () => onTerminalClosed(config.id),
                    ),
                  ),
                );
              },
            ),
          ),
          // Shell Selection Popover
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: ShadTooltip(
              builder: (context) => Text(context.t.addTerminal),
              child: SizedBox(
                width: 36,
                height: 36,
                child: ShellSelectionPopover(
                  controller: popoverController,
                  workspaceId: workspace.id,
                  onAddTerminal: onAddTerminal,
                ),
              ),
            ),
          ),
          // Agent Selection Popover
          if (settings.agents.any((a) => a.enabled))
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ShadTooltip(
                builder: (context) => Text(context.t.addAgent),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: AgentSelectionPopover(
                    controller: agentPopoverController,
                    workspaceId: workspace.id,
                    enabledAgents:
                        settings.agents.where((a) => a.enabled).toList(),
                    onAddTerminal: onAddTerminal,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ThumbnailItem extends StatelessWidget {
  const _ThumbnailItem({
    required this.config,
    required this.node,
    required this.isActive,
    required this.workspace,
    required this.settings,
    required this.onClose,
  });

  final TerminalConfig config;
  final TerminalNode? node;
  final bool isActive;
  final Workspace workspace;
  final AppSettings settings;
  final VoidCallback onClose;

  String? _getAgentIconPath(AgentPreset preset, ShadThemeData theme) =>
      switch (preset) {
        AgentPreset.claude => Assets.claudeLogo,
        AgentPreset.gemini => Assets.geminiLogo,
        AgentPreset.codex => Assets.chatgptLogo,
        AgentPreset.qwen => Assets.qwenLogo,
        AgentPreset.opencode => theme.brightness == Brightness.dark
            ? Assets.opencodeDarkLogo
            : Assets.opencodeLogo,
        AgentPreset.githubCopilot => Assets.githubCopilotLogo,
        _ => null,
      };

  IconData _getIconData(String terminalId, Workspace workspace) {
    // We need to access the map or logic for icons.
    // Since this logic was inside WorkspaceView, we should probably pass it in or duplicate active mapping.
    // For now, I'll copy the map here or make it shared.
    // To keep it clean, I will just include the map here as static or independent.
    // Actually, it's better to duplicate the map here or put it in a shared place.
    // Given the refactor, let's put it here for now as checking workspace config icon.
    final iconName = config.icon;
    if (iconName == null) return LucideIcons.terminal;
    return _iconMapping[iconName] ?? LucideIcons.terminal;
  }

  static const Map<String, IconData> _iconMapping = {
    'terminal': LucideIcons.terminal,
    'command': LucideIcons.command,
    'bug': LucideIcons.bug,
    'server': LucideIcons.server,
    'shield': LucideIcons.shield,
    'code': LucideIcons.code,
    'monitor': LucideIcons.monitor,
    'cpu': LucideIcons.cpu,
    'database': LucideIcons.database,
    'activity': LucideIcons.activity,
    'globe': LucideIcons.globe,
    'box': LucideIcons.box,
    'cloud': LucideIcons.cloud,
    'layout': LucideIcons.layoutPanelLeft,
    'blocks': LucideIcons.blocks,
    'flask': LucideIcons.flaskConical,
    'gitBranch': LucideIcons.gitBranch,
    'docker': LucideIcons.package,
    'search': LucideIcons.search,
    'settings': LucideIcons.settings,
    'zap': LucideIcons.zap,
    'package': LucideIcons.package,
    'git-branch': LucideIcons.gitBranch,
    'flask-conical': LucideIcons.flaskConical,
    'layout-panel-left': LucideIcons.layoutPanelLeft,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return AspectRatio(
      aspectRatio: 1.2,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: AppColors.terminalBackground,
          border: Border.all(
            color:
                isActive ? theme.colorScheme.primary : theme.colorScheme.border,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              color:
                  isActive ? theme.colorScheme.primary : theme.colorScheme.card,
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              child: Row(
                children: [
                  const Gap(4),
                  Expanded(
                    child: Text(
                      config.title,
                      style: theme.textTheme.small.copyWith(
                        color: isActive
                            ? theme.colorScheme.primaryForeground
                            : theme.colorScheme.foreground,
                        fontSize: 11,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onClose,
                    child: Icon(
                      LucideIcons.x,
                      size: 12,
                      color: isActive
                          ? theme.colorScheme.primaryForeground
                          : theme.colorScheme.foreground,
                    ),
                  ),
                ],
              ),
            ),
            // Preview Area
            Expanded(
              child: Container(
                color: theme.colorScheme.background.withValues(alpha: 0.5),
                child: Center(
                  child: () {
                    IconData? iconData;
                    String? svgPath;

                    if (config.agentId != null) {
                      final agent = settings.agents
                          .where((a) => a.id == config.agentId)
                          .firstOrNull;
                      if (agent != null) {
                        svgPath = _getAgentIconPath(agent.preset, theme);
                      }
                    }

                    if (svgPath == null) {
                      iconData = _getIconData(config.id, workspace);
                    }

                    return GlowingIcon(
                      icon: iconData,
                      svgPath: svgPath,
                      status: node?.status ?? TerminalStatus.disconnected,
                      size: 32,
                      baseColor: isActive ? theme.colorScheme.primary : null,
                    );
                  }(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
