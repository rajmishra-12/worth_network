import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/repo/moderation_repo.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';

class AdminContentPage extends StatefulWidget {
  const AdminContentPage({super.key});

  @override
  State<AdminContentPage> createState() => _AdminContentPageState();
}

class _AdminContentPageState extends State<AdminContentPage> {
  final ModerationRepository _repo = ModerationRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _statusFilter = 'all'; // all, visible, hidden, removed
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _showModerationDialog(ActionModel action, String targetStatus) {
    _reasonController.clear();
    String title = 'Hide Content';
    if (targetStatus == 'removed') title = 'Remove Content';
    if (targetStatus == 'visible') title = 'Restore Content';

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
            Text('Action: "${action.title}"', style: CustomTextStyle.size14W600(color: AppColors.grey300)),
            Text('Author: @${action.userName}', style: CustomTextStyle.size12W400(color: AppColors.grey400)),
            const SizedBox(height: AppSize.spacingM),
            Text('Reason for moderation:', style: CustomTextStyle.size14W500(color: AppColors.grey300)),
            const SizedBox(height: 4),
            TextField(
              controller: _reasonController,
              style: CustomTextStyle.size14W400(color: AppColors.white100),
              decoration: InputDecoration(
                hintText: 'Enter reason...',
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
            child: Text('Cancel', style: CustomTextStyle.size14W500(color: AppColors.grey400)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final reasonText = _reasonController.text.trim().isEmpty ? 'Admin action' : _reasonController.text.trim();
              await _repo.updateContentModerationStatus(
                contentId: action.id,
                contentType: 'action',
                status: targetStatus,
                reason: reasonText,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Content status changed to $targetStatus'), backgroundColor: AppColors.success),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: targetStatus == 'removed' ? AppColors.error : AppColors.primary,
            ),
            child: Text('Confirm', style: CustomTextStyle.size14W600(color: AppColors.white100)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = AppColors.success;
    String label = 'Visible';

    if (status == 'hidden') {
      color = AppColors.warning;
      label = 'Hidden';
    } else if (status == 'removed') {
      color = AppColors.error;
      label = 'Removed';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.grey900,
        elevation: 0,
        title: Text('Content Moderation', style: CustomTextStyle.size18W600(color: AppColors.white100)),
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
                    hintText: 'Search by title, author, description...',
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
                      _buildChip('All Content', 'all'),
                      _buildChip('Visible Only', 'visible'),
                      _buildChip('Hidden', 'hidden'),
                      _buildChip('Removed', 'removed'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('actions').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No content found.', style: CustomTextStyle.size14W400(color: AppColors.grey400)),
                  );
                }

                var actions = snapshot.data!.docs.map((doc) {
                  return ActionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                if (_statusFilter != 'all') {
                  actions = actions.where((a) => a.moderationStatus == _statusFilter).toList();
                }

                if (_searchQuery.isNotEmpty) {
                  actions = actions.where((a) {
                    return a.title.toLowerCase().contains(_searchQuery) ||
                        a.description.toLowerCase().contains(_searchQuery) ||
                        a.userName.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSize.paddingM),
                  itemCount: actions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSize.spacingS),
                  itemBuilder: (context, index) {
                    final action = actions[index];
                    return Container(
                      padding: const EdgeInsets.all(AppSize.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.grey900,
                        borderRadius: BorderRadius.circular(AppSize.radiusL),
                        border: Border.all(color: AppColors.grey800),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.grey800,
                                backgroundImage: action.userAvatar != null ? NetworkImage(action.userAvatar!) : null,
                                child: action.userAvatar == null
                                    ? Text(
                                        action.userName.isNotEmpty ? action.userName[0] : 'U',
                                        style: CustomTextStyle.size12W600(color: AppColors.white100),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  action.userName,
                                  style: CustomTextStyle.size14W600(color: AppColors.white100),
                                ),
                              ),
                              _buildStatusChip(action.moderationStatus),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(action.title, style: CustomTextStyle.size14W600(color: AppColors.white100)),
                          const SizedBox(height: 4),
                          Text(
                            action.description,
                            style: CustomTextStyle.size12W400(color: AppColors.grey400),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (action.moderationReason != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Reason: ${action.moderationReason}',
                              style: CustomTextStyle.size12W400(color: AppColors.warning),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (action.moderationStatus != 'visible')
                                OutlinedButton(
                                  onPressed: () => _showModerationDialog(action, 'visible'),
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.success)),
                                  child: Text('Restore', style: CustomTextStyle.size12W600(color: AppColors.success)),
                                ),
                              if (action.moderationStatus != 'hidden') ...[
                                const SizedBox(width: 6),
                                OutlinedButton(
                                  onPressed: () => _showModerationDialog(action, 'hidden'),
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.warning)),
                                  child: Text('Hide', style: CustomTextStyle.size12W600(color: AppColors.warning)),
                                ),
                              ],
                              if (action.moderationStatus != 'removed') ...[
                                const SizedBox(width: 6),
                                OutlinedButton(
                                  onPressed: () => _showModerationDialog(action, 'removed'),
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                                  child: Text('Remove', style: CustomTextStyle.size12W600(color: AppColors.error)),
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
