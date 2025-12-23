import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/terminal_node.dart';

class GlowingIcon extends StatefulWidget {
  const GlowingIcon({
    super.key,
    this.icon,
    this.svgPath,
    required this.status,
    this.size = 16.0,
    this.baseColor,
  }) : assert(
          icon != null || svgPath != null,
          'Either icon or svgPath must be provided',
        );
  final IconData? icon;
  final String? svgPath;
  final TerminalStatus status;
  final double size;
  final Color? baseColor;

  @override
  State<GlowingIcon> createState() => _GlowingIconState();
}

class _GlowingIconState extends State<GlowingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.status == TerminalStatus.running ||
        widget.status == TerminalStatus.restarting) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlowingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == TerminalStatus.running ||
        widget.status == TerminalStatus.restarting) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If baseColor is provided, use it (e.g. for disconnected/idle if we want specific overrides),
    // otherwise fallback to status color logic
    final statusColor = _getStatusColor(widget.status);
    final color = widget.baseColor ?? statusColor;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final isAnimating = widget.status == TerminalStatus.running ||
            widget.status == TerminalStatus.restarting;

        final opacity = isAnimating ? _glowAnimation.value : 1.0;

        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              if (widget.status != TerminalStatus.disconnected)
                BoxShadow(
                  color: statusColor.withValues(alpha: opacity * 0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: widget.svgPath != null
              ? SvgPicture.asset(
                  widget.svgPath!,
                  width: widget.size,
                  height: widget.size,
                  colorFilter: ColorFilter.mode(
                    color.withValues(alpha: opacity),
                    BlendMode.srcIn,
                  ),
                )
              : Icon(
                  widget.icon,
                  size: widget.size,
                  color: color.withValues(alpha: opacity),
                ),
        );
      },
    );
  }

  Color _getStatusColor(TerminalStatus status) => switch (status) {
        TerminalStatus.running => Colors.orangeAccent,
        TerminalStatus.idle => Colors.greenAccent,
        TerminalStatus.error => Colors.redAccent,
        TerminalStatus.disconnected => Colors.grey.shade600,
        TerminalStatus.restarting => Colors.blueAccent,
      };
}
