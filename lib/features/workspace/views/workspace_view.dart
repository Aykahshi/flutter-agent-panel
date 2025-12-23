import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xterm/xterm.dart' hide TerminalView;
import 'dart:convert';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:gap/gap.dart';

import '../widgets/icon_option.dart';
import '../widgets/main_terminal_content.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/utils/platform_utils.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/l10n/app_localizations.dart';

import '../../terminal/models/terminal_node.dart';
import '../../terminal/models/terminal_config.dart';
import '../../terminal/services/isolate_pty.dart';
import '../../terminal/widgets/activity_indicator.dart';
import '../../terminal/widgets/glowing_icon.dart';
import '../bloc/workspace_bloc.dart';
import '../../settings/bloc/settings_bloc.dart';
import '../models/workspace.dart';
import '../../settings/models/app_settings.dart';
import 'dart:io';

class WorkspaceView extends StatefulWidget {
  const WorkspaceView({super.key});

  @override
  State<WorkspaceView> createState() => _WorkspaceViewState();
}

class _WorkspaceViewState extends State<WorkspaceView> {
  final _titleController = TextEditingController();
  final _popoverController = ShadPopoverController();
  final _iconPopoverController = ShadPopoverController();
  final _agentPopoverController = ShadPopoverController();
  String? _activeTerminalId;
  final Map<String, TerminalNode> _terminalNodes = {};
  final Set<String> _pendingTerminalIds = {};
  final Set<String> _restartingIds = {}; // Track terminals currently restarting
  String?
      _newlyCreatedId; // Track newly added terminal to prevent selection reset race conditions

  @override
  void initState() {
    super.initState();
    // Initial sync
    final state = context.read<WorkspaceBloc>().state;
    _syncTerminals(state);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _popoverController.dispose();
    _iconPopoverController.dispose();
    _agentPopoverController.dispose();
    for (var node in _terminalNodes.values) {
      node.dispose();
    }
    _terminalNodes.clear();
    super.dispose();
  }

  Future<void> _syncTerminals(WorkspaceState state) async {
    final selectedWorkspace = state.selectedWorkspace;

    // 1. Retention Logic: Keep terminals that exist in ANY workspace
    final allTerminalIds =
        state.workspaces.expand((w) => w.terminals).map((t) => t.id).toSet();

    // Remove nodes that are no longer in ANY config (deleted by user)
    _terminalNodes.removeWhere((id, node) {
      if (!allTerminalIds.contains(id)) {
        node.dispose();
        debugPrint('Disposing terminal $id (removed from config)');
        return true;
      }
      return false;
    });

    if (selectedWorkspace == null) {
      _activeTerminalId = null;
      return;
    }

    // 2. Creation Logic: Only start PTYs for the CURRENT workspace (Lazy load)
    for (var config in selectedWorkspace.terminals) {
      if (!_terminalNodes.containsKey(config.id) &&
          !_pendingTerminalIds.contains(config.id)) {
        // Yield to UI to prevent freeze and allow loading state to show
        await Future.delayed(Duration.zero);
        _createTerminalNode(config, selectedWorkspace.id);
      } else {
        // Update titles and icons if changed for existing nodes
        final node = _terminalNodes[config.id];
        if (node != null) {
          if (node.title != config.title) {
            node.title = config.title;
          }
          if (node.icon != config.icon) {
            node.icon = config.icon;
          }
        }
      }

      // Note: We used to remove from restarting list here, but it caused races.
      // Now we wait for actual output in _createTerminalNode.
    }

    // Maintain active selection
    // Ensure the active terminal belongs to the SELECTED workspace
    final selectedTerminalIds =
        selectedWorkspace.terminals.map((t) => t.id).toSet();

    if (_activeTerminalId == null ||
        !selectedTerminalIds.contains(_activeTerminalId)) {
      // GUARD: If active ID matches the one we just created, keep it!
      if (_activeTerminalId != null && _activeTerminalId == _newlyCreatedId) {
        return;
      }

      if (selectedWorkspace.terminals.isNotEmpty) {
        _activeTerminalId = selectedWorkspace.terminals.first.id;
      } else {
        _activeTerminalId = null;
      }
    } else {
      // If the newly created ID is now in the state, we can clear our tracker
      if (_activeTerminalId == _newlyCreatedId) {
        _newlyCreatedId = null;
      }
    }
  }

