import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/components/common/common_background.dart';
import 'package:worth_network/core/constants/app_images.dart';
import 'package:worth_network/core/navigator/app_pages.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:worth_network/core/utils/preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, 0.7), // starts below the screen
      end: const Offset(0, 0), // ends at center
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      final isLoggedIn = Preferences().isLoggedIn && FirebaseAuth.instance.currentUser != null;
      if (isLoggedIn) {
        Pages.appRouter.go(Routes.dashBoardScreen);
      } else {
        Pages.appRouter.go(Routes.welcomeScreenPage);
      }
    });
  }

  // void _checkAuthAndNavigate() async {
  //   await Future.delayed(const Duration(seconds: 2)); // splash delay

  //   final authCubit = context.read<AuthCubit>();

  //   // ✅ Check network first
  //   final isConnected = await authCubit.repository.isConnected();

  //   if (!isConnected) {
  //     Pages.appRouter.go(Routes.offlinescreen);
  //     return;
  //   }

  //   // ✅ Then check login state
  //   authCubit.checkAuthStatus();
  //   final isLoggedIn = authCubit.state.isLoggedIn;

  //   if (isLoggedIn) {
  //     Pages.appRouter.go(Routes.dashBoardScreen);
  //   } else {
  //     Pages.appRouter.go(Routes.welcomeScreenPage);
  //   }
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
    
      showSafeArea: false,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: AppColors.black100),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SlideTransition(
              position: _animation,
              child: Image.asset(
                AppIcons.appLogo,
                height: 350.heightMultiplier,
                width: 350.widthMultiplier,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
