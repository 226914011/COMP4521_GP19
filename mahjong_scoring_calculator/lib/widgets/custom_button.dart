import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double? width;
  final double? height;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final VoidCallback? onPressed;

  const CustomButton({
    super.key,
    required this.text,
    this.width,
    this.height,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return SizedBox(
      width: width ?? deviceSize.width * 0.1,
      height: height ?? deviceSize.height * 0.08,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.secondary,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? deviceSize.width * 0.05),
          ),
        ),
        onPressed: onPressed ?? () {},
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? Theme.of(context).colorScheme.onSecondary,
            fontSize: fontSize ?? 12,
          ),
        ),
      ),
    );
  }
}