import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum _AppButtonType { primary, outlined, text }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final bool isDanger;
  final IconData? icon;
  final double? width;
  final _AppButtonType _type;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.isDanger = false,
    this.icon,
    this.width,
  }) : _type = _AppButtonType.primary;

  const AppButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.isDanger = false,
    this.icon,
    this.width,
  }) : _type = _AppButtonType.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.isDanger = false,
    this.icon,
    this.width,
  }) : _type = _AppButtonType.text;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.isDisabled || widget.isLoading || widget.onPressed == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isDisabled || widget.isLoading || widget.onPressed == null) return;
    setState(() => _isPressed = false);
    widget.onPressed!();
  }

  void _handleTapCancel() {
    if (_isPressed) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool effectiveDisabled = widget.isDisabled || widget.isLoading || widget.onPressed == null;

    Widget buttonContent;
    if (widget.isLoading) {
      buttonContent = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(widget.label),
        ],
      );
    }

    Widget buttonWidget;
    switch (widget._type) {
      case _AppButtonType.primary:
        buttonWidget = ElevatedButton(
          onPressed: null, // Handled by GestureDetector
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isDanger ? AppColors.error : AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: widget.isDanger ? AppColors.error : AppColors.primary,
            disabledForegroundColor: Colors.white,
          ),
          child: buttonContent,
        );
        break;
      case _AppButtonType.outlined:
        buttonWidget = OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            foregroundColor: widget.isDanger ? AppColors.error : AppColors.primary,
            side: BorderSide(
              color: widget.isDanger ? AppColors.error : AppColors.primary,
              width: 1.5,
            ),
            disabledForegroundColor: widget.isDanger ? AppColors.error : AppColors.primary,
          ),
          child: buttonContent,
        );
        break;
      case _AppButtonType.text:
        buttonWidget = TextButton(
          onPressed: null,
          style: TextButton.styleFrom(
            foregroundColor: widget.isDanger ? AppColors.error : AppColors.primary,
            disabledForegroundColor: widget.isDanger ? AppColors.error : AppColors.primary,
          ),
          child: buttonContent,
        );
        break;
    }

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Opacity(
        opacity: effectiveDisabled ? 0.5 : 1.0,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: widget.width ?? double.infinity,
            height: 54,
            child: IgnorePointer(
              ignoring: true, // Let GestureDetector handle taps
              child: buttonWidget,
            ),
          ),
        ),
      ),
    );
  }
}
