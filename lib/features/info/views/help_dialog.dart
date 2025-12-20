import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/extensions/context_extension.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showShadDialog(
      context: context,
      builder: (context) => const HelpDialog(),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = context.t;

    return ShadDialog(
      title: Text(l10n.help),
      child: SizedBox(
        width: 400.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Text(
              'Project Repository',
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
            ShadButton.link(
              padding: EdgeInsets.zero,
              onPressed: () =>
                  _launchUrl('https://github.com/Aykahshi/flutter-agent-panel'),
              child:
                  const Text('https://github.com/Aykahshi/flutter-agent-panel'),
            ),
            SizedBox(height: 16.h),
            Text(
              'Issue Tracker',
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
            ShadButton.link(
              padding: EdgeInsets.zero,
              onPressed: () => _launchUrl(
                  'https://github.com/Aykahshi/flutter-agent-panel/issues'),
              child: const Text(
                  'https://github.com/Aykahshi/flutter-agent-panel/issues'),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
