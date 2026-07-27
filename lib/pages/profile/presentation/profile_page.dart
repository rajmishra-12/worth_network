// lib/pages/dashboard/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/pages/profile/cubit/profile_cubit.dart';
import 'package:worth_network/pages/profile/presentation/action_history_tab.dart';
import 'package:worth_network/pages/profile/presentation/my_actions_tab.dart';
import 'package:worth_network/pages/profile/widgets/badge_section.dart';
import 'package:worth_network/pages/profile/widgets/profile_header.dart';
import 'package:worth_network/pages/profile/widgets/stats_card.dart';
import 'package:worth_network/pages/authentication/cubit/auth_cubit.dart';
import 'package:worth_network/core/navigator/app_pages.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ProfileCubit>().loadProfile();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.grey900,
        title: Text(
          'Log Out',
          style: CustomTextStyle.size18W600(color: AppColors.white100),
        ),
        content: Text(
          'Are you sure you want to log out of Worth Network?',
          style: CustomTextStyle.size14W400(color: AppColors.grey400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: CustomTextStyle.size14W500(color: AppColors.grey400),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
              context.go(Routes.loginScreen);
            },
            child: Text(
              'Log Out',
              style: CustomTextStyle.size14W600(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.isLoading && state.profile == null) {
            return const _LoadingState();
          }

          if (state.profile == null) {
            return const _ErrorState();
          }

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                // Top Action bar: Settings & Logout
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSize.paddingM, top: AppSize.paddingS),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings, color: AppColors.white100),
                          onPressed: () {
                            context.push('/settings');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: AppColors.error),
                          onPressed: () {
                            _showLogoutDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Profile Header
                SliverToBoxAdapter(
                  child: ProfileHeader(profile: state.profile!),
                ),
                
                // Stats Cards
                SliverToBoxAdapter(
                  child: StatsCard(
                    totalActions: state.profile!.totalActions,
                    validatedPercentage: state.profile!.validatedPercentage,
                    score: state.profile!.score,
                    level: state.profile!.level,
                    xp: state.profile!.xp,
                    nextLevelXp: state.profile!.nextLevelXp,
                  ),
                ),
                
                // Badges Section
                SliverToBoxAdapter(
                  child: BadgesSection(badges: state.profile!.badges),
                ),
                
                // Tab Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    tabController: _tabController,
                    tabs: const [
                      Tab(text: 'My Actions'),
                      Tab(text: 'History'),
                    ],
                  ),
                ),
                
                // Tab Bar Views
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      MyActionsTab(),
                      ActionHistoryTab(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final List<Tab> tabs;

  const _TabBarDelegate({
    required this.tabController,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: TabBar(
        controller: tabController,
        tabs: tabs,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey500,
        labelStyle: CustomTextStyle.size15W600(),
        unselectedLabelStyle: CustomTextStyle.size15W500(),
        padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.grey500,
          ),
          const SizedBox(height: AppSize.spacingM),
          Text(
            'Failed to load profile',
            style: CustomTextStyle.size16W500(color: AppColors.grey400),
          ),
          const SizedBox(height: AppSize.spacingL),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileCubit>().loadProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.black100,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}