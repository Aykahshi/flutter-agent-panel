import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';

/// Displays a list of tags as colored chips with tooltip for overflow.
class WorkspaceTagChips extends StatelessWidget {
  const WorkspaceTagChips({
    super.key,
    required this.tags,
    this.maxTags = 3,
    this.isCompact = false,
  });

  final List<String> tags;
  final int maxTags;
  final bool isCompact;

  static const _tagColors = [
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFFE91E63), // Pink
    Color(0xFF00BCD4), // Cyan
  ];

  Color _getTagColor(int index) {
    return _tagColors[index % _tagColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    if (tags.isEmpty) return const SizedBox.shrink();

    final displayTags = tags.take(maxTags).toList();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...displayTags.asMap().entries.map((entry) {
          final color = _getTagColor(entry.key);
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 4 : 6,
              vertical: isCompact ? 1 : 2,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              entry.value,
              style: theme.textTheme.small.copyWith(
                color: color,
                fontSize: isCompact ? 9 : 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }),
      ],
    );
  }
}
