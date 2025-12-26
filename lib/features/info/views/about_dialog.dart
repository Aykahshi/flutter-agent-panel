import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/assets.dart';
import '../../../../core/extensions/context_extension.dart';

class AppAboutDialog extends StatelessWidget {
  const AppAboutDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showShadDialog(
      context: context,
      builder: (context) => const AppAboutDialog(),
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
    final theme = context.theme;
    final l10n = context.t;

    return ShadDialog(
      title: Text(l10n.about),
      child: SizedBox(
        width: 400.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(16.h),
            CircleAvatar(
              radius: 40.r,
              backgroundImage: const AssetImage(Assets.avatar),
            ),
            Gap(16.h),
            Text(
              'Author: Aykahshi',
              style:
                  theme.textTheme.large.copyWith(fontWeight: FontWeight.bold),
            ),
            Gap(8.h),
            ShadButton.link(
              onPressed: () => _launchUrl('https://github.com/Aykahshi'),
              child: const Text('GitHub @Aykahshi'),
            ),
            const Divider(),
            Gap(16.h),
            Text(
              'Inspired by',
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
            Gap(8.h),
            ShadButton.link(
              onPressed: () => _launchUrl('https://github.com/tony1223'),
              child: const Text('tony1223'),
            ),
            ShadButton.link(
              onPressed: () => _launchUrl(
                'https://github.com/tony1223/better-agent-terminal',
              ),
              child: const Text('Better Agent Terminal'),
            ),
            Gap(16.h),
          ],
        ),
      ),
    );
  }
}
