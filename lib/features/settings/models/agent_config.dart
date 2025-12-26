import 'package:equatable/equatable.dart';

import '../../../core/constants/assets.dart';

enum AgentPreset {
  claude,
  qwen,
  codex,
  gemini,
  opencode,
  githubCopilot,
  custom,
}

extension AgentPresetX on AgentPreset {
  String get displayName => switch (this) {
        AgentPreset.claude => 'Claude Code',
        AgentPreset.qwen => 'Qwen Code',
        AgentPreset.codex => 'Codex CLI',
        AgentPreset.gemini => 'Gemini CLI',
        AgentPreset.opencode => 'OpenCode',
        AgentPreset.githubCopilot => 'Github Copilot',
        AgentPreset.custom => 'Custom',
      };

  String get defaultCommand => switch (this) {
        AgentPreset.claude => 'claude',
        AgentPreset.qwen => 'qwen',
        AgentPreset.codex => 'codex',
        AgentPreset.gemini => 'gemini',
        AgentPreset.opencode => 'opencode',
        AgentPreset.githubCopilot => 'copilot',
        AgentPreset.custom => '',
      };

  String get defaultInstallCommand => switch (this) {
        AgentPreset.claude => 'npm install -g @anthropic-ai/claude-code',
        AgentPreset.qwen => 'npm install -g @qwen-code/qwen-code',
        AgentPreset.codex => 'npm i -g @openai/codex',
        AgentPreset.gemini => 'npm install -g @google/gemini-cli',
        AgentPreset.opencode => 'npm install -g opencode-ai',
        AgentPreset.githubCopilot => 'npm install -g @github/copilot',
        AgentPreset.custom => '',
      };

  String? get iconAssetPath => switch (this) {
        AgentPreset.claude => Assets.claudeLogo,
        AgentPreset.qwen => Assets.qwenLogo,
        AgentPreset.codex => Assets.chatgptLogo,
        AgentPreset.gemini => Assets.geminiLogo,
        AgentPreset.opencode => Assets.opencodeLogo,
        AgentPreset.githubCopilot => Assets.githubCopilotLogo,
        AgentPreset.custom => null,
      };

  List<String> get defaultArgs => switch (this) {
        AgentPreset.githubCopilot => ['--banner'],
        _ => const [],
      };
}

class AgentConfig extends Equatable {
  const AgentConfig({
    required this.id,
    required this.preset,
    required this.name,
    required this.command,
    this.args = const [],
    this.env = const {},
    this.enabled =
        false, // Default disabled as per typical "toggle" logic? User said "toggle switch... test when on".
    this.customIconPath,
    this.customTextColor,
    this.shellId,
  });

  factory AgentConfig.fromJson(Map<String, dynamic> json) {
    return AgentConfig(
      id: json['id'] as String,
      preset: AgentPreset.values.firstWhere(
        (e) => e.name == json['preset'],
        orElse: () => AgentPreset.custom,
      ),
      name: json['name'] as String,
      command: json['command'] as String,
      args:
          (json['args'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      env: (json['env'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as String),
          ) ??
          const {},
      enabled: json['enabled'] as bool? ?? false,
      customIconPath: json['customIconPath'] as String?,
      customTextColor: json['customTextColor'] as String?,
      shellId: json['shellId'] as String?,
    );
  }
  final String id;
  final AgentPreset preset;
  final String name;
  final String command;
  final List<String> args;
  final Map<String, String> env;
  final bool enabled;
  final String? customIconPath;
  // If user sets a custom text color, we store the hex code
  final String? customTextColor;
  // Shell ID: null = default (pwsh), 'pwsh7'/'gitBash'/etc for ShellType, or custom shell UUID
  final String? shellId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'preset': preset.name,
      'name': name,
      'command': command,
      'args': args,
      'env': env,
      'enabled': enabled,
      'customIconPath': customIconPath,
      'customTextColor': customTextColor,
      'shellId': shellId,
    };
  }

  AgentConfig copyWith({
    String? id,
    AgentPreset? preset,
    String? name,
    String? command,
    List<String>? args,
    Map<String, String>? env,
    bool? enabled,
    String? customIconPath,
    String? customTextColor,
    String? shellId,
    bool clearShellId = false,
  }) {
    return AgentConfig(
      id: id ?? this.id,
      preset: preset ?? this.preset,
      name: name ?? this.name,
      command: command ?? this.command,
      args: args ?? this.args,
      env: env ?? this.env,
      enabled: enabled ?? this.enabled,
      customIconPath: customIconPath ?? this.customIconPath,
      customTextColor: customTextColor ?? this.customTextColor,
      shellId: clearShellId ? null : (shellId ?? this.shellId),
    );
  }

  @override
  List<Object?> get props => [
        id,
        preset,
        name,
        command,
        args,
        env,
        enabled,
        customIconPath,
        customTextColor,
        shellId,
      ];
}
