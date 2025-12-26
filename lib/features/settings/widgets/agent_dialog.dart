import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../bloc/settings_bloc.dart';
import '../models/app_settings.dart';

/// Shows add/edit agent dialog.
void showAddEditAgentDialog(
  BuildContext context,
  AppLocalizations l10n,
  ShadThemeData theme, {
  AgentConfig? existingAgent,
  bool isCustom = false,
}) {
  final nameController = TextEditingController(text: existingAgent?.name ?? '');
  final commandController =
      TextEditingController(text: existingAgent?.command ?? '');
  final argsController =
      TextEditingController(text: existingAgent?.args.join(' ') ?? '');
  final envController = TextEditingController(
    text: existingAgent?.env.entries
            .map((e) => '${e.key}=${e.value}')
            .join('\n') ??
        '',
  );

  showShadDialog(
    context: context,
    builder: (ctx) => ShadDialog(
      title: Text(isCustom ? l10n.addCustomAgent : l10n.editCustomAgent),
      child: SizedBox(
        width: 400.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCustom) ...[
              Text(l10n.agentName),
              ShadInput(controller: nameController),
              Gap(8.h),
              Text(l10n.agentCommand),
              ShadInput(controller: commandController),
              Gap(8.h),
            ],
            Text(l10n.agentArgs),
            ShadInput(controller: argsController),
            Gap(8.h),
            Text(l10n.agentEnv),
            ShadInput(
              controller: envController,
              maxLines: 3,
              placeholder: const Text('KEY=VALUE'),
            ),
            Gap(16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ShadButton.ghost(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n.cancel),
                ),
                ShadButton(
                  onPressed: () {
                    final args = argsController.text
                        .trim()
                        .split(' ')
                        .where((s) => s.isNotEmpty)
                        .toList();
                    final envLines = envController.text.trim().split('\n');
                    final env = <String, String>{};
                    for (final line in envLines) {
                      final parts = line.split('=');
                      if (parts.length >= 2) {
                        env[parts[0].trim()] =
                            parts.sublist(1).join('=').trim();
                      }
                    }

                    if (isCustom) {
                      final newAgent = AgentConfig(
                        id: existingAgent?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        preset: AgentPreset.custom,
                        name: nameController.text,
                        command: commandController.text,
                        args: args,
                        env: env,
                        enabled: true,
                      );
                      if (existingAgent != null) {
                        context
                            .read<SettingsBloc>()
                            .add(UpdateAgentConfig(newAgent));
                      } else {
                        context
                            .read<SettingsBloc>()
                            .add(AddAgentConfig(newAgent));
                      }
                    } else {
                      final updated = existingAgent!.copyWith(
                        args: args,
                        env: env,
                      );
                      context
                          .read<SettingsBloc>()
                          .add(UpdateAgentConfig(updated));
                    }
                    Navigator.of(ctx).pop();
                  },
                  child: Text(l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
