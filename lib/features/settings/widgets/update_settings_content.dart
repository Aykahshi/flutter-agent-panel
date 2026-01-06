import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:updat/updat.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/extensions/context_extension.dart';
import '../../../../core/services/app_version_service.dart';
import 'settings_section.dart';

/// Widget for the Update settings content.
class UpdateSettingsContent extends StatefulWidget {
  const UpdateSettingsContent({super.key});

  @override
  State<UpdateSettingsContent> createState() => _UpdateSettingsContentState();
}

class _UpdateSettingsContentState extends State<UpdateSettingsContent> {
  String? _currentVersion;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    // _cleanupDownloadedFiles() is called inside _loadVersion()
  }

  Future<void> _loadVersion() async {
    final version = await AppVersionService.instance.getVersion();
    _cleanupDownloadedFiles(); // Also cleanup when checking/loading version
    if (mounted) {
      setState(() {
        _currentVersion = version;
        _isLoading = false;
      });
    }
  }

  Future<void> _openReleasesPage() async {
    final url = Uri.parse(AppVersionService.instance.getReleasesPageUrl());
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  /// Clean up any leftover downloaded installer files in the temp directory.
  Future<void> _cleanupDownloadedFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final dir = Directory(tempDir.path);
      if (await dir.exists()) {
        final List<FileSystemEntity> entities = await dir.list().toList();
        for (final entity in entities) {
          if (entity is File) {
            final fileName = entity.path.split(Platform.pathSeparator).last;
            // Matches: flutter_agent_panel-0.0.6-windows-x86_64-setup.exe, etc.
            if (fileName.startsWith('flutter_agent_panel-') &&
                (fileName.endsWith('.exe') ||
                    fileName.endsWith('.dmg') ||
                    fileName.endsWith('.tar.gz'))) {
              try {
                await entity.delete();
              } catch (e) {
                // File might be in use, ignore
              }
            }
          }
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.t;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Version Section
        SettingsSection(
          title: l10n.currentVersion,
          description: l10n.updateDescription,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: theme.colorScheme.border,
                  ),
                ),
                child: _isLoading || _currentVersion == null
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : Text(
                        'v${_currentVersion!}',
                        style: theme.textTheme.large.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
              ),
              Gap(16.w),
              ShadButton.outline(
                onPressed: _openReleasesPage,
                leading: Icon(
                  LucideIcons.externalLink,
                  size: 14.sp,
                ),
                child: Text(l10n.latestVersion),
              ),
            ],
          ),
        ),
        Divider(
          height: 48.h,
          color: theme.colorScheme.border,
        ),

        // Update Widget Section
        SettingsSection(
          title: l10n.checkForUpdates,
          description: l10n.updateDescription,
          child: _currentVersion == null
              ? const Center(child: ShadProgress())
              : UpdatWidget(
                  currentVersion: _currentVersion!,
                  getLatestVersion: () async {
                    return await AppVersionService.instance.getLatestVersion();
                  },
                  getBinaryUrl: (latestVersion) async {
                    return await AppVersionService.instance.getBinaryUrl(
                      latestVersion ?? _currentVersion!,
                    );
                  },
                  getDownloadFileLocation: (latestVersion) async {
                    final url = await AppVersionService.instance.getBinaryUrl(
                      latestVersion ?? _currentVersion!,
                    );
                    final fileName = url.split('/').last;
                    // Download to temp directory instead of Downloads folder
                    final tempDir = await getTemporaryDirectory();
                    final file = File('${tempDir.path}/$fileName');
                    return file;
                  },
                  appName: 'Flutter Agent Panel',
                  updateChipBuilder: _buildUpdateChip,
                  updateDialogBuilder: _buildUpdateDialog,
                  callback: (status) {
                    // Handle status changes
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;

                      if (status == UpdatStatus.upToDate) {
                        // Clear any previous error and cleanup downloaded file
                        setState(() => _errorMessage = null);
                        _cleanupDownloadedFiles();
                        ShadToaster.of(context).show(
                          ShadToast(
                            title: Row(
                              spacing: 8,
                              children: [
                                const Icon(
                                  LucideIcons.circleCheck,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                Text(l10n.noUpdatesAvailable),
                              ],
                            ),
                          ),
                        );
                      } else if (status == UpdatStatus.error) {
                        // Set error message for display and cleanup
                        setState(() {
                          _errorMessage = l10n.updateErrorMessage;
                        });
                        _cleanupDownloadedFiles();
                      } else if (status == UpdatStatus.available ||
                          status == UpdatStatus.checking ||
                          status == UpdatStatus.downloading) {
                        // Clear error when retrying or checking
                        setState(() => _errorMessage = null);
                      }
                    });
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUpdateChip({
    required BuildContext context,
    required UpdatStatus status,
    required String appVersion,
    String? latestVersion,
    required VoidCallback checkForUpdate,
    required VoidCallback openDialog,
    required VoidCallback startUpdate,
    required VoidCallback dismissUpdate,
    required Future<void> Function() launchInstaller,
  }) {
    final l10n = context.t;
    final theme = context.theme;

    String label;
    IconData icon;
    Color? iconColor;
    VoidCallback? onPressed = openDialog;
    bool isError = false;
    bool isDownloading = false;

    switch (status) {
      case UpdatStatus.idle:
        label = l10n.checkForUpdates;
        icon = LucideIcons.refreshCcw;
        onPressed = checkForUpdate;
        break;
      case UpdatStatus.checking:
        label = l10n.checkingForUpdates;
        icon = LucideIcons.loader;
        onPressed = null;
        break;
      case UpdatStatus.available:
        label = l10n.updateAvailable;
        icon = LucideIcons.download;
        break;
      case UpdatStatus.downloading:
        label = l10n.downloading;
        icon = LucideIcons.download;
        onPressed = null;
        isDownloading = true;
        break;
      case UpdatStatus.error:
        label = l10n.updateError;
        icon = LucideIcons.circleAlert;
        iconColor = theme.colorScheme.destructive;
        onPressed = checkForUpdate;
        isError = true;
        break;
      default:
        label = l10n.checkForUpdates;
        icon = LucideIcons.refreshCcw;
        onPressed = checkForUpdate;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ShadButton.outline(
              onPressed: onPressed,
              foregroundColor: isError ? theme.colorScheme.destructive : null,
              leading: Icon(
                icon,
                size: 16.sp,
                color: iconColor,
              ),
              child: Text(label),
            ),
            if (isDownloading) ...[
              Gap(12.w),
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
        // Show error message below button
        if (_errorMessage != null && isError) ...[
          Gap(8.h),
          Text(
            _errorMessage!,
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.destructive,
            ),
          ),
        ],
      ],
    );
  }

  void _buildUpdateDialog({
    required BuildContext context,
    required UpdatStatus status,
    required String appVersion,
    String? latestVersion,
    String? changelog,
    required VoidCallback checkForUpdate,
    required VoidCallback openDialog,
    required VoidCallback startUpdate,
    required VoidCallback dismissUpdate,
    required Future<void> Function() launchInstaller,
  }) {
    showShadDialog(
      context: context,
      builder: (context) {
        final l10n = context.t;

        return ShadDialog(
          title: Text(l10n.updateAvailable),
          description: Text(
            l10n.updateAvailableDescription(latestVersion ?? '', appVersion),
          ),
          actions: [
            ShadButton.outline(
              onPressed: () {
                dismissUpdate();
                Navigator.of(context).pop();
              },
              child: Text(l10n.later),
            ),
            ShadButton(
              onPressed: () {
                startUpdate();
                Navigator.of(context).pop();
              },
              child: Text(l10n.updateNow),
            ),
          ],
        );
      },
    );
  }
}
