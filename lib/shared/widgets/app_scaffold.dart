import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/extensions/context_extension.dart';
import '../../features/settings/views/settings_dialog.dart';
import '../../features/info/views/about_dialog.dart';
import '../../features/info/views/help_dialog.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? titleBar;

  const AppScaffold({super.key, required this.body, this.titleBar});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          // Custom Title Bar with Window Controls
          Container(
            height: 32,
            color: theme.colorScheme.card,
            child: Row(
              children: [
                Expanded(
                  child: DragToMoveArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: titleBar ??
                            Text(
                              'Flutter Agent Panel',
                              style: theme.textTheme.small.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
                // Window Controls
                _WindowButtons(theme: theme),
              ],
            ),
          ),

          // Menu Bar
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.border),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShadButton.link(
                    onPressed: () => SettingsDialog.show(context),
                    child: Text(context.t.settings),
                  ),
                  ShadButton.link(
                    onPressed: () => HelpDialog.show(context),
                    child: Text(context.t.help),
                  ),
                  ShadButton.link(
                    onPressed: () => AppAboutDialog.show(context),
                    child: Text(context.t.about),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _WindowButtons extends StatelessWidget {
  final ShadThemeData theme;

  const _WindowButtons({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WindowButton(
          icon: LucideIcons.minus,
          onPressed: () => windowManager.minimize(),
          theme: theme,
        ),
        _WindowButton(
          icon: LucideIcons.square,
          onPressed: () async {
            if (await windowManager.isMaximized()) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
          },
          theme: theme,
        ),
        _WindowButton(
          icon: LucideIcons.x,
          onPressed: () => windowManager.close(),
          hoverColor: Colors.red,
          theme: theme,
        ),
      ],
    );
  }
}

class _WindowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? hoverColor;
  final ShadThemeData theme;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    required this.theme,
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 32,
      child: ShadButton.ghost(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        width: 46,
        height: 32,
        decoration: ShadDecoration(
          focusedBorder: ShadBorder.none,
          border: ShadBorder.none,
        ),
        child: Icon(
          icon,
          size: 14,
          color: theme.colorScheme.foreground,
        ),
      ),
    );
  }
}
