import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/router/app_router.dart';
import '../bloc/workspace_bloc.dart';
import 'workspace_drawer.dart';

/// Wrapper view that contains the workspace drawer and nested router outlet.
/// This handles the sidebar layout and drawer resize functionality.
@RoutePage()
class WorkspaceWrapperView extends StatefulWidget {
  const WorkspaceWrapperView({super.key});

  @override
  State<WorkspaceWrapperView> createState() => _WorkspaceWrapperViewState();
}

class _WorkspaceWrapperViewState extends State<WorkspaceWrapperView> {
  static const double _minExpandedWidth = 150.0;
  static const double _collapsedWidth = 50.0;
  final ValueNotifier<double> _drawerWidth = ValueNotifier(200.0);
  final ValueNotifier<bool> _isCollapsed = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    // Navigate to selected workspace on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToSelectedWorkspace();
    });
  }

  @override
  void dispose() {
    _drawerWidth.dispose();
    _isCollapsed.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    if (_isCollapsed.value) {
      _isCollapsed.value = false;
      _drawerWidth.value = 200.0;
    } else {
      _isCollapsed.value = true;
      _drawerWidth.value = _collapsedWidth;
    }
  }

  void _navigateToSelectedWorkspace() {
    final state = context.read<WorkspaceBloc>().state;
    if (state.selectedWorkspaceId != null) {
      context.router.navigate(
        WorkspaceRoute(workspaceId: state.selectedWorkspaceId!),
      );
    }
  }

  void _onWorkspaceSelected(String workspaceId) {
    if (context.router.current.pathParams.get('workspaceId') == workspaceId) {
      return;
    }
    context.read<WorkspaceBloc>().add(SelectWorkspace(workspaceId));
    context.router.navigate(WorkspaceRoute(workspaceId: workspaceId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return BlocListener<WorkspaceBloc, WorkspaceState>(
      listenWhen: (previous, current) =>
          previous.selectedWorkspaceId != current.selectedWorkspaceId,
      listener: (context, state) {
        if (state.selectedWorkspaceId != null) {
          context.router.navigate(
            WorkspaceRoute(workspaceId: state.selectedWorkspaceId!),
          );
        }
      },
      child: Row(
        children: [
          // Collapsible & Resizable Drawer
          ValueListenableBuilder2<double, bool>(
            first: _drawerWidth,
            second: _isCollapsed,
            builder: (context, width, collapsed, _) {
              return Row(
                children: [
                  SizedBox(
                    width: collapsed ? _collapsedWidth : width,
                    child: WorkspaceDrawer(
                      isCollapsed: collapsed,
                      onToggle: _toggleDrawer,
                      onWorkspaceSelected: _onWorkspaceSelected,
                    ),
                  ),
                  // Resize Handle
                  if (!collapsed)
                    GestureDetector(
                      onPanUpdate: (details) {
                        final newWidth = _drawerWidth.value + details.delta.dx;
                        if (newWidth < _minExpandedWidth) {
                          // Snap to collapsed if dragged far enough
                          if (newWidth < _minExpandedWidth - 30) {
                            _isCollapsed.value = true;
                            _drawerWidth.value = _collapsedWidth;
                          }
                        } else if (newWidth > 500) {
                          _drawerWidth.value = 500;
                        } else {
                          _drawerWidth.value = newWidth;
                        }
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeLeftRight,
                        child: Container(
                          width: 2,
                          color: theme.colorScheme.border,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Nested Router Outlet
          const Expanded(child: AutoRouter()),
        ],
      ),
    );
  }
}

/// Helper to listen to two ValueNotifiers
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
    this.child,
  });
  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (context, a, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, _) {
            return builder(context, a, b, child);
          },
        );
      },
    );
  }
}
