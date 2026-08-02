import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/pages/network/cubit/network_cubit.dart';
import 'package:worth_network/pages/network/widgets/common_search_bar.dart';
import 'package:worth_network/pages/network/widgets/filter_chips.dart';
import 'package:worth_network/pages/network/widgets/user_card.dart';


class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<NetworkCubit>().loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            CustomSearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onSearch: (query) {
                context.read<NetworkCubit>().searchUsers(query);
              },
              onClear: () {
                _searchController.clear();
                context.read<NetworkCubit>().clearSearch();
              },
            ),
            // Filter Chips (Future-ready)
            const FilterChips(),
            // User List
            Expanded(
              child: BlocBuilder<NetworkCubit, NetworkState>(
                builder: (context, state) {
                  if (state.isLoading && state.users.isEmpty) {
                    return const _LoadingState();
                  }

                  if (state.filteredUsers.isEmpty && !state.isLoading) {
                    return _EmptyState(
                      isSearching: state.searchQuery.isNotEmpty,
                      onClearSearch: () {
                        _searchController.clear();
                        context.read<NetworkCubit>().clearSearch();
                      },
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<NetworkCubit>().loadUsers();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        top: AppSize.paddingS,
                        bottom: AppSize.paddingXL,
                      ),
                      itemCount: state.filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = state.filteredUsers[index];
                        return UserCard(
                          user: user,
                          onTap: () {
                            context.push('/user-detail', extra: {
                              'userId': user.id,
                              'userName': user.name,
                              'userAvatar': user.avatarUrl,
                            });
                          },
                        );

                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSize.paddingM),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSize.paddingM),
          padding: const EdgeInsets.all(AppSize.paddingM),
          decoration: BoxDecoration(
            color: AppColors.grey900,
            borderRadius: BorderRadius.circular(AppSize.radiusM),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.grey800,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSize.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      color: AppColors.grey800,
                    ),
                    const SizedBox(height: AppSize.spacingS),
                    Container(
                      width: 80,
                      height: 12,
                      color: AppColors.grey800,
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.grey800,
                  borderRadius: BorderRadius.circular(AppSize.radiusM),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onClearSearch;

  const _EmptyState({
    required this.isSearching,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSearching ? Icons.search_off_outlined : Icons.people_outline,
                  size: 40,
                  color: AppColors.black100,
                ),
              ),
              const SizedBox(height: AppSize.spacingL),
              Text(
                isSearching ? loc.translate('no_users_found') : loc.translate('explore_network'),
                style: CustomTextStyle.size18W600(color: AppColors.white100),
              ),
              const SizedBox(height: AppSize.spacingS),
              Text(
                isSearching
                    ? loc.translate('try_different_search')
                    : loc.translate('connect_with_people'),
                style: CustomTextStyle.size14W400(color: AppColors.grey400),
              ),
              if (isSearching) ...[
                const SizedBox(height: AppSize.spacingL),
                TextButton(
                  onPressed: onClearSearch,
                  child: Text(
                    loc.translate('clear_search'),
                    style: CustomTextStyle.size14W600(color: AppColors.primary),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}