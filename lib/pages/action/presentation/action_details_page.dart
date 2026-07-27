import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/pages/home/widgets/empty_feed_widget.dart';

class ActionDetailsScreen extends StatefulWidget {
  final ActionModel action;

  const ActionDetailsScreen({super.key, required this.action});

  @override
  State<ActionDetailsScreen> createState() => _ActionDetailsScreenState();
}

class _ActionDetailsScreenState extends State<ActionDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, String>> _comments = [
    {
      'userName': 'Sarah Johnson',
      'avatarUrl': 'https://i.pravatar.cc/150?img=1',
      'text': 'This is highly inspiring! Thanks for doing this.',
      'time': '2h ago',
    },
    {
      'userName': 'Marcus Aurelius',
      'avatarUrl': 'https://i.pravatar.cc/150?img=4',
      'text': 'Proof looks solid. Keep it up!',
      'time': '1h ago',
    },
  ];

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.add({
        'userName': 'You',
        'avatarUrl': 'https://i.pravatar.cc/150?img=10',
        'text': text,
        'time': 'Just now',
      });
      _commentController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
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
          'Action Details',
          style: CustomTextStyle.size18W600(color: AppColors.white100),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSize.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Details & Score
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.grey800,
                        backgroundImage: action.userAvatar != null
                            ? NetworkImage(action.userAvatar!)
                            : null,
                        child: action.userAvatar == null
                            ? Text(action.userName[0], style: const TextStyle(color: AppColors.white100))
                            : null,
                      ),
                      const SizedBox(width: AppSize.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action.userName,
                              style: CustomTextStyle.size15W600(color: AppColors.white100),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MMMM dd, yyyy').format(action.createdAt),
                              style: CustomTextStyle.size12W400(color: AppColors.grey500),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.grey900,
                          borderRadius: BorderRadius.circular(AppSize.radiusS),
                          border: Border.all(color: AppColors.grey800),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: AppColors.primary, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${action.score}',
                              style: CustomTextStyle.size14W600(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSize.spacingL),

                  // Action Title
                  Text(
                    action.title,
                    style: CustomTextStyle.size20W600(color: AppColors.white100),
                  ),
                  const SizedBox(height: AppSize.spacingM),

                  // Category & Status Chips
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSize.radiusM),
                        ),
                        child: Text(
                          action.category,
                          style: CustomTextStyle.size13W500(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: AppSize.spacingS),
                      ValidationBadge(status: action.validationStatus),
                    ],
                  ),
                  const SizedBox(height: AppSize.spacingL),

                  // Description
                  Text(
                    'Description',
                    style: CustomTextStyle.size15W600(color: AppColors.white100),
                  ),
                  const SizedBox(height: AppSize.spacingS),
                  Text(
                    action.description,
                    style: CustomTextStyle.size14W400(color: AppColors.grey300),
                  ),
                  const SizedBox(height: AppSize.spacingXL),

                  // Evidence / Proof Section
                  Text(
                    'Uploaded Proof (Credibility Evidence)',
                    style: CustomTextStyle.size15W600(color: AppColors.white100),
                  ),
                  const SizedBox(height: AppSize.spacingS),
                  _buildEvidencePreview(action),
                  const SizedBox(height: AppSize.spacingXL),

                  // Comments Header
                  Row(
                    children: [
                      Text(
                        'Comments',
                        style: CustomTextStyle.size15W600(color: AppColors.white100),
                      ),
                      const SizedBox(width: AppSize.spacingS),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.grey800,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_comments.length}',
                          style: CustomTextStyle.size11W600(color: AppColors.white100),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSize.spacingM),

                  // Comments List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _comments.length,
                    separatorBuilder: (context, index) => Divider(color: AppColors.grey900, height: 24),
                    itemBuilder: (context, index) {
                      final c = _comments[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.grey800,
                            backgroundImage: NetworkImage(c['avatarUrl']!),
                          ),
                          const SizedBox(width: AppSize.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      c['userName']!,
                                      style: CustomTextStyle.size13W600(color: AppColors.white100),
                                    ),
                                    Text(
                                      c['time']!,
                                      style: CustomTextStyle.size11W400(color: AppColors.grey500),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  c['text']!,
                                  style: CustomTextStyle.size13W400(color: AppColors.grey300),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSize.spacingXL),
                ],
              ),
            ),
          ),

          // Add Comment Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM, vertical: AppSize.paddingS),
            decoration: const BoxDecoration(
              color: AppColors.grey900,
              border: Border(
                top: BorderSide(color: AppColors.grey800, width: 1),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppSize.radiusL),
                        border: Border.all(color: AppColors.grey800),
                      ),
                      child: TextField(
                        controller: _commentController,
                        style: CustomTextStyle.size14W400(color: AppColors.white100),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: CustomTextStyle.size14W400(color: AppColors.grey500),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSize.spacingS),
                  IconButton(
                    icon: Icon(Icons.send_rounded, color: AppColors.primary),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidencePreview(ActionModel action) {
    final proofType = action.proofType ?? 'text';
    final proofUrl = action.proofUrl;

    if (proofType == 'photo' && proofUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSize.radiusM),
        child: Image.network(
          proofUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 120,
              color: AppColors.grey900,
              child: const Center(
                child: Icon(Icons.broken_image_outlined, color: AppColors.grey500, size: 36),
              ),
            );
          },
        ),
      );
    }

    if (proofType == 'document') {
      return Container(
        padding: const EdgeInsets.all(AppSize.paddingM),
        decoration: BoxDecoration(
          color: AppColors.grey900,
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          border: Border.all(color: AppColors.grey800),
        ),
        child: Row(
          children: [
            Icon(Icons.picture_as_pdf, color: AppColors.error, size: 36),
            const SizedBox(width: AppSize.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Signed_Verification_Document.pdf',
                    style: CustomTextStyle.size14W500(color: AppColors.white100),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '142 KB • PDF Document',
                    style: CustomTextStyle.size12W400(color: AppColors.grey500),
                  ),
                ],
              ),
            ),
            Icon(Icons.download_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      );
    }

    if (proofType == 'audio') {
      return Container(
        padding: const EdgeInsets.all(AppSize.paddingM),
        decoration: BoxDecoration(
          color: AppColors.grey900,
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          border: Border.all(color: AppColors.grey800),
        ),
        child: Row(
          children: [
            Icon(Icons.play_circle_fill, color: AppColors.primary, size: 40),
            const SizedBox(width: AppSize.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audio Proof (Voice Note)',
                    style: CustomTextStyle.size14W500(color: AppColors.white100),
                  ),
                  const SizedBox(height: 4),
                  // Mock waveform visualizer
                  Row(
                    children: List.generate(15, (i) {
                      final h = (i % 3 == 0) ? 12.0 : (i % 2 == 0 ? 18.0 : 8.0);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 2.5,
                        height: h,
                        decoration: BoxDecoration(
                          color: i < 6 ? AppColors.primary : AppColors.grey700,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Text(
              '0:12',
              style: CustomTextStyle.size12W500(color: AppColors.grey400),
            ),
          ],
        ),
      );
    }

    // Default to text note or fallback
    return Container(
      padding: const EdgeInsets.all(AppSize.paddingM),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(AppSize.radiusM),
        border: Border.all(color: AppColors.grey800),
      ),
      child: Text(
        'Declared with text proof: "Completed the logged task and discussed outcomes with validator."',
        style: CustomTextStyle.size14W400(color: AppColors.grey300),
      ),
    );
  }
}
