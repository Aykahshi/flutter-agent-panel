import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/constants/assets.dart';
import '../../../../core/extensions/context_extension.dart';
import '../bloc/settings_bloc.dart';
import '../models/app_settings.dart';
import 'agent_dialog.dart';
import '../../../../shared/utils/settings_helpers.dart';
import 'settings_section.dart';

/// Agents settings content widget.
class AgentsContent extends StatefulWidget {
  const AgentsContent({
    super.key,
    required this.settings,
  });

  final AppSettings settings;

  @override
  State<AgentsContent> createState() => _AgentsContentState();
}

class _AgentsContentState extends State<AgentsContent> {
  @override
  void initState() {
    super.initState();
    _verifyAgentInstallations();
  }

  Future<void> _verifyAgentInstallations() async {
    for (final agent in widget.settings.agents) {
      if (agent.enabled) {
        final exists = await _checkCommandInstalled(agent.command);
        if (!exists && mounted) {
          context
              .read<SettingsBloc>()
              .add(UpdateAgentConfig(agent.copyWith(enabled: false)));
        }
      }
    }
  }

  Future<bool> _checkCommandInstalled(String command) async {
    try {
      final isWindows = Platform.isWindows;
      final result = await Process.run(
        isWindows ? 'where' : 'which',
        [command],
        runInShell: true,
      );
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _installAgent(
    String installCommand,
    void Function(String) onLog,
  ) async {
    try {
      final parts = installCommand.split(' ');
      if (parts.isEmpty) return false;

      final process = await Process.start(
        parts.first,
        parts.sublist(1),
        runInShell: true,
      );

      process.stdout.transform(utf8.decoder).listen(onLog);
      process.stderr.transform(utf8.decoder).listen(onLog);

      final exitCode = await process.exitCode;
      return exitCode == 0;
    } catch (e) {
      onLog('Error: $e');
      return false;
    }
  }

  Future<void> _toggleAgent(
    AgentConfig agent,
    bool value,
  ) async {
    final l10n = context.t;
    final theme = context
        .theme; // Use context.theme assuming it's available via extension or method

    if (!value) {
      context
          .read<SettingsBloc>()
          .add(UpdateAgentConfig(agent.copyWith(enabled: false)));
      return;
    }

    context
        .read<SettingsBloc>()
        .add(UpdateAgentConfig(agent.copyWith(enabled: true)));

    final exists = await _checkCommandInstalled(agent.command);
    if (!mounted) return;

    if (exists) return;

    context
        .read<SettingsBloc>()
        .add(UpdateAgentConfig(agent.copyWith(enabled: false)));

    final installCmd = agent.preset.defaultInstallCommand;
    if (installCmd.isEmpty) {
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: Text(l10n.agentNotInstalled),
          description: Text(l10n.agentInstallFailed),
        ),
      );
      return;
    }

    final shouldInstall = await showShadDialog<bool>(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: Text(l10n.installAgentTitle),
        description: Text(l10n.installAgentMessage(agent.name, installCmd)),
        actions: [
          ShadButton.ghost(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ShadButton(
            child: const Text('Install'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (shouldInstall == true) {
      if (!mounted) return;

      final logNotifier = ValueNotifier<String>('');

      ShadToaster.of(context).show(
        ShadToast(
          title: Text(l10n.installingAgent),
          description: ValueListenableBuilder<String>(
            valueListenable: logNotifier,
            builder: (context, log, child) {
              if (log.isEmpty) return const LinearProgressIndicator();

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LinearProgressIndicator(),
                  const Gap(4),
                  Text(
                    log.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.small.copyWith(
                      fontFamily: 'Consolas',
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );

      final success = await _installAgent(installCmd, (line) {
        if (line.trim().isNotEmpty) {
          logNotifier.value = line;
        }
      });

      if (!mounted) return;
      if (success) {
        ShadToaster.of(context).show(
          ShadToast(
            title: Text(l10n.agentInstalled),
            backgroundColor: Colors.green.withValues(alpha: 0.2),
          ),
        );
        context
            .read<SettingsBloc>()
            .add(UpdateAgentConfig(agent.copyWith(enabled: true)));
      } else {
        ShadToaster.of(context).show(
          ShadToast.destructive(title: Text(l10n.agentInstallFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.t;
    final theme = context.theme;
    final settings = widget.settings;

    final presetAgents =
        settings.agents.where((a) => a.preset != AgentPreset.custom).toList();
    final customAgents =
        settings.agents.where((a) => a.preset == AgentPreset.custom).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSection(
          title: l10n.agents,
          description: l10n.agentsDescription,
          child: Column(
            children: [
              ...presetAgents.map((agent) => _buildPresetAgentItem(agent)),
            ],
          ),
        ),
        Divider(height: 32.h, color: theme.colorScheme.border),
        SettingsSection(
          title: l10n.customAgent,
          description: l10n.agentsDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShadButton.outline(
                onPressed: () => showAddEditAgentDialog(
                  context,
                  l10n,
                  theme,
                  isCustom: true,
                ),
                leading: Icon(LucideIcons.plus, size: 16.sp),
                child: Text(l10n.addCustomAgent),
              ),
              Gap(16.h),
              if (customAgents.isEmpty)
                Text(l10n.noCustomAgents, style: theme.textTheme.muted)
              else
                ...customAgents.map((agent) => _buildCustomAgentItem(agent)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetAgentItem(AgentConfig agent) {
    final theme = context.theme;
    final color = getAgentColor(agent.preset);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: BorderRadius.circular(8.r),
        color: agent.enabled
            ? theme.colorScheme.secondary.withValues(alpha: 0.1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32.sp,
            height: 32.sp,
            padding: EdgeInsets.all(4.sp),
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Builder(
              builder: (context) {
                var iconPath = agent.preset.iconAssetPath!;
                ColorFilter? colorFilter;

                if (agent.preset == AgentPreset.opencode &&
                    Theme.of(context).brightness == Brightness.dark) {
                  iconPath = Assets.opencodeDarkLogo;
                }

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
                  placeholderBuilder: (context) => const Icon(LucideIcons.bot),
                );
              },
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.name,
                  style: theme.textTheme.p.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  agent.command,
                  style: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          ShadButton.ghost(
            padding: EdgeInsets.zero,
            width: 32.w,
            height: 32.h,
            onPressed: () => showAddEditAgentDialog(
              context,
              context.t,
              theme,
              existingAgent: agent,
            ),
            child: Icon(LucideIcons.settings, size: 16.sp),
          ),
          Gap(8.w),
          ShadSwitch(
            value: agent.enabled,
            onChanged: (value) => _toggleAgent(agent, value),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAgentItem(AgentConfig agent) {
    final theme = context.theme;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.bot, size: 24.sp),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(agent.name, style: theme.textTheme.p),
                Text(
                  agent.command,
                  style: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          ShadButton.ghost(
            padding: EdgeInsets.zero,
            width: 32.w,
            height: 32.h,
            onPressed: () => showAddEditAgentDialog(
              context,
              context.t,
              theme,
              existingAgent: agent,
              isCustom: true,
            ),
            child: Icon(LucideIcons.pencil, size: 16.sp),
          ),
          ShadButton.ghost(
            padding: EdgeInsets.zero,
            width: 32.w,
            height: 32.h,
            onPressed: () =>
                context.read<SettingsBloc>().add(RemoveAgentConfig(agent.id)),
            child: Icon(
              LucideIcons.trash2,
              size: 16.sp,
              color: theme.colorScheme.destructive,
            ),
          ),
        ],
      ),
    );
  }
}
