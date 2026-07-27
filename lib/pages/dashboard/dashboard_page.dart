// lib/pages/dashboard/dashboard_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/pages/dashboard/cubit/dashboard_cubit.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.child, required this.routerState});
  final Widget? child;
  final GoRouterState routerState;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    final cubit = context.read<DashboardCubit>();
    if (cubit.state.pages.isEmpty) {
      cubit.initializePages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.pages.isEmpty) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
        }

        return Scaffold(
          body: state.pages[state.currentIndex],
          bottomNavigationBar: !kIsWeb
              ? Container(
                  decoration: BoxDecoration(
                     color: AppColors.grey900,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSize.radiusL),
                      topRight: Radius.circular(AppSize.radiusL),
                    ),
                    child: BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: AppColors.grey900,
                      selectedItemColor: AppColors.primary,
                      unselectedItemColor: AppColors.grey500,
                      selectedLabelStyle: CustomTextStyle.size11W500(
                        color: AppColors.primary,
                      ),
                      unselectedLabelStyle: CustomTextStyle.size11W400(
                        color: AppColors.grey500,
                      ),
                      currentIndex: state.currentIndex,
                      onTap: (index) {
                        context.read<DashboardCubit>().changeTab(index);
                      },
                      elevation: 0,
                      showSelectedLabels: true,
                      showUnselectedLabels: true,
                      iconSize: 24,
                      items: _buildNavItems(),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.search_outlined),
        activeIcon: Icon(Icons.search_rounded),
        label: 'Network',
      ),
      BottomNavigationBarItem(
        icon: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.add,
              color: AppColors.black100,
              size: 24,
            ),
          ),
        ),
        activeIcon: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.add,
              color: AppColors.black100,
              size: 24,
            ),
          ),
        ),
        label: 'Action',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person_rounded),
        label: 'Profile',
      ),
    ];
  }
}