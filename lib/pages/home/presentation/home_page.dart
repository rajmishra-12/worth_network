import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:worth_network/components/common/language_toggle_button.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/core/repo/action_repo.dart';
import 'package:worth_network/pages/dashboard/cubit/dashboard_cubit.dart';
import 'package:worth_network/pages/home/cubit/home_cubit.dart';
import 'package:worth_network/pages/home/widgets/action_cards.dart';
import 'package:worth_network/pages/home/widgets/empty_feed_widget.dart';


import 'package:worth_network/pages/home/widgets/empty_following_feed_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadFeed();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 300) {
      final cubit = context.read<HomeCubit>();
      if (cubit.state.currentTab == HomeFeedTab.forYou) {
        cubit.loadMoreForYouFeed();
      } else {
        cubit.loadMoreFollowingFeed();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<HomeCubit>().loadFeed();
              },
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  final isMoreLoading = state.currentTab == HomeFeedTab.forYou
                      ? state.isLoadingMore
                      : state.isFollowingLoadingMore;

                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Top Bar
                      SliverToBoxAdapter(child: _buildTopBar(context, loc)),
                      // Feed Tab Selector (For You vs Following)
                      SliverToBoxAdapter(child: _buildFeedTabSelector(context, state, loc)),
                      const SliverToBoxAdapter(child: SizedBox(height: AppSize.spacingS)),

                      // Feed Content
                      if (state.currentTab == HomeFeedTab.forYou)
                        _buildForYouFeed(context, state)
                      else
                        _buildFollowingFeed(context, state, loc),

                      // Infinite Scroll Loading Indicator
                      if (isMoreLoading)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(AppSize.paddingM),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Bottom padding
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSize.paddingL),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.read<DashboardCubit>().changeTab(2);
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: AppColors.black100),
          ),
        );
      },
    );
  }

  Widget _buildFeedTabSelector(BuildContext context, HomeState state, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.paddingM,
        vertical: AppSize.paddingXS,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabPill(
              context: context,
              label: loc.translate('tab_for_you_feed'),
              isSelected: state.currentTab == HomeFeedTab.forYou,
              onTap: () => context.read<HomeCubit>().changeTab(HomeFeedTab.forYou),
            ),
          ),
          const SizedBox(width: AppSize.spacingS),
          Expanded(
            child: _buildTabPill(
              context: context,
              label: loc.translate('tab_following_feed'),
              isSelected: state.currentTab == HomeFeedTab.following,
              onTap: () => context.read<HomeCubit>().changeTab(HomeFeedTab.following),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey900,
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey800,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: isSelected
              ? CustomTextStyle.size13W600(color: AppColors.black100)
              : CustomTextStyle.size13W500(color: AppColors.grey400),
        ),
      ),
    );
  }

  Widget _buildForYouFeed(BuildContext context, HomeState state) {
    if (state.isLoading) {
      return const SliverFillRemaining(child: FeedShimmer());
    }

    if (state.actions.isEmpty) {
      return SliverFillRemaining(
        child: EmptyFeedWidget(
          onActionTap: () {
            context.read<DashboardCubit>().changeTab(1);
          },
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final action = state.actions[index];
        final currentUserId = ActionRepository().currentUserId;
        final isOwner = action.userId == currentUserId || action.userId == 'currentUser';

        return ActionCard(
          action: action,
          onLikeTap: () {
            context.read<HomeCubit>().likeAction(action.id);
          },
          onCommentTap: () {
            context.push('/action-details', extra: action);
          },
          onUserTap: () {
            context.push('/user-detail', extra: {
              'userId': action.userId,
              'userName': action.userName,
              'userAvatar': action.userAvatar,
            });
          },
          onDeleteTap: isOwner
              ? () {
                  context.read<HomeCubit>().deleteAction(action.id);
                }
              : null,
        );
      }, childCount: state.actions.length),
    );
  }

  Widget _buildFollowingFeed(BuildContext context, HomeState state, AppLocalizations loc) {
    if (state.isFollowingLoading) {
      return const SliverFillRemaining(child: FeedShimmer());
    }

    if (state.followingError != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 40),
              const SizedBox(height: AppSize.spacingS),
              Text(
                state.followingError!,
                style: CustomTextStyle.size14W400(color: AppColors.grey400),
              ),
              const SizedBox(height: AppSize.spacingM),
              ElevatedButton(
                onPressed: () => context.read<HomeCubit>().loadFeed(),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text(loc.translate('retry_btn'), style: const TextStyle(color: AppColors.black100)),
              ),
            ],
          ),
        ),
      );
    }

    if (state.followingActions.isEmpty) {
      return SliverFillRemaining(
        child: EmptyFollowingFeedWidget(
          onExploreTap: () {
            context.read<DashboardCubit>().changeTab(1);
          },
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final action = state.followingActions[index];
        final currentUserId = ActionRepository().currentUserId;
        final isOwner = action.userId == currentUserId || action.userId == 'currentUser';

        return ActionCard(
          action: action,
          onLikeTap: () {
            context.read<HomeCubit>().likeAction(action.id);
          },
          onCommentTap: () {
            context.push('/action-details', extra: action);
          },
          onUserTap: () {
            context.push('/user-detail', extra: {
              'userId': action.userId,
              'userName': action.userName,
              'userAvatar': action.userAvatar,
            });
          },
          onDeleteTap: isOwner
              ? () {
                  context.read<HomeCubit>().deleteAction(action.id);
                }
              : null,
        );
      }, childCount: state.followingActions.length),
    );
  }

  Widget _buildTopBar(BuildContext context, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.paddingM,
        vertical: AppSize.paddingM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo / Title
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSize.radiusS),
                ),
                child: const Center(
                  child: Text(
                    'W',
                    style: TextStyle(
                      color: AppColors.black100,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSize.spacingS),
              Text(
                loc.translate('app_title'),
                style: CustomTextStyle.size14W500(color: AppColors.white100),
              ),
            ],
          ),
          // Action Buttons: Toggle Language & Notifications next to each other
          Row(
            children: [
              const LanguageToggleButton(),
              const SizedBox(width: AppSize.spacingS),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: ActionRepository().getUserNotificationsStream(),
                builder: (context, snapshot) {
                  final notifications = snapshot.data ?? [];
                  final unreadCount = notifications.where((n) => n['isRead'] == false).length;

                  return GestureDetector(
                    onTap: () {
                      context.push('/notifications');
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSize.paddingS),
                          decoration: BoxDecoration(
                            color: AppColors.grey900,
                            borderRadius: BorderRadius.circular(AppSize.radiusM),
                            border: Border.all(color: AppColors.grey800),
                          ),
                          child: const Icon(
                            Icons.notifications_none_outlined,
                            color: AppColors.white100,
                            size: 22,
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: -3,
                            top: -3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.background, width: 1.5),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: const TextStyle(
                                  color: AppColors.white100,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),

            ],
          ),
        ],
      ),
    );
  }
}
