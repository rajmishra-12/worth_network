import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/constants/profile_constants.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/model/profile/profile_model.dart';
import 'package:worth_network/core/repo/action_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/core/repo/follow_repo.dart';
import 'package:worth_network/pages/home/widgets/action_cards.dart';
import 'package:worth_network/pages/network/widgets/follow_button.dart';
import 'package:worth_network/pages/profile/widgets/badge_section.dart';
import 'package:worth_network/pages/profile/widgets/stats_card.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;
  final String? initialName;
  final String? initialAvatar;

  const UserDetailScreen({
    super.key,
    required this.userId,
    this.initialName,
    this.initialAvatar,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final _actionRepo = ActionRepository();
  bool _isLoading = true;

  String _name = '';
  String _username = '';
  String _bio = '';
  String? _avatarUrl;
  String? _accountType;
  List<String> _roles = [];

  int _totalActions = 0;
  int _validatedCount = 0;
  double _validatedPercentage = 0.0;
  int _score = 0;
  int _level = 1;
  int _xp = 0;
  int _nextLevelXp = 100;
  List<BadgeModel> _badges = [];

  List<ActionModel> _userActions = [];

  @override
  void initState() {
    super.initState();
    _name = widget.initialName ?? 'User';
    _avatarUrl = widget.initialAvatar;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _name = data['name'] ?? _name;
        _username = data['username'] ?? '';
        _bio = data['bio'] ?? '';
        _avatarUrl = data['avatarUrl'] ?? _avatarUrl;
        _accountType = data['accountType'] as String?;
        _roles = (data['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        _score = data['score'] ?? 0;
        _level = data['level'] ?? 1;
        _xp = data['xp'] ?? 0;
        _nextLevelXp = data['nextLevelXp'] ?? 100;
      }

      // Fetch user published actions
      final actionsSnap = await FirebaseFirestore.instance
          .collection('actions')
          .where('userId', isEqualTo: widget.userId)
          .get();

      final actions = actionsSnap.docs
          .map((doc) => ActionModel.fromMap(doc.data(), doc.id, currentUserId: currentUserId))
          .toList();

      actions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Fetch validations completed for peers
      final valSnap = await FirebaseFirestore.instance
          .collection('actions')
          .where('validatorId', isEqualTo: widget.userId)
          .where('status', whereIn: ['confirmed', 'certified', 'rejected'])
          .get();

      _totalActions = actions.length;
      _validatedCount = valSnap.docs.length;
      final confirmedCount = actions.where((a) => a.validationStatus == ValidationStatus.confirmed || a.validationStatus == ValidationStatus.certified).length;
      _validatedPercentage = _totalActions > 0 ? (confirmedCount / _totalActions * 100) : 0.0;
      final certifiedCount = actions.where((a) => a.validationStatus == ValidationStatus.certified).length;

      // Evaluate 8 Dynamic Badges for this user profile
      _badges = [
        BadgeModel(
          name: 'First Action',
          description: 'Published your first action',
          isEarned: _totalActions >= 1,
        ),
        BadgeModel(
          name: 'Rising Star',
          description: 'Earned 50+ Worth score',
          isEarned: _score >= 50,
        ),
        BadgeModel(
          name: 'Trusted Validator',
          description: 'Completed 1 peer validation',
          isEarned: _validatedCount >= 1,
        ),
        BadgeModel(
          name: 'Certified Impact',
          description: 'Earned a certified high-confidence action',
          isEarned: certifiedCount >= 1,
        ),
        BadgeModel(
          name: 'Community Contributor',
          description: 'Published 5+ actions',
          isEarned: _totalActions >= 5,
        ),
        BadgeModel(
          name: 'Consistency Champion',
          description: 'Reached Level 2 or 150+ Worth score',
          isEarned: _level >= 2 || _score >= 150,
        ),
        BadgeModel(
          name: 'Reputation Pioneer',
          description: 'Reached Level 3 or 300+ Worth score',
          isEarned: _score >= 300 || _level >= 3,
        ),
        BadgeModel(
          name: 'Master Validator',
          description: 'Completed 5+ peer validations',
          isEarned: _validatedCount >= 5,
        ),
      ];

      if (mounted) {
        setState(() {
          _userActions = actions;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user detail page: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white100),
              onPressed: () => context.pop(),
            ),
            title: Text(
              _username.isNotEmpty ? '@$_username' : _name,
              style: CustomTextStyle.size18W600(color: AppColors.white100),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: FollowButton(targetUserId: widget.userId),
                ),
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : CustomScrollView(
                  slivers: [
                    // User Header
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(AppSize.paddingL),
                        child: Column(
                          children: [
                            // Avatar
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 46,
                                backgroundColor: AppColors.grey800,
                                backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                    ? NetworkImage(_avatarUrl!)
                                    : null,
                                child: _avatarUrl == null || _avatarUrl!.isEmpty
                                    ? Text(
                                        _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                                        style: CustomTextStyle.size24W600(color: AppColors.white100),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: AppSize.spacingM),

                            // Name
                            Text(
                              _name,
                              style: CustomTextStyle.size20W600(color: AppColors.white100),
                            ),
                            if (_username.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                '@$_username',
                                style: CustomTextStyle.size14W400(color: AppColors.primary),
                              ),
                            ],
                            const SizedBox(height: 4),

                            // Bio
                            if (_bio.isNotEmpty)
                              Text(
                                _bio,
                                style: CustomTextStyle.size14W400(color: AppColors.grey400),
                                textAlign: TextAlign.center,
                              ),

                            // Account Type Badge
                            if (_accountType != null && _accountType!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Builder(builder: (context) {
                                final accType = ProfileConstants.getAccountType(_accountType);
                                if (accType == null) return const SizedBox.shrink();
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppSize.radiusM),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(accType.icon, size: 13, color: AppColors.primary),
                                      const SizedBox(width: 5),
                                      Text(
                                        accType.label,
                                        style: CustomTextStyle.size12W500(color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],

                            // Roles & Domains Tags
                            if (_roles.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 6,
                                runSpacing: 6,
                                children: _roles.map((rKey) {
                                  final rOption = ProfileConstants.getRole(rKey);
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.grey800,
                                      borderRadius: BorderRadius.circular(AppSize.radiusS),
                                      border: Border.all(color: AppColors.grey700),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(rOption.icon, size: 12, color: AppColors.white100),
                                        const SizedBox(width: 4),
                                        Text(
                                          rOption.label,
                                          style: CustomTextStyle.size11W400(color: AppColors.white100),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: AppSize.spacingM),

                            // Followers & Following Metrics Row
                            StreamBuilder<Map<String, int>>(
                              stream: FollowRepository().getUserMetricsStream(widget.userId),
                              builder: (context, snapshot) {
                                final metrics = snapshot.data;
                                final followersCount = metrics?['followers'] ?? 0;
                                final followingCount = metrics?['following'] ?? 0;

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        context.push('/user-connections', extra: {
                                          'userId': widget.userId,
                                          'userName': _name,
                                          'initialTabIndex': 0,
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Text(
                                            '$followersCount',
                                            style: CustomTextStyle.size16W600(color: AppColors.white100),
                                          ),
                                          Text(
                                            loc.translate('followers_count'),
                                            style: CustomTextStyle.size12W400(color: AppColors.grey400),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: AppSize.spacingXL),
                                    Container(
                                      height: 24,
                                      width: 1,
                                      color: AppColors.grey800,
                                    ),
                                    const SizedBox(width: AppSize.spacingXL),
                                    GestureDetector(
                                      onTap: () {
                                        context.push('/user-connections', extra: {
                                          'userId': widget.userId,
                                          'userName': _name,
                                          'initialTabIndex': 1,
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Text(
                                            '$followingCount',
                                            style: CustomTextStyle.size16W600(color: AppColors.white100),
                                          ),
                                          Text(
                                            loc.translate('following_count'),
                                            style: CustomTextStyle.size12W400(color: AppColors.grey400),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Stats Card
                    SliverToBoxAdapter(
                      child: StatsCard(
                        totalActions: _totalActions,
                        validatedPercentage: _validatedPercentage,
                        score: _score,
                        level: _level,
                        xp: _xp,
                        nextLevelXp: _nextLevelXp,
                      ),
                    ),

                    // Badges Section
                    SliverToBoxAdapter(
                      child: BadgesSection(badges: _badges),
                    ),

                    // User Actions Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSize.paddingM,
                          AppSize.paddingL,
                          AppSize.paddingM,
                          AppSize.paddingS,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${loc.translate('published_actions')} (${_userActions.length})',
                              style: CustomTextStyle.size16W600(color: AppColors.white100),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Actions Feed
                    _userActions.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSize.paddingXL),
                              child: Center(
                                child: Column(
                                  children: [
                                    const Icon(Icons.assignment_outlined, size: 48, color: AppColors.grey600),
                                    const SizedBox(height: AppSize.spacingM),
                                    Text(
                                      loc.translate('no_published_actions'),
                                      style: CustomTextStyle.size14W400(color: AppColors.grey500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final action = _userActions[index];
                            final isOwner = currentUserId == action.userId;

                            return ActionCard(
                              action: action,
                              onLikeTap: () async {
                                final isLiked = currentUserId != null && action.likedBy.contains(currentUserId);
                                final updatedLikes = isLiked
                                    ? action.likedBy.where((id) => id != currentUserId).toList()
                                    : [...action.likedBy, if (currentUserId != null) currentUserId];
                                final updatedCount = isLiked ? action.likesCount - 1 : action.likesCount + 1;

                                setState(() {
                                  _userActions[index] = action.copyWith(
                                    likedBy: updatedLikes,
                                    likesCount: updatedCount,
                                    isLikedByUser: !isLiked,
                                  );
                                });

                                await _actionRepo.toggleLike(action.id);
                              },
                              onCommentTap: () {
                                context.push('/action-details', extra: action);
                              },
                              onUserTap: () {},
                              onDeleteTap: isOwner
                                  ? () async {
                                      await _actionRepo.deleteAction(action.id);
                                      setState(() {
                                        _userActions.removeAt(index);
                                      });
                                    }
                                  : null,
                            );
                          },
                          childCount: _userActions.length,
                        ),
                      ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSize.paddingXL),
                ),
              ],
            ),
        );
      },
    );
  }
}
