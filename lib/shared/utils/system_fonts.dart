import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Represents a font family with all its variant file paths.
class FontFamilyInfo {
  FontFamilyInfo({required this.name, required this.paths});

  final String name;
  final List<String> paths;

  /// Returns the primary (first) path for loading.
  String get primaryPath => paths.first;
}

/// A lightweight TTF/OTF name table parser to extract font family names.
class TtfNameParser {
  static const int nameTableTag = 0x6E616D65; // 'name'

  /// Parses the font family name from a TTF/OTF file.
  /// Prioritizes Chinese names (Traditional > Simplified) then English.
  static String? getFontFamily(String path) {
    RandomAccessFile? file;
    try {
      file = File(path).openSync();

      // Read SFNT Header (12 bytes)
      final headerData = file.readSync(12);
      if (headerData.length < 12) return null;
      final header = ByteData.sublistView(headerData);
      final numTables = header.getUint16(4);

      // Read Table Directory
      int nameTableOffset = -1;
      for (int i = 0; i < numTables; i++) {
        final entryData = file.readSync(16);
        if (entryData.length < 16) break;
        final entry = ByteData.sublistView(entryData);
        final tag = entry.getUint32(0);
        if (tag == nameTableTag) {
          nameTableOffset = entry.getUint32(8);
          break;
        }
      }

      if (nameTableOffset == -1) return null;

      // Read 'name' table header
      file.setPositionSync(nameTableOffset);
      final nameHeaderData = file.readSync(6);
      if (nameHeaderData.length < 6) return null;
      final nameHeader = ByteData.sublistView(nameHeaderData);
      final count = nameHeader.getUint16(2);
      final stringOffset = nameHeader.getUint16(4);

      // Read NameRecords
      final recordsData = file.readSync(count * 12);
      if (recordsData.length < count * 12) return null;
      final records = ByteData.sublistView(recordsData);

      // Map to store found names by ID and Priority
      // Priority: 16 (Preferred Family) > 1 (Font Family)
      // Language Priority: 0x0404/0x0c04 (TW/HK) > 0x0804 (CN) > 0x0409 (US)
      final Map<int, Map<int, String>> names = {};

      for (int i = 0; i < count; i++) {
        final offset = i * 12;
        final platformID = records.getUint16(offset);
        final languageID = records.getUint16(offset + 4);
        final nameID = records.getUint16(offset + 6);
        final length = records.getUint16(offset + 8);
        final stringDataOffset = records.getUint16(offset + 10);

        if (nameID == 1 || nameID == 16) {
          final currentPos = file.positionSync();
          file.setPositionSync(
            nameTableOffset + stringOffset + stringDataOffset,
          );
          final bytes = file.readSync(length);
          file.setPositionSync(currentPos);

          String? name;
          if (platformID == 3 || platformID == 0) {
            // Windows or Unicode (UTF-16BE)
            try {
              name = _decodeUtf16Be(bytes);
            } catch (_) {}
          } else if (platformID == 1) {
            // Macintosh (Mac Roman) - simplified handling
            name = utf8.decode(bytes, allowMalformed: true);
          }

          if (name != null && name.isNotEmpty) {
            names.putIfAbsent(nameID, () => {})[languageID] = name;
          }
        }
      }

      // Selection logic
      return _pickBestName(names);
    } catch (e) {
      return null;
    } finally {
      file?.closeSync();
    }
  }

  static String _decodeUtf16Be(Uint8List bytes) {
    final charCodes = <int>[];
    for (int i = 0; i < bytes.length; i += 2) {
      if (i + 1 < bytes.length) {
        charCodes.add((bytes[i] << 8) | bytes[i + 1]);
      }
    }
    return String.fromCharCodes(charCodes);
  }

  static String? _pickBestName(Map<int, Map<int, String>> names) {
    // Priority Name IDs: 16, then 1
    for (final nameID in [16, 1]) {
      final familyNames = names[nameID];
      if (familyNames == null) continue;

      // Lang Priority: Trad Chin (0x0404, 0x0c04, 0x1404, 0x1004) -> Simp Chin (0x0804) -> English (0x0409, 0x0809 etc)
      const tradChin = [0x0404, 0x0c04, 0x1404, 0x1004];
      for (final lang in tradChin) {
        if (familyNames.containsKey(lang)) return familyNames[lang];
      }
      if (familyNames.containsKey(0x0804)) return familyNames[0x0804];
      if (familyNames.containsKey(0x0409)) return familyNames[0x0409];

      // Fallback to any English-like or just any
      for (final lang in familyNames.keys) {
        if ((lang & 0xFF) == 0x09) return familyNames[lang];
      }
      if (familyNames.isNotEmpty) return familyNames.values.first;
    }
    return null;
  }
}

/// Helper for background scanning
class FontScanResult {
  FontScanResult(this.fontPaths, this.familyMap);
  final List<String> fontPaths;
  final Map<String, FontFamilyInfo> familyMap;
}

