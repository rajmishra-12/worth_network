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


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadFeed();
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
              child: CustomScrollView(
                slivers: [
                  // Top Bar
                  SliverToBoxAdapter(child: _buildTopBar(context, loc)),
                  // Feed Content
                  BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
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

                    },
                  ),
                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSize.paddingL),
                  ),
                ],
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