  Future<void> _createTerminalNode(
      TerminalConfig config, String workspaceId) async {
    if (_pendingTerminalIds.contains(config.id)) return;

    _pendingTerminalIds.add(config.id);

    try {
      final terminal = Terminal(
        maxLines: 10000,
      );

      // Determine shell and cwd
      String shell;
      List<String> ptyArgs;

      if (config.agentId != null && config.agentId!.isNotEmpty) {
        // Agent terminal: wrap command in pwsh.exe
        shell = PlatformUtils.isWindows ? 'pwsh.exe' : '/bin/bash';
        if (PlatformUtils.isWindows) {
          ptyArgs = [
            '-NoLogo',
            '-NoExit',
            '-Command',
            config.shellCmd,
            ...config.args,
          ];
        } else {
          ptyArgs = ['-c', config.shellCmd, ...config.args];
        }
      } else {
        // Normal terminal
        shell = config.shellCmd.isNotEmpty
            ? config.shellCmd
            : (PlatformUtils.isWindows ? 'pwsh.exe' : '/bin/bash');
        ptyArgs = config.args;
      }

      final cwd = config.cwd.isNotEmpty ? config.cwd : Directory.current.path;

      final pty = await IsolatePty.start(
        shell,
        arguments: ptyArgs,
        workingDirectory: cwd,
        environment: {
          'TERM': 'xterm-256color',
          'COLORTERM': 'truecolor',
          ...Platform.environment,
        },
      );

      final node = TerminalNode(
        id: config.id,
        workspaceId: workspaceId,
        title: config.title,
        terminal: terminal,
        pty: pty,
        onStatusChanged: () {
          if (mounted) {
            setState(() {});
          }
        },
      );

      // Setup PTY -> Terminal (Output)
      // Use utf8.decoder transform to handle multi-byte characters (mojibake fix)
      bool outputTimerStarted = false;
      pty.output
          .cast<List<int>>()
          .transform(const Utf8Decoder(allowMalformed: true))
          .listen((data) {
        terminal.write(data);
        if (data.isNotEmpty) {
          if (!node.hasOutput && !outputTimerStarted) {
            outputTimerStarted = true;
            // Directly show the terminal when output is received
            if (mounted) {
              node.hasOutput = true;
              // Clear restarting state only when we have actual output
              if (_restartingIds.contains(config.id)) {
                _restartingIds.remove(config.id);
              }
              // Force rebuild to remove loading state
              setState(() {});
            }
          }
          node.markActivity();
        }
      });

      // Setup Terminal -> PTY (Input)
      terminal.onOutput = (data) {
        pty.write(const Utf8Encoder().convert(data));
      };

      if (mounted) {
        setState(() {
          _terminalNodes[config.id] = node;
        });
      }
    } catch (e) {
      debugPrint('Failed to start terminal: $e');
    } finally {
      if (mounted) {
        _pendingTerminalIds.remove(config.id);
      } else {
        _pendingTerminalIds.remove(config.id);
      }
    }
  }

