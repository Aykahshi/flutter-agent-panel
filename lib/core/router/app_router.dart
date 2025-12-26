import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../features/home/views/app_shell.dart';
import '../../features/workspace/views/workspace_wrapper_view.dart';
import '../../features/workspace/views/workspace_view.dart';
import '../../features/terminal/views/terminal_view.dart';

part 'app_router.gr.dart';

/// Main router configuration for the application.
/// Uses auto_route for type-safe navigation with nested routes.
@AutoRouterConfig(replaceInRouteName: 'View|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: AppShellRoute.page,
          path: '/',
          initial: true,
          children: [
            AutoRoute(
              page: WorkspaceWrapperRoute.page,
              path: 'workspace',
              initial: true,
              children: [
                AutoRoute(
                  page: WorkspaceRoute.page,
                  path: ':workspaceId',
                  children: [
                    AutoRoute(
                      page: TerminalRoute.page,
                      path: 'terminal/:terminalId',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ];

  @override
  List<AutoRouteGuard> get guards => [];
}
