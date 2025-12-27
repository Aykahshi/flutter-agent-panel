import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/services/app_version_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../settings/views/settings_dialog.dart';

/// Application shell that provides the main scaffold and router outlet.
@RoutePage()
class AppShellView extends StatefulWidget {
  const AppShellView({super.key});

  @override
  State<AppShellView> createState() => _AppShellViewState();
}

class _AppShellViewState extends State<AppShellView> {
  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    // Small delay to ensure UI is ready
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final hasUpdate = await AppVersionService.instance.hasUpdate();
    if (!mounted) return;

    if (hasUpdate) {
      ShadToaster.of(context).show(
        ShadToast(
          title: Text(context.t.updateAvailable),
          description: Text(context.t.updateDescription),
          action: ShadButton.outline(
            child: Text(context.t.update),
            onPressed: () {
              SettingsDialog.show(context, initialTab: 5);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: AutoRouter(),
    );
  }
}
