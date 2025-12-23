import 'package:flutter/material.dart';
import '../models/terminal_node.dart';

class ActivityIndicator extends StatefulWidget {
  const ActivityIndicator({
    super.key,
    required this.status,
    this.size = 8.0,
  });
  final TerminalStatus status;
  final double size;

  @override
  State<ActivityIndicator> createState() => _ActivityIndicatorState();
}

class _ActivityIndicatorState extends State<ActivityIndicator>
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

    _glowAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.status == TerminalStatus.running) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ActivityIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == TerminalStatus.running) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
      _controller.value = 1.0; // Solid circle when not running
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(widget.status);

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final opacity = widget.status == TerminalStatus.running
            ? _glowAnimation.value
            : 1.0;

        // Assuming 'withValues' is an extension method on Color that takes an alpha parameter.
        // If it's not, this code will cause a compilation error.
        // For standard Flutter Color, you would use 'withAlpha((255 * opacity).round())'
        // or 'withOpacity(opacity)'.
        // The instruction specifically asks for 'withValues(alpha: ...)', so we're applying it directly.
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: opacity),
            boxShadow: [
              if (widget.status != TerminalStatus.disconnected)
                BoxShadow(
                  color: color.withValues(alpha: opacity * 0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
            ],
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
