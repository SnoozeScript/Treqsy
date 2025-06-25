import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  final bool readOnly;
  final VoidCallback? onTap;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final Color? fillColor;
  final bool filled;
  final String? errorText;
  final String? helperText;
  final TextStyle? helperStyle;
  final String? initialValue;
  final TextAlign textAlign;
  final bool expands;
  final double? height;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.readOnly = false,
    this.onTap,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.fillColor = Colors.grey.shade100,
    this.filled = true,
    this.errorText,
    this.helperText,
    this.helperStyle,
    this.initialValue,
    this.textAlign = TextAlign.start,
    this.expands = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        validator: validator,
        enabled: enabled,
        maxLines: maxLines,
        maxLength: maxLength,
        autofocus: autofocus,
        focusNode: focusNode,
        textCapitalization: textCapitalization,
        readOnly: readOnly,
        onTap: onTap,
        initialValue: initialValue,
        textAlign: textAlign,
        expands: expands,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: enabled ? null : theme.hintColor,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefix,
          suffixIcon: suffix,
          contentPadding: contentPadding,
          border: border,
          enabledBorder: enabledBorder ?? border,
          focusedBorder: focusedBorder ??
              border.copyWith(
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
          errorBorder: errorBorder ??
              border.copyWith(
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1,
                ),
              ),
          focusedErrorBorder: focusedErrorBorder ??
              border.copyWith(
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 2,
                ),
              ),
          fillColor: fillColor,
          filled: filled,
          errorText: errorText,
          helperText: helperText,
          helperStyle: helperStyle ?? theme.textTheme.bodySmall,
          helperMaxLines: 2,
          errorMaxLines: 2,
          counterText: '',
        ),
      ),
    );
  }
}
