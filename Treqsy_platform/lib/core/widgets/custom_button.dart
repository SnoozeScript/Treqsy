import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isOutlined;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 50,
    this.borderRadius = 12,
    this.padding,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: isOutlined
          ? Colors.transparent
          : (backgroundColor ?? theme.colorScheme.primary),
      foregroundColor: foregroundColor ?? Colors.white,
      minimumSize: Size(width ?? double.infinity, height),
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: isOutlined
            ? BorderSide(
                color: backgroundColor ?? theme.colorScheme.primary,
                width: 1.5,
              )
            : BorderSide.none,
      ),
      elevation: isOutlined ? 0 : 2,
      shadowColor: Colors.black12,
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: isOutlined
                    ? (backgroundColor ?? theme.colorScheme.primary)
                    : Colors.white,
                strokeWidth: 2,
              ),
            )
          : child,
    );
  }
}
