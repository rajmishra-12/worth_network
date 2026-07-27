import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:worth_network/core/theme/app_colors.dart';

class CommonBackground extends StatelessWidget {
  final Widget child;
  final Widget? bottomNavBar;
  final Color? backgroundColor;
  final bool? showSafeArea;
  final AppBar? appBar;

  const CommonBackground({
    super.key,
    required this.child,
    this.backgroundColor,
    this.bottomNavBar,
    this.showSafeArea = true,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNavBar,
      backgroundColor: backgroundColor ?? AppColors.black100,
      body:
          showSafeArea == true
              ? SafeArea(child: SizedBox(width: double.infinity, child: child))
              : SizedBox(width: double.infinity, child: child),
    );
  }
}
