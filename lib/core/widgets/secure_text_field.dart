import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Secure text field with optional masking for sensitive data
class SecureTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool isSensitive;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final bool autofocus;

  const SecureTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.isSensitive = false,
    this.prefixIcon,
    this.suffix,
    this.enabled = true,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
  });

  @override
  State<SecureTextField> createState() => _SecureTextFieldState();
}

class _SecureTextFieldState extends State<SecureTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.isSensitive;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      obscureText: _obscured,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      textCapitalization: widget.textCapitalization,
      autofocus: widget.autofocus,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        letterSpacing: 0.3,
      ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        counterText: '',
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 20)
            : null,
        suffixIcon: widget.isSensitive
            ? IconButton(
                icon: Icon(
                  _obscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : widget.suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: widget.suffix,
                  )
                : null,
      ),
    );
  }
}
