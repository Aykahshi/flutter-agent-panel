import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/extensions/context_extension.dart';

import '../bloc/settings_bloc.dart';
import '../models/app_settings.dart';
import 'settings_section.dart';

/// General settings content widget for language selection and global env vars.
class GeneralSettingsContent extends StatefulWidget {
  const GeneralSettingsContent({
    super.key,
    required this.settings,
  });

  final AppSettings settings;

  @override
  State<GeneralSettingsContent> createState() => _GeneralSettingsContentState();
}

class _GeneralSettingsContentState extends State<GeneralSettingsContent> {
  late TextEditingController _envController;

  @override
  void initState() {
    super.initState();
    _envController = TextEditingController(
      text: widget.settings.globalEnvironmentVariables.entries
          .map((e) => '${e.key}=${e.value}')
          .join('\n'),
    );
  }

  @override
  void didUpdateWidget(covariant GeneralSettingsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.globalEnvironmentVariables !=
        widget.settings.globalEnvironmentVariables) {
      _envController.text = widget.settings.globalEnvironmentVariables.entries
          .map((e) => '${e.key}=${e.value}')
          .join('\n');
    }
  }

  @override
  void dispose() {
    _envController.dispose();
    super.dispose();
  }

  void _saveEnvVars() {
    final envLines = _envController.text.trim().split('\n');
    final env = <String, String>{};
    for (final line in envLines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split('=');
      if (parts.length >= 2) {
        env[parts[0].trim()] = parts.sublist(1).join('=').trim();
      }
    }
    context.read<SettingsBloc>().add(UpdateGlobalEnvVars(env));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.t;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSection(
          title: l10n.language,
          description: l10n.selectLanguage,
          child: ShadSelect<String>(
            initialValue: widget.settings.locale,
            placeholder: Text(l10n.selectLanguage),
            options: [
              ShadOption(value: 'en', child: Text(l10n.english)),
              ShadOption(value: 'zh', child: Text(l10n.chineseHans)),
              ShadOption(value: 'zh_Hant', child: Text(l10n.chineseHant)),
            ],
            selectedOptionBuilder: (context, value) {
              if (value == 'en') return Text(l10n.english);
              if (value == 'zh') return Text(l10n.chineseHans);
              if (value == 'zh_Hant') return Text(l10n.chineseHant);
              return Text(value);
            },
            onChanged: (value) {
              if (value != null) {
                context.read<SettingsBloc>().add(UpdateLocale(value));
              }
            },
          ),
        ),
        Gap(16.h),
        SettingsSection(
          title: l10n.globalEnvironmentVariables,
          description: l10n.globalEnvironmentVariablesDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShadInput(
                controller: _envController,
                maxLines: 5,
                placeholder: const Text('KEY=VALUE'),
                onChanged: (_) => _saveEnvVars(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
