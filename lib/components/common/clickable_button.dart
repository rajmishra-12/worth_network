import 'package:flutter/material.dart';

class ClickableButton extends StatelessWidget {
  const ClickableButton({
    super.key,
    required this.onTap,
    required this.child,
    this.borderRadius,
  });

  final VoidCallback? onTap;
  final Widget child;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: borderRadius,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: child,
    );
  }
}
