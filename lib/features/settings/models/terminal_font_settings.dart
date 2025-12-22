import 'package:equatable/equatable.dart';

/// Terminal font configuration settings
class TerminalFontSettings extends Equatable {
  final String fontFamily;
  final double fontSize;
  final bool isBold;
  final bool isItalic;

  const TerminalFontSettings({
    this.fontFamily = 'Cascadia Code',
    this.fontSize = 14.0,
    this.isBold = false,
    this.isItalic = false,
  });

  TerminalFontSettings copyWith({
    String? fontFamily,
    double? fontSize,
    bool? isBold,
    bool? isItalic,
  }) {
    return TerminalFontSettings(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
    );
  }

  factory TerminalFontSettings.fromJson(Map<String, dynamic> json) {
    return TerminalFontSettings(
      fontFamily: json['fontFamily'] as String? ?? 'Cascadia Code',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      isBold: json['isBold'] as bool? ?? false,
      isItalic: json['isItalic'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'isBold': isBold,
      'isItalic': isItalic,
    };
  }

  @override
  List<Object?> get props => [fontFamily, fontSize, isBold, isItalic];
}
