import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';

/// Application shell that provides the main scaffold and router outlet.
@RoutePage()
class AppShellView extends StatelessWidget {
  const AppShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: AutoRouter(),
    );
  }
}
