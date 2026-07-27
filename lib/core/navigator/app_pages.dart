import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:worth_network/core/global_keys.dart';
import 'package:worth_network/pages/authentication/presentation/sign_in_page.dart';
import 'package:worth_network/pages/authentication/presentation/sign_up_page.dart';
import 'package:worth_network/pages/dashboard/dashboard_page.dart';
import 'package:worth_network/pages/onboarding_pages.dart/splash_page.dart';
import 'package:worth_network/pages/onboarding_pages.dart/welcome_page.dart';
import 'package:worth_network/pages/authentication/presentation/profile_setup_page.dart';
import 'package:worth_network/pages/action/presentation/action_details_page.dart';
import 'package:worth_network/pages/action/presentation/validation_request_page.dart';
import 'package:worth_network/pages/home/presentation/notifications_page.dart';
import 'package:worth_network/pages/profile/presentation/settings_page.dart';
import 'package:worth_network/pages/authentication/presentation/forget_password_page.dart';
import 'package:worth_network/core/model/home/action_model.dart';

part 'app_router.dart';

class Pages {
  static GoRouter get appRouter => _appRouter;

  static final GoRouter _appRouter = GoRouter(
    initialLocation: Routes.splashPage,
    navigatorKey: GlobalKeys.navigatorKey,
    routes: [
      GoRoute(
        path: Routes.splashPage,
        name: Routes.splashPage,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: Routes.welcomeScreenPage,
        name: Routes.welcomeScreenPage,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.loginScreen,
        name: Routes.loginScreen,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.dashBoardScreen,
        name: Routes.dashBoardScreen,
        builder: (context, state) => DashboardScreen(routerState: state),
      ),
      GoRoute(
        path: Routes.signupScreen,
        name: Routes.signupScreen,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: Routes.profilesetup,
        name: Routes.profilesetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: Routes.forgetPasswordScreen,
        name: Routes.forgetPasswordScreen,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/action-details',
        name: 'action-details',
        builder: (context, state) {
          final action = state.extra as ActionModel;
          return ActionDetailsScreen(action: action);
        },
      ),
      GoRoute(
        path: '/validation-request',
        name: 'validation-request',
        builder: (context, state) {
          final action = state.extra as ActionModel;
          return ValidationRequestScreen(action: action);
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

