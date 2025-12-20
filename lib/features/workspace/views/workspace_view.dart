import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:xterm/xterm.dart' hide TerminalView;
import 'package:flutter_pty/flutter_pty.dart';
import 'dart:convert';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/utils/platform_utils.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../terminal/views/terminal_view.dart';
import '../../terminal/models/terminal_node.dart';
import '../../terminal/models/terminal_config.dart';
import '../../terminal/widgets/activity_indicator.dart';
import '../bloc/workspace_bloc.dart';
import '../../settings/bloc/settings_bloc.dart';
import '../models/workspace.dart';
import '../../settings/models/app_settings.dart';
import 'dart:io';
import 'dart:async';

class WorkspaceView extends StatefulWidget {
  const WorkspaceView({super.key});

  @override
  State<WorkspaceView> createState() => _WorkspaceViewState();
}

class _WorkspaceViewState extends State<WorkspaceView> {
  final _titleController = TextEditingController();
  final _popoverController = ShadPopoverController();
  final _iconPopoverController = ShadPopoverController();
  String? _activeTerminalId;
  final Map<String, TerminalNode> _terminalNodes = {};
  final Set<String> _pendingTerminalIds = {};

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
    _iconPopoverController.dispose();
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
        _pendingTerminalIds.add(config.id);

        // Yield to UI to prevent freeze and allow loading state to show
        await Future.delayed(Duration.zero);

