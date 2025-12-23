import 'package:auto_route/auto_route.dart';

import '../../features/home/views/app_shell.dart';

part 'app_router.gr.dart';

/// Main router configuration for the application.
/// Uses auto_route for type-safe navigation.
@AutoRouterConfig(replaceInRouteName: 'View,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: AppShellRoute.page, initial: true),
      ];

  @override
  List<AutoRouteGuard> get guards => [];
}
