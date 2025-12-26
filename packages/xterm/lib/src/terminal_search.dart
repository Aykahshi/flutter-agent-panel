import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:xterm/src/core/buffer/buffer.dart';
import 'package:xterm/src/core/buffer/cell_offset.dart';
import 'package:xterm/src/core/buffer/line.dart';
import 'package:xterm/src/terminal.dart';
import 'package:xterm/src/ui/controller.dart';

/// Represents a single search match in the terminal buffer.
class TerminalSearchMatch {
  /// The starting position of the match.
  final CellOffset start;

  /// The ending position of the match (exclusive).
  final CellOffset end;

  /// The matched text.
  final String text;

  const TerminalSearchMatch({
    required this.start,
    required this.end,
    required this.text,
  });

  @override
  String toString() => 'TerminalSearchMatch($start -> $end: "$text")';
}

/// Options for terminal search behavior.
class TerminalSearchOptions {
  /// Whether the search is case-sensitive.
  final bool caseSensitive;

  /// Whether to use regular expressions for matching.
  final bool useRegex;

  const TerminalSearchOptions({
    this.caseSensitive = false,
    this.useRegex = false,
  });

  TerminalSearchOptions copyWith({
    bool? caseSensitive,
    bool? useRegex,
  }) {
    return TerminalSearchOptions(
      caseSensitive: caseSensitive ?? this.caseSensitive,
      useRegex: useRegex ?? this.useRegex,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TerminalSearchOptions &&
        other.caseSensitive == caseSensitive &&
        other.useRegex == useRegex;
  }

  @override
  int get hashCode => caseSensitive.hashCode ^ useRegex.hashCode;
}

/// Controller for managing terminal search functionality.
///
/// This controller handles searching through terminal buffer content,
/// managing search matches, and coordinating with [TerminalController]
/// for highlighting matches.
class TerminalSearchController extends ChangeNotifier {
  /// Creates a new [TerminalSearchController].
  TerminalSearchController({
    required this.terminal,
    required this.terminalController,
  });

  /// The terminal to search in.
  final Terminal terminal;

  /// The controller for managing highlights.
  final TerminalController terminalController;

  /// The current search pattern.
  String _pattern = '';
  String get pattern => _pattern;

  /// The current search options.
  TerminalSearchOptions _options = const TerminalSearchOptions();
  TerminalSearchOptions get options => _options;

  /// The list of all matches found.
  List<TerminalSearchMatch> _matches = [];
  List<TerminalSearchMatch> get matches => List.unmodifiable(_matches);

  /// The index of the currently selected match.
  int _currentMatchIndex = 0;
  int get currentMatchIndex => _currentMatchIndex;

  /// The currently selected match, or null if no matches.
  TerminalSearchMatch? get currentMatch {
    if (_matches.isEmpty) return null;
    return _matches[_currentMatchIndex];
  }

  /// The total number of matches.
  int get matchCount => _matches.length;

  /// Whether search is currently active.
  bool _isActive = false;
  bool get isActive => _isActive;

  /// List of active highlights.
  final List<TerminalHighlight> _highlights = [];

  /// Sets the search pattern and triggers a new search.
  void setPattern(String pattern) {
    if (_pattern == pattern) return;
    _pattern = pattern;
    _performSearch();
  }

  /// Sets the search options and triggers a new search.
  void setOptions(TerminalSearchOptions options) {
    if (_options == options) return;
    _options = options;
    _performSearch();
  }

  /// Toggles case sensitivity.
  void toggleCaseSensitive() {
    _options = _options.copyWith(caseSensitive: !_options.caseSensitive);
    _performSearch();
  }

  /// Toggles regex mode.
  void toggleRegex() {
    _options = _options.copyWith(useRegex: !_options.useRegex);
    _performSearch();
  }

  /// Activates the search functionality.
  void activate() {
    _isActive = true;
    _performSearch();
    notifyListeners();
  }

  /// Deactivates the search functionality and clears highlights.
  void deactivate() {
    _isActive = false;
    _clearHighlights();
    _matches = [];
    _currentMatchIndex = 0;
    notifyListeners();
  }

  /// Navigates to the next match.
  void nextMatch() {
    if (_matches.isEmpty) return;
    _currentMatchIndex = (_currentMatchIndex + 1) % _matches.length;
    _updateHighlights();
    notifyListeners();
  }

  /// Navigates to the previous match.
  void previousMatch() {
    if (_matches.isEmpty) return;
    _currentMatchIndex =
        (_currentMatchIndex - 1 + _matches.length) % _matches.length;
    _updateHighlights();
    notifyListeners();
  }