Future<FontScanResult> _scanFontsIsolate(List<String> directories) async {
  final List<String> fontPaths = [];
  final Map<String, FontFamilyInfo> familyMap = {};

  for (final dirPath in directories) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) continue;

    try {
      final entities = dir.listSync(recursive: true, followLinks: false);
      for (final entity in entities) {
        if (entity is File) {
          final path = entity.path.toLowerCase();
          if (path.endsWith('.ttf') || path.endsWith('.otf')) {
            fontPaths.add(entity.path);
          }
        }
      }
    } catch (_) {}
  }

  for (final path in fontPaths) {
    final familyName = TtfNameParser.getFontFamily(path);
    if (familyName != null && familyName.isNotEmpty) {
      if (familyMap.containsKey(familyName)) {
        familyMap[familyName]!.paths.add(path);
      } else {
        familyMap[familyName] = FontFamilyInfo(name: familyName, paths: [path]);
      }
    }
  }

  return FontScanResult(fontPaths, familyMap);
}

class SystemFonts {
  SystemFonts._internal() {
    _fontDirectories.addAll(_getFontDirectories());
  }

  factory SystemFonts() {
    return _instance;
  }

  static final SystemFonts _instance = SystemFonts._internal();

  final List<String> _fontDirectories = [];
  List<String> _fontPaths = [];
  Map<String, FontFamilyInfo> _fontFamilyMap = {};
  final List<String> _loadedFonts = [];

  bool _isScanned = false;
  Completer<void>? _scanCompleter;

  List<String> _getFontDirectories() {
    if (Platform.isWindows) {
      return [
        '${Platform.environment['windir']}/fonts/',
        '${Platform.environment['USERPROFILE']}/AppData/Local/Microsoft/Windows/Fonts/',
      ];
    }
    if (Platform.isMacOS) {
      return [
        '/Library/Fonts/',
        '/System/Library/Fonts/',
        '${Platform.environment['HOME']}/Library/Fonts/',
      ];
    }
    if (Platform.isLinux) {
      return [
        '/usr/share/fonts/',
        '/usr/local/share/fonts/',
        '${Platform.environment['HOME']}/.local/share/fonts/',
      ];
    }
    return [];
  }

  Future<void> _scanFonts() async {
    if (_isScanned) return;
    if (_scanCompleter != null) return _scanCompleter!.future;

    _scanCompleter = Completer<void>();

    try {
      final result = await compute(_scanFontsIsolate, _fontDirectories);
      _fontPaths = result.fontPaths;
      _fontFamilyMap = result.familyMap;
      _isScanned = true;
      _scanCompleter!.complete();
    } catch (e) {
      _scanCompleter!.completeError(e);
      rethrow;
    } finally {
      _scanCompleter = null;
    }
  }

  Future<List<String>> getFontFamilies() async {
    await _scanFonts();
    return _fontFamilyMap.keys.toList()..sort();
  }

  Future<FontFamilyInfo?> getFontFamilyInfo(String familyName) async {
    await _scanFonts();
    return _fontFamilyMap[familyName];
  }

  Future<String?> loadFont(String familyName) async {
    if (_loadedFonts.contains(familyName)) return familyName;

    await _scanFonts();
    final familyInfo = _fontFamilyMap[familyName];
    if (familyInfo == null) return null;

    try {
      final loader = FontLoader(familyName);
      for (final path in familyInfo.paths) {
        final bytes = await File(path).readAsBytes();
        loader.addFont(Future.value(ByteData.view(bytes.buffer)));
      }
      await loader.load();
      _loadedFonts.add(familyName);
      return familyName;
    } catch (_) {
      return null;
    }
  }

  Future<String?> loadFontFromPath(String path) async {
    if (!path.toLowerCase().endsWith('.ttf') &&
        !path.toLowerCase().endsWith('.otf')) {
      return null;
    }
    if (!File(path).existsSync()) return null;

    final familyName = TtfNameParser.getFontFamily(path);
    if (familyName == null || familyName.isEmpty) return null;

    if (_loadedFonts.contains(familyName)) return familyName;

    try {
      final bytes = await File(path).readAsBytes();
      final loader = FontLoader(familyName);
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
      await loader.load();
      _loadedFonts.add(familyName);

      if (!_fontFamilyMap.containsKey(familyName)) {
        _fontFamilyMap[familyName] =
            FontFamilyInfo(name: familyName, paths: [path]);
      }
      return familyName;
    } catch (_) {
      return null;
    }
  }

  void addAdditionalFontDirectory(String path) {
    if (Directory(path).existsSync() && !_fontDirectories.contains(path)) {
      _fontDirectories.add(path);
      _isScanned = false;
    }
  }

  void rescan() {
    _fontFamilyMap.clear();
    _fontPaths.clear();
    _isScanned = false;
  }

  // Legacy API
  List<String> getFontPaths() => _fontPaths;
  Map<String, String> getFontMap() {
    final map = <String, String>{};
    _fontFamilyMap.forEach((k, v) => map[k] = v.primaryPath);
    return map;
  }

  List<String> getFontList() => _fontFamilyMap.keys.toList();
}
