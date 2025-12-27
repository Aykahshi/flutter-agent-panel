import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
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
  String _currentVersion = '0.0.0';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final version = await AppVersionService.instance.getFullVersion();
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
                child: _isLoading
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : Text(
                        'v$_currentVersion',
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
          child: UpdatWidget(
            currentVersion: _currentVersion,
            getLatestVersion: () async {
              return await AppVersionService.instance.getLatestVersion();
            },
            getBinaryUrl: (latestVersion) async {
              return await AppVersionService.instance.getBinaryUrl(
                latestVersion ?? _currentVersion,
              );
            },
            appName: 'Flutter Agent Panel',
            updateChipBuilder: _buildUpdateChip,
            updateDialogBuilder: _buildUpdateDialog,
            callback: (status) {
              // Handle update status changes if needed
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

    String label;
    IconData icon;
    VoidCallback? onPressed = openDialog;

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
        break;
      case UpdatStatus.error:
        label = l10n.updateError;
        icon = LucideIcons.info;
        onPressed = checkForUpdate;
        break;
      default:
        label = l10n.checkForUpdates;
        icon = LucideIcons.refreshCcw;
        onPressed = checkForUpdate;
    }

    return ShadButton.outline(
      onPressed: onPressed,
      leading: Icon(icon, size: 16.sp),
      child: Text(label),
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
