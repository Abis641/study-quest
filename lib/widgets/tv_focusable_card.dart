// lib/widgets/tv_focusable_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_theme.dart';

class TVFocusableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool autofocus;

  const TVFocusableCard({
    super.key,
    required this.child,
    this.onTap,
    this.focusNode,
    this.width,
    this.height,
    this.backgroundColor,
    this.gradient,
    this.borderRadius,
    this.padding,
    this.autofocus = false,
  });

  @override
  State<TVFocusableCard> createState() => _TVFocusableCardState();
}

class _TVFocusableCardState extends State<TVFocusableCard> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChanged);
    }
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space)) {
          setState(() => _isPressed = true);
          widget.onTap?.call();
          return KeyEventResult.handled;
        }
        if (event is KeyUpEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space)) {
          setState(() => _isPressed = false);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          height: widget.height,
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.96 : _isFocused ? 1.04 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.gradient == null
                ? (widget.backgroundColor ?? AppTheme.cardBase)
                : null,
            gradient: widget.gradient,
            borderRadius:
                widget.borderRadius ?? BorderRadius.circular(20),
            border: _isFocused
                ? Border.all(
                    color: AppTheme.focusBorder,
                    width: TVSizes.focusBorderWidth,
                  )
                : Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.focusBorder.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(20),
            child: widget.child,
          ),
        ),
      ),
    ).animate(target: _isFocused ? 1 : 0);
  }
}

// ── TV Button ────────────────────────────────────────────────────────────

class TVButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool autofocus;
  final FocusNode? focusNode;
  final double? width;

  const TVButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.autofocus = false,
    this.focusNode,
    this.width,
  });

  @override
  State<TVButton> createState() => _TVButtonState();
}

class _TVButtonState extends State<TVButton> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.primary;
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onPressed?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          height: TVSizes.buttonHeight,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: _isFocused ? color : color.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            border: _isFocused
                ? Border.all(color: Colors.white, width: 2)
                : null,
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.6),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
              ],
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
