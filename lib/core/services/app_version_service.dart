import 'dart:convert';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import 'app_logger.dart';

/// GitHub repository information for release checking.
const String _githubOwner = 'Aykahshi';
const String _githubRepo = 'flutter-agent-panel';

/// Service for managing application version information and updates.
class AppVersionService {
  AppVersionService._();

  static final AppVersionService instance = AppVersionService._();

  PackageInfo? _packageInfo;
  Map<String, dynamic>? _latestReleaseJson;

  /// Gets the package info (cached after first call).
  Future<PackageInfo> getPackageInfo() async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    return _packageInfo!;
  }

  /// Gets the current app version string (e.g., "1.0.0").
  Future<String> getVersion() async {
    final info = await getPackageInfo();
    // Normalize: remove anything after + or -
    return info.version.split('+')[0].split('-')[0];
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
    AppLogger.instance.logger.d({
      'logger': 'Update',
      'message': 'Fetching latest version from GitHub...',
    });
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
        _latestReleaseJson = json;
        final tagName = json['tag_name'] as String?;
        if (tagName != null) {
          // Remove 'Release v' or 'v' prefix if present
          final version = tagName
              .replaceFirst('Release v', '')
              .replaceFirst('v', '')
              .trim();
          AppLogger.instance.logger.i({
            'logger': 'Update',
            'action': 'latestVersionFetched',
            'version': version,
            'tagName': tagName,
          });
          return version;
        }
      }
      // Return current version if no release found
      final currentVersion = await getVersion();
      AppLogger.instance.logger.w({
        'logger': 'Update',
        'message': 'No release found, using current version',
        'currentVersion': currentVersion,
      });
      return currentVersion;
    } catch (e) {
      AppLogger.instance.logger.e(
        {
          'logger': 'Update',
          'message': 'Error fetching latest version',
        },
        error: e,
      );
      // Return current version on error
      return await getVersion();
    }
  }

  /// Checks if there is an update available.
  Future<bool> hasUpdate() async {
    try {
      final currentVersion = await getVersion();
      final latestVersion = await getLatestVersion();
      final updateAvailable =
          _isVersionGreaterThan(latestVersion, currentVersion);

      AppLogger.instance.logger.i({
        'logger': 'Update',
        'action': 'updateCheck',
        'currentVersion': currentVersion,
        'latestVersion': latestVersion,
        'updateAvailable': updateAvailable,
      });

      return updateAvailable;
    } catch (e) {
      AppLogger.instance.logger.e(
        {
          'logger': 'Update',
          'message': 'Error checking for updates',
        },
        error: e,
      );
      return false;
    }
  }

  bool _isVersionGreaterThan(String v1, String v2) {
    try {
      // Strip build numbers or pre-release suffixes (e.g., 0.0.3+1 -> 0.0.3)
      final cleanV1 = v1.split('+')[0].split('-')[0];
      final cleanV2 = v2.split('+')[0].split('-')[0];

      final v1Parts = cleanV1.split('.').map(int.parse).toList();
      final v2Parts = cleanV2.split('.').map(int.parse).toList();

      for (var i = 0; i < v1Parts.length && i < v2Parts.length; i++) {
        if (v1Parts[i] > v2Parts[i]) return true;
        if (v1Parts[i] < v2Parts[i]) return false;
      }

      // If lengths differ, the one with more parts is greater (e.g. 1.0.1 > 1.0)
      return v1Parts.length > v2Parts.length;
    } catch (e) {
      AppLogger.instance.logger.e(
        {
          'logger': 'Update',
          'message': 'Error comparing versions: $v1 vs $v2',
        },
        error: e,
      );
      return false;
    }
  }

  /// Gets the download URL for the binary based on current platform.
  Future<String> getBinaryUrl(String version) async {
    // If we have cached release info, try to find the best asset
    if (_latestReleaseJson != null) {
      final assets = _latestReleaseJson!['assets'] as List<dynamic>?;
      if (assets != null) {
        final assetUrls =
            assets.map((a) => a['browser_download_url'] as String).toList();

        switch (Platform.operatingSystem) {
          case 'windows':
            final setupExe = assetUrls
                .where((url) => url.endsWith('-setup.exe'))
                .firstOrNull;
            if (setupExe != null) return setupExe;
          case 'macos':
            final dmg =
                assetUrls.where((url) => url.endsWith('.dmg')).firstOrNull;
            if (dmg != null) return dmg;
          case 'linux':
            final tarGz =
                assetUrls.where((url) => url.endsWith('.tar.gz')).firstOrNull;
            if (tarGz != null) return tarGz;
        }
      }
    }

    // Fallback if no assets found or no cache
    final cleanVersion = version.split('+')[0].split('-')[0];
    final baseUrl =
        'https://github.com/$_githubOwner/$_githubRepo/releases/download/v$cleanVersion';

    if (Platform.isWindows) {
      return '$baseUrl/flutter_agent_panel-$cleanVersion-windows-x86_64-setup.exe';
    } else if (Platform.isMacOS) {
      return '$baseUrl/flutter_agent_panel-$cleanVersion-macos-universal.dmg';
    } else if (Platform.isLinux) {
      return '$baseUrl/flutter_agent_panel-$cleanVersion-linux-x86_64.tar.gz';
    }

    return '$baseUrl/flutter_agent_panel-$cleanVersion-windows-x86_64-setup.exe';
  }

  /// Gets the GitHub releases page URL.
  String getReleasesPageUrl() {
    return 'https://github.com/$_githubOwner/$_githubRepo/releases';
  }
}
