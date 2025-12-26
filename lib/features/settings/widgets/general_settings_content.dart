import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/extensions/context_extension.dart';

import '../bloc/settings_bloc.dart';
import '../models/app_settings.dart';
import 'settings_section.dart';

/// General settings content widget for language selection.
class GeneralSettingsContent extends StatelessWidget {
  const GeneralSettingsContent({
    super.key,
    required this.settings,
  });

  final AppSettings settings;

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
            initialValue: settings.locale,
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
      ],
    );
  }
}