        try {
          final terminal = Terminal(
            maxLines: 10000,
          );

          // Determine shell and cwd
          final shell = config.shellCmd.isNotEmpty
              ? config.shellCmd
              : (PlatformUtils.isWindows ? 'pwsh.exe' : '/bin/bash');

          final cwd =
              config.cwd.isNotEmpty ? config.cwd : selectedWorkspace.path;

          final pty = Pty.start(
            shell,
            columns: 80,
            rows: 24,
            workingDirectory: cwd,
            environment: Platform.environment, // Inherit system environment
          );

          final node = TerminalNode(
            id: config.id,
            workspaceId: selectedWorkspace.id,
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
          pty.output
              .cast<List<int>>()
              .transform(const Utf8Decoder(allowMalformed: true))
              .listen((data) {
            terminal.write(data);
            node.markActivity();
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
          _pendingTerminalIds.remove(config.id);
        }
      }

      // Update titles and icons if changed
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

    // Maintain active selection
    // Ensure the active terminal belongs to the SELECTED workspace
    final selectedTerminalIds =
        selectedWorkspace.terminals.map((t) => t.id).toSet();

    if (_activeTerminalId == null ||
        !selectedTerminalIds.contains(_activeTerminalId)) {
      if (selectedWorkspace.terminals.isNotEmpty) {
        _activeTerminalId = selectedWorkspace.terminals.first.id;
      } else {
        _activeTerminalId = null;
      }
    }
  }

  void _addNewTerminal(BuildContext context, String workspaceId,
      {String? shellCmd}) {
    final settings = context.read<SettingsBloc>().state.settings;
    final l10n = context.t;

    String effectiveShellCmd = shellCmd ?? 'pwsh';

    if (effectiveShellCmd == 'custom') {
      effectiveShellCmd = settings.customShellPath ?? 'pwsh';
    }

    final config = TerminalConfig.create(
      title: l10n.terminal,
      cwd: context.read<WorkspaceBloc>().state.selectedWorkspace?.path ?? '',
      shellCmd: effectiveShellCmd,
    );
    context.read<WorkspaceBloc>().add(AddTerminalToWorkspace(
          workspaceId: workspaceId,
          config: config,
        ));
    // Auto select new terminal
    setState(() {
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

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return BlocConsumer<WorkspaceBloc, WorkspaceState>(
      listener: (context, state) {
        // Sync local terminal nodes when state changes
        _syncTerminals(state);
      },
      builder: (context, state) {
        final workspace = state.selectedWorkspace;

        if (workspace == null) {
          final l10n = context.t;
          return Center(
            child: Text(
              l10n.selectWorkspacePrompt,
              style: theme.textTheme.muted.copyWith(fontSize: 16.sp),
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

        return Column(
          children: [
            // Top Bar (Active Terminal Title / Controls)
            Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.card,
                border: Border(
                  bottom: BorderSide(color: theme.colorScheme.border),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                children: [
                  if (activeNode != null)
                    Expanded(
                      child: Row(
                        children: [
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
                                  _buildIconOption(context, 'terminal',
                                      activeNode, workspace),
                                  _buildIconOption(context, 'command',
                                      activeNode, workspace),
                                  _buildIconOption(
                                      context, 'bug', activeNode, workspace),
                                  _buildIconOption(
                                      context, 'server', activeNode, workspace),
                                  _buildIconOption(context, 'database',
                                      activeNode, workspace),
                                  _buildIconOption(context, 'activity',
                                      activeNode, workspace),
                                  _buildIconOption(
                                      context, 'shield', activeNode, workspace),
                                  _buildIconOption(
                                      context, 'code', activeNode, workspace),
                                  _buildIconOption(context, 'monitor',
                                      activeNode, workspace),
                                  _buildIconOption(
                                      context, 'cpu', activeNode, workspace),
                                  _buildIconOption(
                                      context, 'flask', activeNode, workspace),
                                  _buildIconOption(
                                      context, 'globe', activeNode, workspace),
                                  _buildIconOption(
                                      context, 'box', activeNode, workspace),
                                  _buildIconOption(
                                      context, 'cloud', activeNode, workspace),
                                  _buildIconOption(
                                      context, 'layout', activeNode, workspace),
                                  _buildIconOption(context, 'gitBranch',
                                      activeNode, workspace),
                                  _buildIconOption(
                                      context, 'docker', activeNode, workspace),
                                  _buildIconOption(
                                      context, 'blocks', activeNode, workspace),
                                  _buildIconOption(
                                      context, 'search', activeNode, workspace),
                                  _buildIconOption(context, 'settings',
                                      activeNode, workspace),
                                  _buildIconOption(
                                      context, 'zap', activeNode, workspace),
                                ],
                              ),
                            ),
                            child: ShadButton.ghost(
                              padding: EdgeInsets.zero,
                              width: 32.w,
                              height: 32.h,
                              onPressed: () => _iconPopoverController.toggle(),
                              child: Icon(
                                _getIconData(activeNode.id, workspace),
                                size: 18.sp,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
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
                                style: theme.textTheme.small,
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
                      ),
                    ),
                ],
              ),
            ),

            // Main Terminal Area (No outer padding here)
            Expanded(
              child: activeNode != null
                  ? TerminalView(
                      key: ValueKey(activeNode.id),
                      terminalNode: activeNode,
                    )
                  : Center(
                      child: Text(
                        context.t.noTerminalsOpen,
                        style: theme.textTheme.muted,
                      ),
                    ),
            ),

            // Bottom Thumbnail Bar
            Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.card,
                border: Border(
                  top: BorderSide(color: theme.colorScheme.border),
                ),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.all(8.w),
                children: [
                  SizedBox(
                    height: 104.h,
                    child: ReorderableListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
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
                                margin: EdgeInsets.only(right: 8.w),
                                decoration: BoxDecoration(
                                  color: AppColors.terminalBackground,
                                  border: Border.all(
                                    color: isActive
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.border,
                                    width: isActive ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4.r),
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.w, vertical: 2.h),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getIconData(config.id, workspace),
                                            size: 10.sp,
                                            color: isActive
                                                ? theme.colorScheme
                                                    .primaryForeground
                                                : theme.colorScheme.primary,
                                          ),
                                          SizedBox(width: 4.w),
                                          if (node != null) ...[
                                            ActivityIndicator(
                                              status: node.status,
                                              size: 6.sp,
                                            ),
                                            SizedBox(width: 4.w),
                                          ],
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
                                                      fontSize: 10.sp,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => _closeTerminal(context,
                                                workspace.id, config.id),
                                            child: Icon(LucideIcons.x,
                                                size: 12.sp,
                                                color: isActive
                                                    ? theme.colorScheme
                                                        .primaryForeground
                                                    : theme.colorScheme
                                                        .foreground),
                                          )
                                        ],
                                      ),
                                    ),
                                    // Preview
                                    Expanded(
                                      child: node != null
                                          ? IgnorePointer(
                                              child: Transform.scale(
                                                scale: 0.2, // Tiny preview
                                                alignment: Alignment.topLeft,
                                                child: SizedBox(
                                                  width: 500.w,
                                                  height: 500.h,
                                                  child: TerminalView(
                                                    terminalNode: node,
                                                    interactive: false,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Center(
                                              child: SizedBox.square(
                                                dimension: 16.sp,
                                                child:
                                                    const CircularProgressIndicator(
                                                        strokeWidth: 2),
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
                    padding: EdgeInsets.symmetric(vertical: 0.h),
                    child: SizedBox(
                      width: 36.w,
                      height: 36.w, // Match thumbnail aspect ratio roughly
                      child: ShadPopover(
                        controller: _popoverController,
                        padding: EdgeInsets.zero,
                        child: ShadButton.outline(
                          padding: EdgeInsets.zero,
                          size: ShadButtonSize.sm,
                          onPressed: () => _popoverController.show(),
                          child: Icon(LucideIcons.plus,
                              size: 16.sp,
                              color: theme.colorScheme.mutedForeground),
                        ),
                        popover: (context) => SizedBox(
                          width: 200.w,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Text(context.t.selectShell,
                                    style: theme.textTheme.small
                                        .copyWith(fontWeight: FontWeight.bold)),
                              ),
                              Divider(
                                  height: 1, color: theme.colorScheme.border),
                              ...ShellType.values.map((shell) {
                                final shellDisplayName =
                                    _getShellTypeLocalizedName(
                                        shell, context.t);
                                return InkWell(
                                  onTap: () {
                                    _popoverController.hide();
                                    _addNewTerminal(context, workspace.id,
                                        shellCmd: shell.command.isEmpty
                                            ? 'custom'
                                            : shell.command);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.w, vertical: 8.h),
                                    child: Row(
                                      children: [
                                        Icon(_getShellIcon(shell.icon),
                                            size: 16.sp),
                                        SizedBox(width: 8.w),
                                        Text(shellDisplayName),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildIconOption(BuildContext context, String iconName,
      TerminalNode node, Workspace workspace) {
    final iconData = _iconMapping[iconName] ?? LucideIcons.terminal;

    return ShadButton.ghost(
      padding: EdgeInsets.zero,
      width: 40.w,
      height: 40.h,
      onPressed: () {
        final config = workspace.terminals.firstWhere((t) => t.id == node.id);
        context.read<WorkspaceBloc>().add(UpdateTerminalInWorkspace(
              workspaceId: workspace.id,
              config: config.copyWith(icon: iconName),
            ));
        _iconPopoverController.hide();
      },
      child: Icon(iconData, size: 20.sp),
    );
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

  String _getShellTypeLocalizedName(ShellType shell, AppLocalizations l10n) {
    switch (shell) {
      case ShellType.pwsh7:
        return l10n.pwsh7;
      case ShellType.powershell:
        return l10n.powershell;
      case ShellType.cmd:
        return l10n.cmd;
      case ShellType.wsl:
        return l10n.wsl;
      case ShellType.gitBash:
        return l10n.gitBash;
      case ShellType.custom:
        return l10n.custom;
    }
  }
}
