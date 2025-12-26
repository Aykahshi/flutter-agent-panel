import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:gap/gap.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/router/app_router.dart';
import '../../settings/bloc/settings_bloc.dart';
import '../../settings/models/app_settings.dart';
import '../../terminal/bloc/terminal_bloc.dart';
import '../../terminal/models/terminal_config.dart';
import '../../terminal/models/terminal_node.dart';
import '../bloc/workspace_bloc.dart';
import '../models/workspace.dart';
import '../widgets/terminal_top_bar.dart';
import '../widgets/thumbnail_bar.dart';

/// Main workspace page that displays terminal list and content.
/// Uses nested routing for terminal display.
@RoutePage()
class WorkspaceView extends StatefulWidget {
  const WorkspaceView({
    super.key,
    @pathParam required this.workspaceId,
  });

  final String workspaceId;

  @override
  State<WorkspaceView> createState() => _WorkspaceViewState();
}

class _WorkspaceViewState extends State<WorkspaceView> {
  final _titleController = TextEditingController();
  final _popoverController = ShadPopoverController();
  final _iconPopoverController = ShadPopoverController();
  final _agentPopoverController = ShadPopoverController();
  String? _activeTerminalId;

  @override
  void initState() {
    super.initState();
    _syncTerminals();
  }

  @override
  void didUpdateWidget(covariant WorkspaceView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workspaceId != widget.workspaceId) {
      _syncTerminals();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _popoverController.dispose();
    _iconPopoverController.dispose();
    _agentPopoverController.dispose();
    super.dispose();
  }

