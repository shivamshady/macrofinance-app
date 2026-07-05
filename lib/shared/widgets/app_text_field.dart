import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

enum _AppTextFieldType { generic, phone, amount, pan, password }

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final IconData? prefix;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  final _AppTextFieldType _type;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.prefix,
    this.onChanged,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
  }) : _type = _AppTextFieldType.generic;

  const AppTextField.phone({
    super.key,
    this.label = 'Phone Number',
    this.controller,
    this.onChanged,
    this.validator,
  })  : _type = _AppTextFieldType.phone,
        hint = 'Enter 10 digit number',
        prefix = Icons.phone_android,
        maxLength = 10,
        textCapitalization = TextCapitalization.none,
        keyboardType = TextInputType.number;

  const AppTextField.amount({
    super.key,
    this.label = 'Amount',
    this.hint = 'Enter amount',
    this.controller,
    this.onChanged,
    this.validator,
  })  : _type = _AppTextFieldType.amount,
        prefix = Icons.currency_rupee,
        maxLength = null,
        textCapitalization = TextCapitalization.none,
        keyboardType = const TextInputType.numberWithOptions(decimal: true);

  const AppTextField.pan({
    super.key,
    this.controller,
    this.onChanged,
    this.validator,
  })  : _type = _AppTextFieldType.pan,
        label = 'PAN Number',
        hint = 'ABCDE1234F',
        prefix = Icons.badge_outlined,
        maxLength = 10,
        textCapitalization = TextCapitalization.characters,
        keyboardType = TextInputType.text;

  const AppTextField.password({
    super.key,
    this.label = 'MPIN',
    this.hint = 'Enter MPIN',
    this.controller,
    this.onChanged,
    this.validator,
    this.maxLength = 4,
    this.prefix = Icons.lock_outline,
  })  : _type = _AppTextFieldType.password,
        textCapitalization = TextCapitalization.none,
        keyboardType = TextInputType.number;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = false;
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _internalController = widget.controller ?? TextEditingController();
    _internalController.addListener(_handleTextChange);
    if (widget._type == _AppTextFieldType.password) {
      _obscureText = true;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    if (widget.controller == null) {
      _internalController.dispose();
    } else {
      _internalController.removeListener(_handleTextChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleTextChange() {
    if (mounted) setState(() {});
  }

  List<TextInputFormatter> _getFormatters() {
    List<TextInputFormatter> formatters = [];
    if (widget.maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(widget.maxLength));
    }
    if (widget._type == _AppTextFieldType.phone || widget._type == _AppTextFieldType.password) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (widget._type == _AppTextFieldType.amount) {
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')));
      // Basic comma formatter could be added here, but avoiding complex logic for now
      // to keep it simple. Usually requires tracking selection offset.
    }
    if (widget._type == _AppTextFieldType.pan) {
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')));
      formatters.add(TextInputFormatter.withFunction((oldValue, newValue) {
        return TextEditingValue(
          text: newValue.text.toUpperCase(),
          selection: newValue.selection,
        );
      }));
    }
    return formatters;
  }

  Widget? _buildPrefix() {
    if (widget._type == _AppTextFieldType.phone) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 8, top: 15, bottom: 15),
        child: Text(
          '+91',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      );
    }
    if (widget._type == _AppTextFieldType.amount) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 8, top: 15, bottom: 15),
        child: Text(
          '₹',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      );
    }
    if (widget.prefix != null) {
      return Icon(
        widget.prefix,
        color: _isFocused ? AppColors.primary : AppColors.textHint,
      );
    }
    return null;
  }

  Widget? _buildSuffix() {
    if (widget._type == _AppTextFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textHint,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (_isFocused && _internalController.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.clear, color: AppColors.textHint, size: 20),
        onPressed: () {
          _internalController.clear();
          if (widget.onChanged != null) widget.onChanged!('');
        },
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _internalController,
      focusNode: _focusNode,
      obscureText: _obscureText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      inputFormatters: _getFormatters(),
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefix != null && widget._type != _AppTextFieldType.phone && widget._type != _AppTextFieldType.amount
            ? Icon(
                widget.prefix,
                color: _isFocused ? AppColors.primary : AppColors.textHint,
              )
            : null,
        prefix: _buildPrefix(),
        suffixIcon: _buildSuffix(),
      ),
    );
  }
}
