import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/model/user/user_model.dart';
import 'package:worth_network/core/repo/moderation_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final ModerationRepository _repo = ModerationRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _statusFilter = 'all'; // all, active, suspended, blocked
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _showStatusChangeDialog(UserModel user, String targetStatus, AppLocalizations loc) {
    _reasonController.clear();
    String title = loc.translate('suspend_account_title');
    if (targetStatus == 'blocked') title = loc.translate('block_account_title');
    if (targetStatus == 'active') title = loc.translate('reactivate_account_title');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.grey900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.radiusL),
          side: const BorderSide(color: AppColors.grey800),
        ),
        title: Text(title, style: CustomTextStyle.size18W600(color: AppColors.white100)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${loc.translate('user_label')} @${user.username ?? user.name}', style: CustomTextStyle.size14W600(color: AppColors.grey300)),
            const SizedBox(height: AppSize.spacingM),
            Text(loc.translate('reason_status_change'), style: CustomTextStyle.size14W500(color: AppColors.grey300)),
            const SizedBox(height: 4),
            TextField(
              controller: _reasonController,
              style: CustomTextStyle.size14W400(color: AppColors.white100),
              decoration: InputDecoration(
                hintText: loc.translate('audit_log_hint'),
                hintStyle: CustomTextStyle.size14W400(color: AppColors.grey500),
                filled: true,
                fillColor: AppColors.grey800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.radiusM),
                  borderSide: const BorderSide(color: AppColors.grey700),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.translate('close_btn'), style: CustomTextStyle.size14W500(color: AppColors.grey400)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final reasonText = _reasonController.text.trim().isEmpty ? loc.translate('default_admin_status_reason') : _reasonController.text.trim();
              await _repo.updateUserAccountStatus(
                targetUserId: user.id,
                targetUserName: user.name,
                accountStatus: targetStatus,
                reason: reasonText,
              );
              if (mounted) {
                final toastMsg = loc.translate('user_status_updated_toast').replaceAll('{status}', targetStatus);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(toastMsg), backgroundColor: AppColors.success),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: targetStatus == 'active' ? AppColors.success : AppColors.error,
            ),
            child: Text(loc.translate('confirm_btn'), style: CustomTextStyle.size14W600(color: AppColors.white100)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, AppLocalizations loc) {
    Color color = AppColors.success;
    String label = loc.translate('filter_active');

    if (status == 'suspended') {
      color = Colors.purpleAccent;
      label = loc.translate('filter_suspended');
    } else if (status == 'blocked') {
      color = AppColors.error;
      label = loc.translate('filter_blocked');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSize.radiusS),
      ),
      child: Text(label, style: CustomTextStyle.size12W600(color: color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.grey900,
            elevation: 0,
            title: Text(loc.translate('user_moderation_title'), style: CustomTextStyle.size18W600(color: AppColors.white100)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white100),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSize.paddingM),
                color: AppColors.grey900,
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                      style: CustomTextStyle.size14W400(color: AppColors.white100),
                      decoration: InputDecoration(
                        hintText: loc.translate('search_user_hint'),
                        hintStyle: CustomTextStyle.size14W400(color: AppColors.grey500),
                        prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
                        filled: true,
                        fillColor: AppColors.grey800,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSize.radiusM),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSize.spacingS),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChip(loc.translate('filter_all_accounts'), 'all'),
                          _buildChip(loc.translate('filter_active'), 'active'),
                          _buildChip(loc.translate('filter_suspended'), 'suspended'),
                          _buildChip(loc.translate('filter_blocked'), 'blocked'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(loc.translate('no_users_found_admin'), style: CustomTextStyle.size14W400(color: AppColors.grey400)),
                      );
                    }

                    var users = snapshot.data!.docs.map((doc) {
                      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                    }).toList();

                    if (_statusFilter != 'all') {
                      users = users.where((u) => u.accountStatus == _statusFilter).toList();
                    }

                    if (_searchQuery.isNotEmpty) {
                      users = users.where((u) {
                        final name = u.name.toLowerCase();
                        final username = (u.username ?? '').toLowerCase();
                        return name.contains(_searchQuery) || username.contains(_searchQuery);
                      }).toList();
                    }

                    if (users.isEmpty) {
                      return Center(
                        child: Text(loc.translate('no_users_found_admin'), style: CustomTextStyle.size14W400(color: AppColors.grey400)),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(AppSize.paddingM),
                      itemCount: users.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSize.spacingS),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Container(
                          padding: const EdgeInsets.all(AppSize.paddingM),
                          decoration: BoxDecoration(
                            color: AppColors.grey900,
                            borderRadius: BorderRadius.circular(AppSize.radiusL),
                            border: Border.all(color: AppColors.grey800),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.grey800,
                                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                                    child: user.avatarUrl == null
                                        ? Text(
                                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                            style: CustomTextStyle.size14W600(color: AppColors.white100),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: AppSize.spacingM),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(user.name, style: CustomTextStyle.size14W600(color: AppColors.white100)),
                                        if (user.username != null)
                                          Text('@${user.username}', style: CustomTextStyle.size12W400(color: AppColors.grey400)),
                                      ],
                                    ),
                                  ),
                                  _buildStatusChip(user.accountStatus, loc),
                                ],
                              ),
                              if (user.suspensionReason != null && user.suspensionReason!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${loc.translate('reason_label')} ${user.suspensionReason}',
                                    style: CustomTextStyle.size12W400(color: AppColors.warning),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (user.accountStatus != 'active')
                                    OutlinedButton(
                                      onPressed: () => _showStatusChangeDialog(user, 'active', loc),
                                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.success)),
                                      child: Text(loc.translate('activate_user'), style: CustomTextStyle.size12W600(color: AppColors.success)),
                                    ),
                                  if (user.accountStatus != 'suspended') ...[
                                    const SizedBox(width: 6),
                                    OutlinedButton(
                                      onPressed: () => _showStatusChangeDialog(user, 'suspended', loc),
                                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.purpleAccent)),
                                      child: Text(loc.translate('suspend_user'), style: CustomTextStyle.size12W600(color: Colors.purpleAccent)),
                                    ),
                                  ],
                                  if (user.accountStatus != 'blocked') ...[
                                    const SizedBox(width: 6),
                                    OutlinedButton(
                                      onPressed: () => _showStatusChangeDialog(user, 'blocked', loc),
                                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                                      child: Text(loc.translate('block_user'), style: CustomTextStyle.size12W600(color: AppColors.error)),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) setState(() => _statusFilter = value);
        },
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.grey800,
        checkmarkColor: AppColors.black100,
        labelStyle: CustomTextStyle.size12W600(
          color: isSelected ? AppColors.black100 : AppColors.grey400,
        ),
      ),
    );
  }
}