  /// Navigates to a specific match by index.
  void goToMatch(int index) {
    if (index < 0 || index >= _matches.length) return;
    _currentMatchIndex = index;
    _updateHighlights();
    notifyListeners();
  }

  /// Performs the search operation.
  void _performSearch() {
    if (!_isActive || _pattern.isEmpty) {
      _clearHighlights();
      _matches = [];
      _currentMatchIndex = 0;
      notifyListeners();
      return;
    }

    final buffer = terminal.buffer;
    final newMatches = <TerminalSearchMatch>[];

    try {
      final regex = _buildRegex();
      if (regex == null) {
        _clearHighlights();
        _matches = [];
        _currentMatchIndex = 0;
        notifyListeners();
        return;
      }

      // Search line by line
      for (int lineIndex = 0; lineIndex < buffer.height; lineIndex++) {
        final line = buffer.lines[lineIndex];
        final lineText = line.getText();

        for (final match in regex.allMatches(lineText)) {
          final startX = _getVisualPosition(line, match.start);
          final endX = _getVisualPosition(line, match.end);

          newMatches.add(TerminalSearchMatch(
            start: CellOffset(startX, lineIndex),
            end: CellOffset(endX, lineIndex),
            text: match.group(0) ?? '',
          ));
        }
      }
    } catch (e) {
      // Invalid regex, clear matches
      _clearHighlights();
      _matches = [];
      _currentMatchIndex = 0;
      notifyListeners();
      return;
    }

    _matches = newMatches;

    // Try to keep the current match index valid
    if (_currentMatchIndex >= _matches.length) {
      _currentMatchIndex = _matches.isEmpty ? 0 : _matches.length - 1;
    }

    _updateHighlights();
    notifyListeners();
  }

  /// Builds the regex pattern based on current options.
  RegExp? _buildRegex() {
    if (_pattern.isEmpty) return null;

    try {
      String regexPattern;
      if (_options.useRegex) {
        regexPattern = _pattern;
      } else {
        // Escape special regex characters for literal search
        regexPattern = RegExp.escape(_pattern);
      }

      return RegExp(
        regexPattern,
        caseSensitive: _options.caseSensitive,
        multiLine: false,
      );
    } catch (e) {
      return null;
    }
  }

  /// Converts a text position to a visual cell position.
  /// This handles wide characters (e.g., CJK, emoji) correctly.
  int _getVisualPosition(BufferLine line, int textPosition) {
    int visualPos = 0;
    int textPos = 0;

    final length = line.getTrimmedLength();
    for (int i = 0; i < length && textPos < textPosition; i++) {
      final width = line.getWidth(i);
      if (width > 0) {
        textPos++;
        visualPos = i + 1;
      }
    }

    return visualPos;
  }

  /// Clears all active highlights.
  void _clearHighlights() {
    for (final highlight in _highlights) {
      highlight.dispose();
    }
    _highlights.clear();
  }

  /// Updates the highlights based on current matches.
  void _updateHighlights() {
    _clearHighlights();

    if (_matches.isEmpty) return;

    final buffer = terminal.buffer;

    for (int i = 0; i < _matches.length; i++) {
      final match = _matches[i];
      final isCurrent = i == _currentMatchIndex;

      // Get the matched range coordinates
      final startY = match.start.y;
      final endY = match.end.y;

      if (startY < 0 || startY >= buffer.height) continue;

      // Create anchors for the highlight
      final p1 = buffer.createAnchor(match.start.x, startY);
      final p2 = buffer.createAnchor(match.end.x, endY);

      // Use different colors for current match vs other matches
      // Use semi-transparent colors so the underlying text remains visible
      // in both light and dark themes.
      final color = isCurrent
          ? const Color(0xFF31FF26)
              .withValues(alpha: 0.5) // bright green with alpha
          : const Color(0xFFFFFF2B).withValues(alpha: 0.5); // yellow with alpha

      final highlight = terminalController.highlight(
        p1: p1,
        p2: p2,
        color: color,
      );

      _highlights.add(highlight);

      if (isCurrent) {
        terminalController.scrollToLine(match.start.y);
      }
    }
  }

  /// Refreshes the search results (e.g., after terminal content changes).
  void refresh() {
    if (_isActive) {
      _performSearch();
    }
  }

  @override
  void dispose() {
    _clearHighlights();
    super.dispose();
  }
}
