// lib/core/ui/widgets/custom_button.dart
import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height = 48,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius = 12,
    this.padding,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null && !isLoading;

    Widget buttonChild() {
      if (isLoading) {
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getLoadingColor(theme, isDisabled),
            ),
          ),
        );
      } else if (icon != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(text, style: textStyle ?? _getTextStyle(theme, isDisabled)),
          ],
        );
      } else {
        return Text(text, style: textStyle ?? _getTextStyle(theme, isDisabled));
      }
    }

    Widget buttonContent = Container(
      height: height,
      width: isFullWidth ? double.infinity : width,
      padding: padding,
      child: Center(child: buttonChild()),
    );

    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getBackgroundColor(theme, isDisabled),
            foregroundColor: _getForegroundColor(theme, isDisabled),
            elevation: isDisabled ? 0 : 2,
            shadowColor: isDisabled ? Colors.transparent : null,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: buttonContent,
        );

      case ButtonType.secondary:
        return OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: _getForegroundColor(theme, isDisabled),
            backgroundColor:
                isDisabled ? Colors.grey.shade100 : Colors.transparent,
            side: BorderSide(
              color: _getBorderColor(theme, isDisabled),
              width: 1.5,
            ),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: buttonContent,
        );

      case ButtonType.text:
        return TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: _getForegroundColor(theme, isDisabled),
            backgroundColor:
                isDisabled ? Colors.transparent : Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: buttonContent,
        );
    }
  }

  TextStyle _getTextStyle(ThemeData theme, bool isDisabled) {
    Color color;

    if (textColor != null && !isDisabled) {
      color = textColor!;
    } else {
      switch (type) {
        case ButtonType.primary:
          color = isDisabled ? Colors.grey.shade500 : Colors.white;
          break;
        case ButtonType.secondary:
        case ButtonType.text:
          color = isDisabled ? Colors.grey.shade400 : theme.primaryColor;
          break;
      }
    }

    return theme.textTheme.labelLarge!.copyWith(
      color: color,
      fontWeight: FontWeight.w600,
    );
  }

  Color _getForegroundColor(ThemeData theme, bool isDisabled) {
    if (textColor != null && !isDisabled) {
      return textColor!;
    }

    switch (type) {
      case ButtonType.primary:
        return isDisabled ? Colors.grey.shade500 : Colors.white;
      case ButtonType.secondary:
      case ButtonType.text:
        return isDisabled ? Colors.grey.shade400 : theme.primaryColor;
    }
  }

  Color _getBackgroundColor(ThemeData theme, bool isDisabled) {
    if (backgroundColor != null && !isDisabled) {
      return backgroundColor!;
    }

    switch (type) {
      case ButtonType.primary:
        return isDisabled ? Colors.grey.shade300 : theme.primaryColor;
      case ButtonType.secondary:
        return isDisabled ? Colors.grey.shade100 : Colors.transparent;
      case ButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getBorderColor(ThemeData theme, bool isDisabled) {
    if (borderColor != null && !isDisabled) {
      return borderColor!;
    }

    return isDisabled ? Colors.grey.shade300 : theme.primaryColor;
  }

  Color _getLoadingColor(ThemeData theme, bool isDisabled) {
    switch (type) {
      case ButtonType.primary:
        return isDisabled ? Colors.grey.shade500 : Colors.white;
      case ButtonType.secondary:
      case ButtonType.text:
        return isDisabled ? Colors.grey.shade400 : theme.primaryColor;
    }
  }
}

