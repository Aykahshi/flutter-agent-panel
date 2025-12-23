import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../workspace/views/workspace_drawer.dart';
import '../../workspace/views/workspace_view.dart';
import '../../../shared/widgets/app_scaffold.dart';

@RoutePage()
class AppShellView extends StatefulWidget {
  const AppShellView({super.key});

  @override
  State<AppShellView> createState() => _AppShellViewState();
}

class _AppShellViewState extends State<AppShellView> {
  static const double _minExpandedWidth = 150.0;
  static const double _collapsedWidth = 50.0;
  final ValueNotifier<double> _drawerWidth = ValueNotifier(200.0);
  final ValueNotifier<bool> _isCollapsed = ValueNotifier(false);

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

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return AppScaffold(
      body: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
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
                      ),
                    ),
                    // Resize Handle
                    if (!collapsed)
                      GestureDetector(
                        onPanUpdate: (details) {
                          final newWidth =
                              _drawerWidth.value + details.delta.dx;
                          if (newWidth < _minExpandedWidth) {
                            // Optionally snap to collapsed if dragged far enough
                            if (newWidth < _minExpandedWidth - 30) {
                              _isCollapsed.value = true;
                              _drawerWidth.value = _collapsedWidth;
                            }
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
            // Main Content
            const Expanded(
              child: WorkspaceView(),
            ),
          ],
        ),
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
