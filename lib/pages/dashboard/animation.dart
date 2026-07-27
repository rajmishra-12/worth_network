// lib/pages/dashboard/dashboard_screen_animated.dart (Alternative with curved shape)
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/pages/dashboard/cubit/dashboard_cubit.dart';

class DashboardScreenAnimated extends StatefulWidget {
  const DashboardScreenAnimated({super.key, this.child, required this.routerState});
  final Widget? child;
  final GoRouterState routerState;

  @override
  State<DashboardScreenAnimated> createState() => _DashboardScreenAnimatedState();
}

class _DashboardScreenAnimatedState extends State<DashboardScreenAnimated> {
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
          extendBody: true,
          body: state.pages[state.currentIndex],
          bottomNavigationBar: !kIsWeb
              ? Container(
                  margin: const EdgeInsets.only(
                    left: AppSize.paddingM,
                    right: AppSize.paddingM,
                    bottom: AppSize.paddingM,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.radiusXL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSize.radiusXL),
                    child: BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: AppColors.grey900.withValues(alpha: 0.95),
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
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            color: AppColors.black100,
            size: 22,
          ),
        ),
        activeIcon: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            color: AppColors.black100,
            size: 22,
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