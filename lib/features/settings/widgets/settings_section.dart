import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../core/extensions/context_extension.dart';

/// A reusable section widget for settings pages.
class SettingsSection extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;

  const SettingsSection({
    super.key,
    required this.title,
    this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.large),
        if (description != null)
          Text(
            description!,
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        Gap(16.h),
        child,
      ],
    );
  }
}