  void _syncTerminals() {
    final workspaceState = context.read<WorkspaceBloc>().state;
    final workspace = workspaceState.workspaces
        .where((w) => w.id == widget.workspaceId)
        .firstOrNull;

    if (workspace == null) return;

    // Get all terminal IDs across all workspaces
    final allTerminalIds = workspaceState.workspaces
        .expand((w) => w.terminals)
        .map((t) => t.id)
        .toSet();

    // Sync terminals with bloc
    context.read<TerminalBloc>().add(
          SyncWorkspaceTerminals(
            workspaceId: widget.workspaceId,
            configs: workspace.terminals,
            allTerminalIds: allTerminalIds,
          ),
        );

    // Set initial active terminal and navigate
    if (_activeTerminalId == null ||
        !workspace.terminals.any((t) => t.id == _activeTerminalId)) {
      if (workspace.terminals.isNotEmpty) {
        final firstId = workspace.terminals.first.id;
        setState(() {
          _activeTerminalId = firstId;
        });
        // Defer navigation until after the widget rebuild
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.router.navigate(TerminalRoute(terminalId: firstId));
          }
        });
      } else {
        _activeTerminalId = null;
      }
    }
  }

  void _addNewTerminal(
    BuildContext context,
    String workspaceId, {
    String? shellCmd,
    String? agentId,
  }) {
    final settings = context.read<SettingsBloc>().state.settings;
    final l10n = context.t;

    String effectiveShellCmd = shellCmd ?? settings.defaultShell.command;
    String terminalTitle = l10n.terminal;

    // Handle custom shell selection
    if (shellCmd != null && shellCmd.startsWith('custom:')) {
      final shellId = shellCmd.substring(7);
      final customShell =
          settings.customShells.where((s) => s.id == shellId).firstOrNull;
      if (customShell != null) {
        effectiveShellCmd = customShell.path;
        terminalTitle = customShell.name;
      }
    } else if (shellCmd == 'custom' ||
        (shellCmd == null && settings.defaultShell == ShellType.custom)) {
      if (settings.selectedCustomShellId != null) {
        final customShell = settings.customShells
            .where((s) => s.id == settings.selectedCustomShellId)
            .firstOrNull;
        if (customShell != null) {
          effectiveShellCmd = customShell.path;
          terminalTitle = customShell.name;
        }
      }
    }

    List<String> terminalArgs = [];
    if (agentId != null) {
      final agentParams = settings.agents.firstWhere((a) => a.id == agentId);
      terminalArgs = agentParams.args;
      terminalTitle = agentParams.preset == AgentPreset.custom
          ? agentParams.name
          : agentParams.preset.displayName;
    }

    final config = TerminalConfig.create(
      title: terminalTitle,
      cwd: context.read<WorkspaceBloc>().state.selectedWorkspace?.path ?? '',
      shellCmd: effectiveShellCmd,
      agentId: agentId,
      args: terminalArgs,
    );

    context.read<WorkspaceBloc>().add(
          AddTerminalToWorkspace(
            workspaceId: workspaceId,
            config: config,
          ),
        );

    // Auto select new terminal
    setState(() {
      _activeTerminalId = config.id;
    });

    // Navigate to new terminal after rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.router.navigate(TerminalRoute(terminalId: config.id));
      }
    });
  }

  void _closeTerminal(
    BuildContext context,
    String workspaceId,
    String terminalId,
  ) {
    context.read<WorkspaceBloc>().add(
          RemoveTerminalFromWorkspace(
            workspaceId: workspaceId,
            terminalId: terminalId,
          ),
        );
    context.read<TerminalBloc>().add(
          DisposeTerminal(terminalId: terminalId),
        );
  }

  void _refreshTerminal(String terminalId) {
    final workspaceState = context.read<WorkspaceBloc>().state;
    final workspace = workspaceState.workspaces
        .where((w) => w.id == widget.workspaceId)
        .firstOrNull;
    if (workspace == null) return;

    final config =
        workspace.terminals.where((t) => t.id == terminalId).firstOrNull;
    if (config == null) return;

    context.read<TerminalBloc>().add(
          RestartTerminal(
            terminalId: terminalId,
            config: config,
            workspaceId: widget.workspaceId,
          ),
        );
  }

  void _updateTitle(TerminalNode node, Workspace workspace) {
    final value = _titleController.text.trim();
    if (value.isNotEmpty && value != node.title) {
      final config = workspace.terminals.firstWhere((t) => t.id == node.id);
      context.read<WorkspaceBloc>().add(
            UpdateTerminalInWorkspace(
              workspaceId: workspace.id,
              config: config.copyWith(title: value),
            ),
          );
    }
  }

  IconData _getIconData(String terminalId, Workspace workspace) {
    try {
      final config = workspace.terminals.firstWhere((t) => t.id == terminalId);
      final iconName = config.icon;
      if (iconName == null) return LucideIcons.terminal;

      if (_iconMapping.containsKey(iconName)) {
        return _iconMapping[iconName]!;
      }
      return LucideIcons.terminal;
    } catch (_) {
      return LucideIcons.terminal;
    }
  }

  static final Map<String, IconData> _iconMapping = {
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

  Color? _getAgentColor(AgentPreset preset) => switch (preset) {
        AgentPreset.claude => const Color(0xFFD97757),
        AgentPreset.qwen => const Color(0xFF615CED),
        AgentPreset.codex => const Color(0xFF10A37F),
        AgentPreset.gemini => const Color(0xFF4E87F6),
        AgentPreset.opencode => Colors.blueGrey,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return BlocConsumer<WorkspaceBloc, WorkspaceState>(
      listener: (context, state) {
        _syncTerminals();
      },
      builder: (context, workspaceState) {
        final workspace = workspaceState.workspaces
            .where((w) => w.id == widget.workspaceId)
            .firstOrNull;
        final settings = context.watch<SettingsBloc>().state.settings;

        if (workspace == null) {
          final l10n = context.t;
          return Center(
            child: Text(
              l10n.selectWorkspacePrompt,
              style: theme.textTheme.muted.copyWith(fontSize: 16),
            ),
          );
        }

        return BlocBuilder<TerminalBloc, TerminalState>(
          builder: (context, terminalState) {
            final activeNode = _activeTerminalId != null
                ? terminalState.terminals[_activeTerminalId]
                : null;

            final activeConfig = _activeTerminalId != null
                ? workspace.terminals
                    .where((t) => t.id == _activeTerminalId)
                    .firstOrNull
                : null;

            final agentConfig = activeConfig?.agentId != null
                ? settings.agents
                    .where((a) => a.id == activeConfig!.agentId)
                    .firstOrNull
                : null;

            // Agent Color Theme
            final agentColor =
                agentConfig != null ? _getAgentColor(agentConfig.preset) : null;
            final topBarColor = agentColor != null
                ? agentColor.withValues(alpha: 0.1)
                : theme.colorScheme.card;
            final topBarBorderColor = agentColor ?? theme.colorScheme.border;

            return Column(
              children: [
                // Top Bar
                TerminalTopBar(
                  activeNode: activeNode,
                  agentConfig: agentConfig,
                  workspace: workspace,
                  agentColor: agentColor,
                  topBarColor: topBarColor,
                  topBarBorderColor: topBarBorderColor,
                  titleController: _titleController,
                  iconPopoverController: _iconPopoverController,
                  iconMapping: _iconMapping,
                  onRefresh: () => _refreshTerminal(activeNode?.id ?? ''),
                  onClose: () => _closeTerminal(
                    context,
                    workspace.id,
                    activeNode?.id ?? '',
                  ),
                  onUpdateTitle: _updateTitle,
                  getIconData: _getIconData,
                ),

                // Terminal Content (Nested Router) or Empty State
                if (_activeTerminalId !=
                    null) // Changed from activeNode != null
                  const Expanded(child: AutoRouter())
                else
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.terminal,
                            size: 64,
                            color: theme.colorScheme.mutedForeground
                                .withValues(alpha: 0.5),
                          ),
                          const Gap(16),
                          Text(
                            context.t.noTerminalsOpen,
                            style: theme.textTheme.large.copyWith(
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom Thumbnail Bar
                ThumbnailBar(
                  workspace: workspace,
                  settings: settings,
                  terminals: terminalState.terminals,
                  activeTerminalId: _activeTerminalId,
                  onTerminalSelected: (id) {
                    setState(() {
                      _activeTerminalId = id;
                    });
                    // Defer navigation until after rebuild
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        context.router.navigate(TerminalRoute(terminalId: id));
                      }
                    });
                  },
                  onTerminalClosed: (id) =>
                      _closeTerminal(context, workspace.id, id),
                  onAddTerminal: _addNewTerminal,
                  popoverController: _popoverController,
                  agentPopoverController: _agentPopoverController,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
// Removed entire _buildThumbnailBar and _buildThumbnailItem methods as they are extracted.
