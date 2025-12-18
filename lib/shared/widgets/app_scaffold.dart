import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors, Page;
import 'package:macos_ui/macos_ui.dart';
import 'package:window_manager/window_manager.dart';
import '../utils/platform_utils.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? titleBar;

  const AppScaffold({super.key, required this.body, this.titleBar});

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isWindows) {
      return NavigationView(
        appBar: const NavigationAppBar(
          title: DragToMoveArea(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Flutter Agent Panel'),
            ),
          ),
          actions: WindowCaption(
            brightness: Brightness.dark,
            backgroundColor: Colors.transparent,
          ),
          automaticallyImplyLeading: false,
        ),
        content: ScaffoldPage(content: body),
      );
    } else if (PlatformUtils.isMacOS) {
      return MacosScaffold(
        toolBar: titleBar != null ? ToolBar(title: titleBar!) : null,
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return body;
            },
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: titleBar != null ? AppBar(title: titleBar) : null,
        body: body,
      );
    }
  }
}