  void _addNewTerminal(BuildContext context, String workspaceId,
      {String? shellCmd, String? agentId}) {
    final settings = context.read<SettingsBloc>().state.settings;
    final l10n = context.t;

    String effectiveShellCmd = shellCmd ?? settings.defaultShell.command;
    String terminalTitle = l10n.terminal;

    // Handle custom shell selection with ID format (custom:${id})
    if (shellCmd != null && shellCmd.startsWith('custom:')) {
      final shellId = shellCmd.substring(7);
      final customShell =
          settings.customShells.where((s) => s.id == shellId).firstOrNull;
      if (customShell != null) {
        effectiveShellCmd = customShell.path;
        terminalTitle = customShell.name;
      }
    }
    // Handle legacy 'custom' command or default custom shell selection
    else if (shellCmd == 'custom' ||
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
      // Set the title to the agent's display name or custom name
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
    context.read<WorkspaceBloc>().add(AddTerminalToWorkspace(
          workspaceId: workspaceId,
          config: config,
        ));
    // Auto select new terminal
    setState(() {
      _newlyCreatedId = config.id;
      _activeTerminalId = config.id;
    });
  }

  void _closeTerminal(
      BuildContext context, String workspaceId, String terminalId) {
    context.read<WorkspaceBloc>().add(RemoveTerminalFromWorkspace(
          workspaceId: workspaceId,
          terminalId: terminalId,
        ));
  }

  void _refreshTerminal(String terminalId) {
    if (mounted) {
      setState(() {
        _restartingIds.add(terminalId);
      });
    }

    // Delay slightly to show the restarting state
    Future.delayed(const Duration(milliseconds: 500), () {
      final node = _terminalNodes[terminalId];
      if (node != null) {
        // Disposing the node kills the PTY.
        node.dispose();
      }

      // Removing it from the map forces _syncTerminals to recreate it
      _terminalNodes.remove(terminalId);

      // Note: We do NOT remove from _restartingIds here.
      // It will be removed in _syncTerminals when the new node is created.

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return BlocConsumer<WorkspaceBloc, WorkspaceState>(
      listener: (context, state) {
        // Sync local terminal nodes when state changes
        _syncTerminals(state);
      },
      builder: (context, state) {
        final workspace = state.selectedWorkspace;
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

        // Initial sync check
        if (_terminalNodes.length < workspace.terminals.length) {
          // Check if we are missing any terminals for the current workspace
          final missing =
              workspace.terminals.any((t) => !_terminalNodes.containsKey(t.id));
          if (missing) {
            _syncTerminals(state);
          }
        }

        final activeNode = _activeTerminalId != null
            ? _terminalNodes[_activeTerminalId]
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
            // Top Bar (Active Terminal Title / Controls)
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: topBarColor,
                border: Border(
                  bottom: BorderSide(
                      color: topBarBorderColor.withValues(alpha: 0.3)),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  if (activeNode != null)
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (agentConfig != null) ...[
                            // Agent Icon
                            Container(
                              width: 32,
                              height: 32,
                              padding: const EdgeInsets.all(4),
                              child: agentConfig.preset.iconAssetPath != null
                                  ? Builder(builder: (context) {
                                      var iconPath =
                                          agentConfig.preset.iconAssetPath!;
                                      ColorFilter? colorFilter;

                                      if (agentConfig.preset ==
                                              AgentPreset.opencode &&
                                          Theme.of(context).brightness ==
                                              Brightness.dark) {
                                        iconPath =
                                            'assets/images/agent_logos/opencode-dark.svg';
                                      }

                                      if (agentConfig.preset ==
                                              AgentPreset.codex ||
                                          agentConfig.preset ==
                                              AgentPreset.githubCopilot) {
                                        colorFilter = ColorFilter.mode(
                                            theme.colorScheme.foreground,
                                            BlendMode.srcIn);
                                      }

                                      return SvgPicture.asset(
                                        iconPath,
                                        colorFilter: colorFilter,
                                      );
                                    })
                                  : Icon(LucideIcons.bot,
                                      color: agentColor ??
                                          theme.colorScheme.primary),
                            ),
                            const Gap(8),
                            // Fixed Title
                            Expanded(
                                child: Text(activeNode.title,
                                    style: theme.textTheme.large.copyWith(
                                        color: agentColor ??
                                            theme.colorScheme.foreground,
                                        fontWeight: FontWeight.bold))),
                          ] else ...[
                            // Icon Selector
                            ShadPopover(
                              controller: _iconPopoverController,
                              popover: (context) => Container(
                                width: 300,
                                height: 300,
                                padding: const EdgeInsets.all(8),
                                child: GridView.count(
                                  crossAxisCount: 5,
                                  children: [
                                    ..._iconMapping.keys.map(
                                      (iconName) => IconOption(
                                        iconName: iconName,
                                        node: activeNode,
                                        workspace: workspace,
                                        iconMapping: _iconMapping,
                                        onClose: () =>
                                            _iconPopoverController.toggle(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              child: ShadButton.ghost(
                                padding: EdgeInsets.zero,
                                width: 32,
                                height: 32,
                                onPressed: () =>
                                    _iconPopoverController.toggle(),
                                child: Icon(
                                  _getIconData(activeNode.id, workspace),
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const Gap(4),
                            Expanded(
                              child: Focus(
                                onFocusChange: (hasFocus) {
                                  if (!hasFocus) {
                                    _updateTitle(activeNode, workspace);
                                  }
                                },
                                child: ShadInput(
                                  key: ValueKey(activeNode.id),
                                  controller: _titleController
                                    ..text = activeNode.title,
                                  style: theme.textTheme.large,
                                  decoration: ShadDecoration(
                                    border: ShadBorder.none,
                                    focusedBorder: ShadBorder.none,
                                  ),
                                  onSubmitted: (value) =>
                                      _updateTitle(activeNode, workspace),
                                ),
                              ),
                            ),
                          ],
                          const Gap(8),
                          const Gap(8),
                          const Gap(8),
                          ActivityIndicator(
                            status: activeNode.status,
                            size: 8,
                          ),
                          const Gap(8),
                          const Gap(8),
                          ShadButton.ghost(
                            width: 32,
                            height: 32,
                            padding: EdgeInsets.zero,
                            onPressed: () => _refreshTerminal(activeNode.id),
                            child: Icon(
                              LucideIcons.refreshCw,
                              size: 16,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                          ShadButton.ghost(
                            width: 32,
                            height: 32,
                            padding: EdgeInsets.zero,
                            onPressed: () => _closeTerminal(
                                context, workspace.id, activeNode.id),
                            child: Icon(
                              LucideIcons.x,
                              size: 16,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Main Terminal Area (No outer padding here)
            Expanded(
              child: MainTerminalContent(
                activeNode: activeNode,
                isRestarting: _activeTerminalId != null &&
                    _restartingIds.contains(_activeTerminalId),
              ),
            ),

            // Bottom Thumbnail Bar
            Container(
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
                                newIndex: newIndex));
                      },
                      itemBuilder: (context, index) {
                        final config = workspace.terminals[index];
                        final node = _terminalNodes[config.id];
                        final isActive = config.id == _activeTerminalId;

                        return ReorderableDragStartListener(
                          key: ValueKey(config.id),
                          index: index,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeTerminalId = config.id;
                              });
                            },
                            child: AspectRatio(
                              aspectRatio: 1.2,
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.terminalBackground,
                                  border: Border.all(
                                    color: isActive
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.border,
                                    width: isActive ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Header
                                    Container(
                                      color: isActive
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.card,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      child: Row(
                                        children: [
                                          const Gap(4),
                                          Expanded(
                                            child: Text(
                                              config.title,
                                              style: theme
                                                  .textTheme.small
                                                  .copyWith(
                                                      color: isActive
                                                          ? theme.colorScheme
                                                              .primaryForeground
                                                          : theme.colorScheme
                                                              .foreground,
                                                      fontSize: 11,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => _closeTerminal(context,
                                                workspace.id, config.id),
                                            child: Icon(LucideIcons.x,
                                                size: 12,
                                                color: isActive
                                                    ? theme.colorScheme
                                                        .primaryForeground
                                                    : theme.colorScheme
                                                        .foreground),
                                          )
                                        ],
                                      ),
                                    ),
                                    // Preview Area (Blurred BG + Glowing Icon)
                                    Expanded(
                                      child: Container(
                                        color: theme.colorScheme.background
                                            .withValues(alpha: 0.5),
                                        child: Center(
                                          child: () {
                                            // Determine icon or SVG path
                                            IconData? iconData;
                                            String? svgPath;

                                            if (config.agentId != null) {
                                              final agents = context
                                                  .read<SettingsBloc>()
                                                  .state
                                                  .settings
                                                  .agents;
                                              final agent = agents
                                                  .where((a) =>
                                                      a.id == config.agentId)
                                                  .firstOrNull;
                                              if (agent != null) {
                                                svgPath = _getAgentIconPath(
                                                    agent.preset, theme);
                                              }
                                            }

                                            // Fallback to standard icon logic if no agent/svg
                                            if (svgPath == null) {
                                              iconData = _getIconData(
                                                  config.id, workspace);
                                            }

                                            return GlowingIcon(
                                              icon: iconData,
                                              svgPath: svgPath,
                                              status: node?.status ??
                                                  TerminalStatus.disconnected,
                                              size: 32,
                                              baseColor: isActive
                                                  ? theme.colorScheme.primary
                                                  : null,
                                            );
                                          }(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Appended Add Button with Shell Selection Popover
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    child: SizedBox(
                      width: 36,
                      height: 36, // Match thumbnail aspect ratio roughly
                      child: ShadPopover(
                        controller: _popoverController,
                        padding: EdgeInsets.zero,
                        child: ShadButton.outline(
                          padding: EdgeInsets.zero,
                          size: ShadButtonSize.sm,
                          onPressed: () => _popoverController.toggle(),
                          child: Icon(LucideIcons.terminal,
                              size: 16,
                              color: theme.colorScheme.mutedForeground),
                        ),
                        popover: (context) => SizedBox(
                          width: 200,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(context.t.selectShell,
                                    style: theme.textTheme.small
                                        .copyWith(fontWeight: FontWeight.bold)),
                              ),
                              Divider(
                                  height: 1, color: theme.colorScheme.border),
                              // Built-in shells (excluding custom type)
                              ...ShellType.values
                                  .where((s) => s != ShellType.custom)
                                  .map((shell) {
                                final shellDisplayName =
                                    _getShellTypeLocalizedName(
                                        shell, context.t);
                                return InkWell(
                                  onTap: () {
                                    _popoverController.hide();
                                    _addNewTerminal(context, workspace.id,
                                        shellCmd: shell.command);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(_getShellIcon(shell.icon),
                                            size: 16),
                                        const Gap(8),
                                        Text(shellDisplayName),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              // Custom shells from settings
                              if (context
                                  .read<SettingsBloc>()
                                  .state
                                  .settings
                                  .customShells
                                  .isNotEmpty) ...[
                                Divider(
                                    height: 1, color: theme.colorScheme.border),
                                ...context
                                    .read<SettingsBloc>()
                                    .state
                                    .settings
                                    .customShells
                                    .map((customShell) {
                                  return InkWell(
                                    onTap: () {
                                      _popoverController.hide();
                                      _addNewTerminal(context, workspace.id,
                                          shellCmd: 'custom:${customShell.id}');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(_getShellIcon(customShell.icon),
                                              size: 16),
                                          const Gap(8),
                                          Text(customShell.name),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Add Agent Button
                  // Add Agent Button
                  if (settings.agents.any((a) => a.enabled))
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ShadPopover(
                        controller: _agentPopoverController,
                        padding: EdgeInsets.zero,
                        child: ShadButton.outline(
                          padding: EdgeInsets.zero,
                          size: ShadButtonSize.sm,
                          width: 36,
                          height: 36,
                          onPressed: () => _agentPopoverController
                              .toggle(), // Explicit toggle

                          child: Icon(LucideIcons.bot,
                              size: 16,
                              color: theme.colorScheme.mutedForeground),
                        ),
                        popover: (context) {
                          final enabledAgents =
                              settings.agents.where((a) => a.enabled).toList();
                          return SizedBox(
                              width: 200,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(context.t.agents,
                                          style: theme.textTheme.small.copyWith(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Divider(
                                        height: 1,
                                        color: theme.colorScheme.border),
                                    ...enabledAgents.map((agent) => InkWell(
                                        onTap: () {
                                          _agentPopoverController.toggle();
                                          _addNewTerminal(context, workspace.id,
                                              shellCmd: agent.command,
                                              agentId: agent.id);
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            child: Row(children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: agent.preset
                                                            .iconAssetPath !=
                                                        null
                                                    ? Builder(
                                                        builder: (context) {
                                                        var iconPath = agent
                                                            .preset
                                                            .iconAssetPath!;
                                                        ColorFilter?
                                                            colorFilter;

                                                        // Adapt Opencode icon for dark mode
                                                        if (agent.preset ==
                                                                AgentPreset
                                                                    .opencode &&
                                                            Theme.of(context)
                                                                    .brightness ==
                                                                Brightness
                                                                    .dark) {
                                                          iconPath =
                                                              'assets/images/agent_logos/opencode-dark.svg';
                                                        }

                                                        // Adapt Codex and Github Copilot icon color
                                                        if (agent.preset ==
                                                                AgentPreset
                                                                    .codex ||
                                                            agent.preset ==
                                                                AgentPreset
                                                                    .githubCopilot) {
                                                          colorFilter =
                                                              ColorFilter.mode(
                                                                  theme
                                                                      .colorScheme
                                                                      .foreground,
                                                                  BlendMode
                                                                      .srcIn);
                                                        }

                                                        return SvgPicture.asset(
                                                          iconPath,
                                                          colorFilter:
                                                              colorFilter,
                                                        );
                                                      })
                                                    : Icon(LucideIcons.bot,
                                                        size: 16),
                                              ),
                                              const Gap(8),
                                              Text(agent.name),
                                            ]))))
                                  ]));
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateTitle(TerminalNode node, Workspace workspace) {
    final value = _titleController.text.trim();
    if (value.isNotEmpty && value != node.title) {
      final config = workspace.terminals.firstWhere((t) => t.id == node.id);
      context.read<WorkspaceBloc>().add(UpdateTerminalInWorkspace(
            workspaceId: workspace.id,
            config: config.copyWith(title: value),
          ));
    }
  }

  IconData _getIconData(String terminalId, Workspace workspace) {
    try {
      final config = workspace.terminals.firstWhere((t) => t.id == terminalId);
      final iconName = config.icon;
      if (iconName == null) return LucideIcons.terminal;

      // Support both current keys and potential legacy stringified IconData
      if (_iconMapping.containsKey(iconName)) {
        return _iconMapping[iconName]!;
      }

      // Fallback: If it's a legacy string like 'IconData(U+0EB3A)', we can't easily map back,
      // but we can try to find if any value in our map matches it if we had the code.
      // For now, return terminal icon if no match.
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
    // Aliases for legacy/alternative names
    'package': LucideIcons.package,
    'git-branch': LucideIcons.gitBranch,
    'flask-conical': LucideIcons.flaskConical,
    'layout-panel-left': LucideIcons.layoutPanelLeft,
  };

  IconData _getShellIcon(String iconName) {
    switch (iconName) {
      case 'terminal':
        return LucideIcons.terminal;
      case 'command':
        return LucideIcons.squareTerminal;
      case 'server':
        return LucideIcons.server;
      case 'gitBranch':
        return LucideIcons.gitBranch;
      case 'box':
        return LucideIcons.box;
      case 'settings':
        return LucideIcons.settings;
      default:
        return LucideIcons.terminal;
    }
  }

  String _getShellTypeLocalizedName(ShellType shell, AppLocalizations l10n) =>
      switch (shell) {
        ShellType.pwsh7 => l10n.pwsh7,
        ShellType.powershell => l10n.powershell,
        ShellType.cmd => l10n.cmd,
        ShellType.wsl => l10n.wsl,
        ShellType.gitBash => l10n.gitBash,
        ShellType.custom => l10n.custom,
      };

  Color? _getAgentColor(AgentPreset preset) => switch (preset) {
        AgentPreset.claude => const Color(0xFFD97757),
        AgentPreset.qwen => const Color(0xFF615CED),
        AgentPreset.codex => const Color(0xFF10A37F),
        AgentPreset.gemini => const Color(0xFF4E87F6),
        AgentPreset.opencode => Colors.blueGrey,
        _ => null,
      };

  String? _getAgentIconPath(AgentPreset preset, ShadThemeData theme) {
    switch (preset) {
      case AgentPreset.claude:
        return 'assets/images/agent_logos/claude.svg';
      case AgentPreset.gemini:
        return 'assets/images/agent_logos/gemini.svg';
      case AgentPreset.codex:
        return 'assets/images/agent_logos/chatgpt.svg';
      case AgentPreset.qwen:
        return 'assets/images/agent_logos/qwen.svg';
      case AgentPreset.opencode:
        return theme.brightness == Brightness.dark
            ? 'assets/images/agent_logos/opencode-dark.svg'
            : 'assets/images/agent_logos/opencode.svg';
      case AgentPreset.githubCopilot:
        return 'assets/images/agent_logos/github-copilot.svg';
      default:
        return null;
    }
  }
}
