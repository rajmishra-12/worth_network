import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/repo/moderation_repo.dart';
import 'package:worth_network/core/services/moderation_text_service.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';

class AdminWordFilterPage extends StatefulWidget {
  const AdminWordFilterPage({super.key});

  @override
  State<AdminWordFilterPage> createState() => _AdminWordFilterPageState();
}

class _AdminWordFilterPageState extends State<AdminWordFilterPage> {
  final ModerationRepository _repo = ModerationRepository();
  final TextEditingController _wordController = TextEditingController();

  bool _isAdding = false;

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  Future<void> _addWord(AppLocalizations loc) async {
    final text = _wordController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isAdding = true);
    try {
      await _repo.addBlockedWord(text);
      _wordController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('added_word_toast')} ("$text")'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('error_adding_word')} $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _removeWord(String word, AppLocalizations loc) async {
    try {
      await _repo.removeBlockedWord(word);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('removed_word_toast')} ("$word")'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('error_removing_word')} $e'), backgroundColor: AppColors.error),
        );
      }
    }
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
            title: Text(loc.translate('prohibited_word_filter'), style: CustomTextStyle.size18W600(color: AppColors.white100)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white100),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppSize.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('manage_abusive_words'),
                  style: CustomTextStyle.size16W600(color: AppColors.white100),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.translate('word_filter_desc'),
                  style: CustomTextStyle.size14W400(color: AppColors.grey400),
                ),
                const SizedBox(height: AppSize.spacingM),

                // Input field + Add button
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _wordController,
                        onSubmitted: (_) => _addWord(loc),
                        style: CustomTextStyle.size14W400(color: AppColors.white100),
                        decoration: InputDecoration(
                          hintText: loc.translate('enter_prohibited_word_hint'),
                          hintStyle: CustomTextStyle.size14W400(color: AppColors.grey500),
                          filled: true,
                          fillColor: AppColors.grey900,
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM, vertical: AppSize.paddingM),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSize.radiusM),
                            borderSide: const BorderSide(color: AppColors.grey800),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSize.radiusM),
                            borderSide: const BorderSide(color: AppColors.grey800),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSize.radiusM),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSize.spacingS),
                    ElevatedButton(
                      onPressed: _isAdding ? null : () => _addWord(loc),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSize.radiusM)),
                      ),
                      child: _isAdding
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white100))
                          : Text(loc.translate('add_word_btn'), style: CustomTextStyle.size14W600(color: AppColors.white100)),
                    ),
                  ],
                ),

                const SizedBox(height: AppSize.spacingL),

                // Words Chips Container
                Expanded(
                  child: StreamBuilder<List<String>>(
                    stream: _repo.getBlockedWordsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      }

                      final words = snapshot.data ?? [];
                      final fallbackWords = ModerationTextService().currentBlockedWords.toList();

                      final displayWords = words.isNotEmpty ? words : fallbackWords;

                      if (displayWords.isEmpty) {
                        return Center(
                          child: Text(loc.translate('no_blocked_words'), style: CustomTextStyle.size14W400(color: AppColors.grey400)),
                        );
                      }

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSize.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.grey900,
                          borderRadius: BorderRadius.circular(AppSize.radiusL),
                          border: Border.all(color: AppColors.grey800),
                        ),
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: displayWords.map((word) {
                              return Chip(
                                backgroundColor: AppColors.grey800,
                                side: const BorderSide(color: AppColors.grey700),
                                label: Text(word, style: CustomTextStyle.size14W500(color: AppColors.white100)),
                                deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.error),
                                onDeleted: () => _removeWord(word, loc),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

