import 'package:flutter/material.dart';

import '../../../features/terminal/models/terminal_node.dart';
import '../../../features/workspace/models/workspace.dart';

/// Callback for adding a new terminal to a workspace.
typedef AddTerminalCallback = void Function(
  BuildContext context,
  String workspaceId, {
  String? shellCmd,
  String? agentId,
});

/// Callback for updating terminal title.
typedef UpdateTitleCallback = void Function(
  TerminalNode node,
  Workspace workspace,
);

/// Callback for getting icon data from terminal and workspace.
typedef GetIconDataCallback = IconData Function(
  String terminalId,
  Workspace workspace,
);
