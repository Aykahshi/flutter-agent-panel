import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../workspace/views/workspace_drawer.dart';
import '../../workspace/views/workspace_view.dart';
import '../../../shared/widgets/app_scaffold.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
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
    final theme = ShadTheme.of(context);

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
                      width: collapsed ? _collapsedWidth.w : width.w,
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
                            width: 2.w,
                            color: theme.colorScheme.border,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            // Main Content
            Expanded(
              child: const WorkspaceView(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper to listen to two ValueNotifiers
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;
  final Widget? child;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
    this.child,
  });

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
