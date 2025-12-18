import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:signals/signals_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../terminal/viewmodels/terminal_viewmodel.dart';
import '../../terminal/views/terminal_view.dart';
import '../viewmodels/workspace_viewmodel.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../../core/viewmodels/theme_viewmodel.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import '../../terminal/models/terminal_node.dart';

class WorkspaceView extends StatefulWidget {
  const WorkspaceView({super.key});

  @override
  State<WorkspaceView> createState() => _WorkspaceViewState();
}

class _WorkspaceViewState extends State<WorkspaceView> {
  final _terminalViewModel = TerminalViewModel();
  final _workspaceViewModel = WorkspaceViewModel();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (t == null) {
      return const Center(
        child: Text("Localization Error: AppLocalizations not found"),
      );
    }

    return AppScaffold(
      // titleBar: Text(t.appTitle), // Optional custom title bar
      body: Material(
        type: MaterialType.transparency,
        child: Row(
          children: [
            // Sidebar (Workspaces)
            Container(
              width: 60.w,
              color: AppColors.surface,
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      // Demo: Add default workspace
                      _workspaceViewModel.addWorkspace("New Work", "");
                    },
                  ),
                  Expanded(
                    child: Watch((context) {
                      final workspaces = _workspaceViewModel.workspaces.value;
                      return ListView.builder(
                        itemCount: workspaces.length,
                        itemBuilder: (context, index) {
                          final w = workspaces[index];
                          return Watch((context) {
                            final isActive =
                                _workspaceViewModel.activeWorkspaceId.value ==
                                w.id;
                            return Tooltip(
                              message: w.name,
                              child: GestureDetector(
                                onTap: () {
                                  _workspaceViewModel.setActiveWorkspace(w.id);
                                },
                                child: Stack(
                                  children: [
                                    // Selection Indicator
                                    Positioned(
                                      left: 0,
                                      top: 10.h,
                                      bottom: 10.h,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        width: isActive ? 4.w : 0,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(4.r),
                                            bottomRight: Radius.circular(4.r),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 50.h,
                                      margin: EdgeInsets.symmetric(
                                        vertical: 4.h,
                                        horizontal: 8.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          w.name.substring(0, 1).toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 10.h),
                  IconButton(
                    icon: Watch((_) {
                      return Icon(
                        ThemeViewModel().themeMode.value == ThemeMode.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color: Colors.white,
                      );
                    }),
                    onPressed: () {
                      final newMode =
                          ThemeViewModel().themeMode.value == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark;
                      ThemeViewModel().setThemeMode(newMode);
                    },
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
            // Main Area (Terminal Split View)
            Expanded(
              child: Column(
                children: [
                  // Add Terminal Button Bar
                  Container(
                    height: 40.h,
                    color: AppColors.surface,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      children: [
                        Text(
                          t.terminal,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            final wsId =
                                _workspaceViewModel.activeWorkspaceId.value;
                            if (wsId != null) {
                              _terminalViewModel.createTerminal(
                                workspaceId: wsId,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Watch((context) {
                      final wsId = _workspaceViewModel.activeWorkspaceId.value;
                      if (wsId == null) {
                        return Center(
                          child: Text(
                            t.newTerminal,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      final terminals = _terminalViewModel
                          .getWorkspaceTerminals(wsId);
                      final activeId =
                          _terminalViewModel.activeTerminalId.value;

                      if (terminals.isEmpty) {
                        return Column(
                          children: [
                            Expanded(child: Center(child: Text(t.newTerminal))),
                            _buildThumbnailBar(context, terminals),
                          ],
                        );
                      }

                      final activeTerminal =
                          terminals.firstWhereOrNull((t) => t.id == activeId) ??
                          terminals.first;

                      return Column(
                        children: [
                          // Main Terminal (70%)
                          Expanded(
                            flex: 7,
                            child: TerminalView(
                              key: ObjectKey(activeTerminal.id),
                              terminalNode: activeTerminal,
                            ),
                          ),
                          // Thumbnail Bar (30%)
                          _buildThumbnailBar(context, terminals),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailBar(
    BuildContext context,
    IList<TerminalNode> terminals,
  ) {
    final t = AppLocalizations.of(context);
    return Container(
      height: 180.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderColor, width: 1)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        itemCount: terminals.length + 1,
        itemBuilder: (context, index) {
          if (index == terminals.length) {
            // "Add Terminal" button at the end
            return GestureDetector(
              onTap: () {
                final wsId = _workspaceViewModel.activeWorkspaceId.value;
                if (wsId != null) {
                  _terminalViewModel.createTerminal(workspaceId: wsId);
                }
              },
              child: Container(
                width: 200.w,
                margin: EdgeInsets.only(right: 10.w),
                decoration: BoxDecoration(
                  color: AppColors.terminalBackground,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.borderColor, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 30),
                    SizedBox(height: 5.h),
                    Text(
                      t?.newTerminal ?? '+ New',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          }

          final node = terminals[index];
          final isActive = _terminalViewModel.activeTerminalId.value == node.id;

          return GestureDetector(
            onTap: () {
              _terminalViewModel.setActiveTerminal(node.id);
            },
            child: Container(
              width: 200.w,
              margin: EdgeInsets.only(right: 10.w),
              decoration: BoxDecoration(
                color: AppColors.terminalBackground,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.borderColor,
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Title Bar
                  Container(
                    height: 24.h,
                    width: double.infinity,
                    color: isActive ? AppColors.primary : AppColors.surface,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            node.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                          onPressed: () {
                            _terminalViewModel.closeTerminal(node.id);
                          },
                        ),
                      ],
                    ),
                  ),
                  // Content (Disabled Terminal View for Thumbnail)
                  Expanded(
                    child: IgnorePointer(
                      child: Transform.scale(
                        scale: 0.8, // Simplified preview
                        child: TerminalView(
                          key: ValueKey('thumb_${node.id}'),
                          terminalNode: node,
                          interactive: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
