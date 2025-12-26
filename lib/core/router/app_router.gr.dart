// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AppShellView]
class AppShellRoute extends PageRouteInfo<void> {
  const AppShellRoute({List<PageRouteInfo>? children})
    : super(AppShellRoute.name, initialChildren: children);

  static const String name = 'AppShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AppShellView();
    },
  );
}

/// generated route for
/// [TerminalView]
class TerminalRoute extends PageRouteInfo<TerminalRouteArgs> {
  TerminalRoute({
    Key? key,
    required String terminalId,
    List<PageRouteInfo>? children,
  }) : super(
         TerminalRoute.name,
         args: TerminalRouteArgs(key: key, terminalId: terminalId),
         rawPathParams: {'terminalId': terminalId},
         initialChildren: children,
       );

  static const String name = 'TerminalRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<TerminalRouteArgs>(
        orElse: () =>
            TerminalRouteArgs(terminalId: pathParams.getString('terminalId')),
      );
      return TerminalView(key: args.key, terminalId: args.terminalId);
    },
  );
}

class TerminalRouteArgs {
  const TerminalRouteArgs({this.key, required this.terminalId});

  final Key? key;

  final String terminalId;

  @override
  String toString() {
    return 'TerminalRouteArgs{key: $key, terminalId: $terminalId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TerminalRouteArgs) return false;
    return key == other.key && terminalId == other.terminalId;
  }

  @override
  int get hashCode => key.hashCode ^ terminalId.hashCode;
}

/// generated route for
/// [WorkspaceView]
class WorkspaceRoute extends PageRouteInfo<WorkspaceRouteArgs> {
  WorkspaceRoute({
    Key? key,
    required String workspaceId,
    List<PageRouteInfo>? children,
  }) : super(
         WorkspaceRoute.name,
         args: WorkspaceRouteArgs(key: key, workspaceId: workspaceId),
         rawPathParams: {'workspaceId': workspaceId},
         initialChildren: children,
       );

  static const String name = 'WorkspaceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<WorkspaceRouteArgs>(
        orElse: () => WorkspaceRouteArgs(
          workspaceId: pathParams.getString('workspaceId'),
        ),
      );
      return WorkspaceView(key: args.key, workspaceId: args.workspaceId);
    },
  );
}

class WorkspaceRouteArgs {
  const WorkspaceRouteArgs({this.key, required this.workspaceId});

  final Key? key;

  final String workspaceId;

  @override
  String toString() {
    return 'WorkspaceRouteArgs{key: $key, workspaceId: $workspaceId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkspaceRouteArgs) return false;
    return key == other.key && workspaceId == other.workspaceId;
  }

  @override
  int get hashCode => key.hashCode ^ workspaceId.hashCode;
}

/// generated route for
/// [WorkspaceWrapperView]
class WorkspaceWrapperRoute extends PageRouteInfo<void> {
  const WorkspaceWrapperRoute({List<PageRouteInfo>? children})
    : super(WorkspaceWrapperRoute.name, initialChildren: children);

  static const String name = 'WorkspaceWrapperRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WorkspaceWrapperView();
    },
  );
}
