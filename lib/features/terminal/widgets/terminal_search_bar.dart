import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:xterm/ui.dart';
import '../../../core/extensions/context_extension.dart';

/// A search bar widget for terminal content search.
///
/// Displays a search input field with navigation buttons and search options,
/// positioned at the top-right corner of the terminal.
class TerminalSearchBar extends StatefulWidget {
  const TerminalSearchBar({
    super.key,
    required this.searchController,
    required this.onClose,
  });

  /// The search controller managing search state.
  final TerminalSearchController searchController;

  /// Callback when the search bar is closed.
  final VoidCallback onClose;

  @override
  State<TerminalSearchBar> createState() => _TerminalSearchBarState();
}

class _TerminalSearchBarState extends State<TerminalSearchBar> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.searchController.pattern,
    );
    _focusNode = FocusNode();

    // Listen to search controller changes
    widget.searchController.addListener(_onSearchControllerChanged);

    // Request focus when opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchControllerChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onTextChanged(String value) {
    widget.searchController.setPattern(value);
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        widget.onClose();
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (HardwareKeyboard.instance.isShiftPressed) {
          widget.searchController.previousMatch();
        } else {
          widget.searchController.nextMatch();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.f3) {
        if (HardwareKeyboard.instance.isShiftPressed) {
          widget.searchController.previousMatch();
        } else {
          widget.searchController.nextMatch();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final searchController = widget.searchController;
    final matchCount = searchController.matchCount;
    final currentIndex = searchController.currentMatchIndex;
    final options = searchController.options;

    // Match counter text
    final matchText = matchCount > 0
        ? '${currentIndex + 1}/$matchCount'
        : searchController.pattern.isNotEmpty
            ? '0/0'
            : '';

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: theme.colorScheme.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search input field
            SizedBox(
              width: 150,
              child: ShadInput(
                controller: _textController,
                focusNode: _focusNode,
                placeholder: Text(
                  context.t.terminalSearchPlaceholder,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                decoration: const ShadDecoration(
                  border: ShadBorder.none,
                  focusedBorder: ShadBorder.none,
                  errorBorder: ShadBorder.none,
                  secondaryBorder: ShadBorder.none,
                  secondaryFocusedBorder: ShadBorder.none,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                style: const TextStyle(fontSize: 12),
                onChanged: _onTextChanged,
              ),
            ),

            // Match counter
            if (matchText.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  matchText,
                  style: TextStyle(
                    fontSize: 11,
                    color: matchCount > 0
                        ? theme.colorScheme.foreground
                        : theme.colorScheme.destructive,
                  ),
                ),
              ),
            ],

            // Navigation buttons
            _buildIconButton(
              icon: LucideIcons.chevronUp,
              tooltip: context.t.terminalSearchPrevious,
              onPressed: matchCount > 0
                  ? () => searchController.previousMatch()
                  : null,
            ),
            _buildIconButton(
              icon: LucideIcons.chevronDown,
              tooltip: context.t.terminalSearchNext,
              onPressed:
                  matchCount > 0 ? () => searchController.nextMatch() : null,
            ),

            // Separator
            Container(
              width: 1,
              height: 16,
              color: theme.colorScheme.border,
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),

            // Case sensitivity toggle
            _buildToggleButton(
              label: 'Aa',
              tooltip: context.t.terminalSearchCaseSensitive,
              isActive: options.caseSensitive,
              onPressed: () => searchController.toggleCaseSensitive(),
            ),

            // Regex toggle
            _buildToggleButton(
              label: '.*',
              tooltip: context.t.terminalSearchRegex,
              isActive: options.useRegex,
              onPressed: () => searchController.toggleRegex(),
            ),

            // Separator
            Container(
              width: 1,
              height: 16,
              color: theme.colorScheme.border,
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),

            // Close button
            _buildIconButton(
              icon: LucideIcons.x,
              tooltip: context.t.close,
              onPressed: widget.onClose,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    VoidCallback? onPressed,
  }) {
    final theme = context.theme;
    final isEnabled = onPressed != null;

    return ShadTooltip(
      anchor: const ShadAnchorAuto(
        offset: Offset(0, 60),
        targetAnchor: Alignment.topCenter,
        followerAnchor: Alignment.topCenter,
      ),
      builder: (context) => Text(tooltip),
      child: ShadGestureDetector(
        child: SizedBox(
          width: 24,
          height: 24,
          child: IconButton(
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            iconSize: 14,
            icon: Icon(
              icon,
              color: isEnabled
                  ? theme.colorScheme.foreground
                  : theme.colorScheme.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required String tooltip,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    final theme = context.theme;

    return ShadTooltip(
      anchor: const ShadAnchorAuto(
        offset: Offset(0, 60),
        targetAnchor: Alignment.topCenter,
        followerAnchor: Alignment.topCenter,
      ),
      builder: (context) => Text(tooltip),
      child: ShadGestureDetector(
        onTap: onPressed,
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: isActive
                ? Border.all(color: theme.colorScheme.primary, width: 1)
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.foreground,
            ),
          ),
        ),
      ),
    );
  }
}
