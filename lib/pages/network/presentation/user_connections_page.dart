import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/pages/network/cubit/user_connections_cubit.dart';
import 'package:worth_network/pages/network/widgets/common_search_bar.dart';
import 'package:worth_network/pages/network/widgets/user_card.dart';

class UserConnectionsScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final int initialTabIndex;

  const UserConnectionsScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.initialTabIndex = 0,
  });

  @override
  State<UserConnectionsScreen> createState() => _UserConnectionsScreenState();
}

class _UserConnectionsScreenState extends State<UserConnectionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final UserConnectionsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = UserConnectionsCubit()..loadConnections(widget.userId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<LocaleCubit, String>(
        builder: (context, localeCode) {
          final loc = AppLocalizations(localeCode);

          return DefaultTabController(
            length: 2,
            initialIndex: widget.initialTabIndex,
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.background,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.white100),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  widget.userName,
                  style: CustomTextStyle.size18W600(color: AppColors.white100),
                ),
                bottom: TabBar(
                  indicatorColor: AppColors.primary,
                  dividerColor: Colors.transparent,
                  dividerHeight: 0,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.grey400,
                  labelStyle: CustomTextStyle.size14W600(color: AppColors.primary),
                  tabs: [
                    Tab(text: loc.translate('followers_count')),
                    Tab(text: loc.translate('following_count')),
                  ],
                ),
              ),
              body: Column(
                children: [
                  const SizedBox(height: AppSize.spacingS),
                  // Search Bar
                  Builder(builder: (ctx) {
                    return CustomSearchBar(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onSearch: (query) {
                        ctx.read<UserConnectionsCubit>().search(query);
                      },
                      onClear: () {
                        _searchController.clear();
                        ctx.read<UserConnectionsCubit>().search('');
                      },
                    );
                  }),
                  const SizedBox(height: AppSize.spacingS),
                  Expanded(
                    child: BlocBuilder<UserConnectionsCubit, UserConnectionsState>(
                      builder: (ctx, state) {
                        if (state.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          );
                        }

                        if (state.errorMessage != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  state.errorMessage!,
                                  style: CustomTextStyle.size14W400(color: AppColors.grey400),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    ctx.read<UserConnectionsCubit>().loadConnections(widget.userId);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                  child: Text(
                                    loc.translate('retry_btn'),
                                    style: CustomTextStyle.size14W600(color: AppColors.black100),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return TabBarView(
                          children: [
                            // Followers List
                            _buildUserList(
                              context: ctx,
                              users: state.filteredFollowers,
                              emptyMessage: loc.translate('no_followers_yet'),
                              loc: loc,
                            ),
                            // Following List
                            _buildUserList(
                              context: ctx,
                              users: state.filteredFollowing,
                              emptyMessage: loc.translate('no_following_yet'),
                              loc: loc,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserList({
    required BuildContext context,
    required List users,
    required String emptyMessage,
    required AppLocalizations loc,
  }) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, color: AppColors.grey600, size: 56),
            const SizedBox(height: AppSize.spacingM),
            Text(
              emptyMessage,
              style: CustomTextStyle.size15W500(color: AppColors.grey400),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<UserConnectionsCubit>().loadConnections(widget.userId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: AppSize.paddingXL),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return UserCard(
            user: user,
            onTap: () {
              context.push('/user-detail', extra: {
                'userId': user.id,
                'userName': user.name,
                'userAvatar': user.avatarUrl,
              });
            },
            onFollowChanged: () {
              context.read<UserConnectionsCubit>().loadConnections(widget.userId);
            },
          );
        },
      ),
    );
  }
}
