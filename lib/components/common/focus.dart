import 'package:flutter/material.dart';

class FocusWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const FocusWidget({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(padding: padding, child: child),
    );
  }
}
