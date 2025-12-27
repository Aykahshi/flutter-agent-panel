import 'dart:convert';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

/// GitHub repository information for release checking.
const String _githubOwner = 'Aykahshi';
const String _githubRepo = 'flutter-agent-panel';

/// Service for managing application version information and updates.
class AppVersionService {
  AppVersionService._();

  static final AppVersionService instance = AppVersionService._();

  PackageInfo? _packageInfo;

  /// Gets the package info (cached after first call).
  Future<PackageInfo> getPackageInfo() async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    return _packageInfo!;
  }

  /// Gets the current app version string (e.g., "1.0.0").
  Future<String> getVersion() async {
    final info = await getPackageInfo();
    return info.version;
  }

  /// Gets the current build number (e.g., "1").
  Future<String> getBuildNumber() async {
    final info = await getPackageInfo();
    return info.buildNumber;
  }

  /// Gets the full version string (e.g., "1.0.0+1").
  Future<String> getFullVersion() async {
    final info = await getPackageInfo();
    return '${info.version}+${info.buildNumber}';
  }

  /// Fetches the latest version from GitHub Releases.
  /// Returns the version string without the 'v' prefix.
  Future<String> getLatestVersion() async {
    try {
      final url = Uri.parse(
        'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest',
      );
      final request = await HttpClient().getUrl(url);
      request.headers.add('Accept', 'application/vnd.github.v3+json');
      request.headers.add('User-Agent', 'flutter-agent-panel');

      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final tagName = json['tag_name'] as String?;
        if (tagName != null) {
          // Remove 'Release v' or 'v' prefix if present
          return tagName
              .replaceFirst('Release v', '')
              .replaceFirst('v', '')
              .trim();
        }
      }
      // Return current version if no release found
      return await getVersion();
    } catch (e) {
      // Return current version on error
      return await getVersion();
    }
  }

  /// Checks if there is an update available.
  Future<bool> hasUpdate() async {
    try {
      final currentVersion = await getVersion();
      final latestVersion = await getLatestVersion();

      return _isVersionGreaterThan(latestVersion, currentVersion);
    } catch (e) {
      return false;
    }
  }

  bool _isVersionGreaterThan(String v1, String v2) {
    try {
      final v1Parts = v1.split('.').map(int.parse).toList();
      final v2Parts = v2.split('.').map(int.parse).toList();

      for (var i = 0; i < v1Parts.length && i < v2Parts.length; i++) {
        if (v1Parts[i] > v2Parts[i]) return true;
        if (v1Parts[i] < v2Parts[i]) return false;
      }

      // If lengths differ, the one with more parts is greater (e.g. 1.0.1 > 1.0)
      return v1Parts.length > v2Parts.length;
    } catch (e) {
      return false;
    }
  }

  /// Gets the download URL for the binary based on current platform.
  Future<String> getBinaryUrl(String version) async {
    final baseUrl =
        'https://github.com/$_githubOwner/$_githubRepo/releases/download/Release%20v$version';

    if (Platform.isWindows) {
      return '$baseUrl/flutter_agent_panel-$version-windows-x86_64-setup.exe';
    } else if (Platform.isMacOS) {
      return '$baseUrl/flutter_agent_panel-$version-macos-universal.dmg';
    } else if (Platform.isLinux) {
      return '$baseUrl/flutter_agent_panel-$version-linux-x86_64.tar.gz';
    }

    // Default to Windows
    return '$baseUrl/flutter_agent_panel-$version-windows-x86_64-setup.exe';
  }

  /// Gets the GitHub releases page URL.
  String getReleasesPageUrl() {
    return 'https://github.com/$_githubOwner/$_githubRepo/releases';
  }
}
