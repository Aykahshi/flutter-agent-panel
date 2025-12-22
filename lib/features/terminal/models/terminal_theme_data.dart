import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:xterm/xterm.dart' as xterm;

/// Data class representing a terminal color theme loaded from JSON.
class TerminalThemeData extends Equatable {
  final String name;
  final Color black;
  final Color red;
  final Color green;
  final Color yellow;
  final Color blue;
  final Color purple;
  final Color cyan;
  final Color white;
  final Color brightBlack;
  final Color brightRed;
  final Color brightGreen;
  final Color brightYellow;
  final Color brightBlue;
  final Color brightPurple;
  final Color brightCyan;
  final Color brightWhite;
  final Color background;
  final Color foreground;
  final Color selectionBackground;
  final Color cursorColor;

  const TerminalThemeData({
    required this.name,
    required this.black,
    required this.red,
    required this.green,
    required this.yellow,
    required this.blue,
    required this.purple,
    required this.cyan,
    required this.white,
    required this.brightBlack,
    required this.brightRed,
    required this.brightGreen,
    required this.brightYellow,
    required this.brightBlue,
    required this.brightPurple,
    required this.brightCyan,
    required this.brightWhite,
    required this.background,
    required this.foreground,
    required this.selectionBackground,
    required this.cursorColor,
  });

  /// Parse a hex color string (e.g., "#RRGGBB") to a Color.
  static Color _parseHexColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add alpha if not present
    }
    return Color(int.parse(hex, radix: 16));
  }

  /// Create a TerminalThemeData from a JSON map.
  factory TerminalThemeData.fromJson(Map<String, dynamic> json) {
    return TerminalThemeData(
      name: json['name'] as String? ?? 'Unnamed',
      black: _parseHexColor(json['black'] as String? ?? '#000000'),
      red: _parseHexColor(json['red'] as String? ?? '#FF0000'),
      green: _parseHexColor(json['green'] as String? ?? '#00FF00'),
      yellow: _parseHexColor(json['yellow'] as String? ?? '#FFFF00'),
      blue: _parseHexColor(json['blue'] as String? ?? '#0000FF'),
      purple: _parseHexColor(json['purple'] as String? ?? '#FF00FF'),
      cyan: _parseHexColor(json['cyan'] as String? ?? '#00FFFF'),
      white: _parseHexColor(json['white'] as String? ?? '#FFFFFF'),
      brightBlack: _parseHexColor(json['brightBlack'] as String? ?? '#808080'),
      brightRed: _parseHexColor(json['brightRed'] as String? ?? '#FF0000'),
      brightGreen: _parseHexColor(json['brightGreen'] as String? ?? '#00FF00'),
      brightYellow:
          _parseHexColor(json['brightYellow'] as String? ?? '#FFFF00'),
      brightBlue: _parseHexColor(json['brightBlue'] as String? ?? '#0000FF'),
      brightPurple:
          _parseHexColor(json['brightPurple'] as String? ?? '#FF00FF'),
      brightCyan: _parseHexColor(json['brightCyan'] as String? ?? '#00FFFF'),
      brightWhite: _parseHexColor(json['brightWhite'] as String? ?? '#FFFFFF'),
      background: _parseHexColor(json['background'] as String? ?? '#000000'),
      foreground: _parseHexColor(json['foreground'] as String? ?? '#FFFFFF'),
      selectionBackground:
          _parseHexColor(json['selectionBackground'] as String? ?? '#3A3D41'),
      cursorColor: _parseHexColor(json['cursorColor'] as String? ?? '#FFFFFF'),
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() {
    String colorToHex(Color c) =>
        '#${c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    return {
      'name': name,
      'black': colorToHex(black),
      'red': colorToHex(red),
      'green': colorToHex(green),
      'yellow': colorToHex(yellow),
      'blue': colorToHex(blue),
      'purple': colorToHex(purple),
      'cyan': colorToHex(cyan),
      'white': colorToHex(white),
      'brightBlack': colorToHex(brightBlack),
      'brightRed': colorToHex(brightRed),
      'brightGreen': colorToHex(brightGreen),
      'brightYellow': colorToHex(brightYellow),
      'brightBlue': colorToHex(brightBlue),
      'brightPurple': colorToHex(brightPurple),
      'brightCyan': colorToHex(brightCyan),
      'brightWhite': colorToHex(brightWhite),
      'background': colorToHex(background),
      'foreground': colorToHex(foreground),
      'selectionBackground': colorToHex(selectionBackground),
      'cursorColor': colorToHex(cursorColor),
    };
  }

  /// Convert to xterm.TerminalTheme for use with the xterm package.
  xterm.TerminalTheme toXtermTheme() {
    return xterm.TerminalTheme(
      cursor: cursorColor,
      selection: selectionBackground.withValues(alpha: 0.5),
      background: background,
      foreground: foreground,
      black: black,
      red: red,
      green: green,
      yellow: yellow,
      blue: blue,
      magenta: purple,
      cyan: cyan,
      white: white,
      brightBlack: brightBlack,
      brightRed: brightRed,
      brightGreen: brightGreen,
      brightYellow: brightYellow,
      brightBlue: brightBlue,
      brightMagenta: brightPurple,
      brightCyan: brightCyan,
      brightWhite: brightWhite,
      searchHitBackground: const Color(0xFFE5E510),
      searchHitBackgroundCurrent: const Color(0xFF0DBC79),
      searchHitForeground: const Color(0xFF000000),
    );
  }

  @override
  List<Object?> get props => [
        name,
        black,
        red,
        green,
        yellow,
        blue,
        purple,
        cyan,
        white,
        brightBlack,
        brightRed,
        brightGreen,
        brightYellow,
        brightBlue,
        brightPurple,
        brightCyan,
        brightWhite,
        background,
        foreground,
        selectionBackground,
        cursorColor,
      ];
}
