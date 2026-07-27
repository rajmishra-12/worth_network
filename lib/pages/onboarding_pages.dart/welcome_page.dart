import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/components/common/common_background.dart';
import 'package:worth_network/components/common/common_button.dart';
import 'package:worth_network/components/common/language_toggle_button.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/navigator/app_pages.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _goToNextPage() {
    if (_currentIndex == 0) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() {
    Pages.appRouter.go(Routes.loginScreen);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, locale) {
        final loc = AppLocalizations(locale);
        return CommonBackground(
          backgroundColor: AppColors.background,
          showSafeArea: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingL, vertical: AppSize.paddingM),
            child: Column(
              children: [
                // Top Row: Logo & Language Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
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
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSize.spacingS),
                        Text(
                          loc.translate('app_title'),
                          style: CustomTextStyle.size16W600(color: AppColors.white100),
                        ),
                      ],
                    ),
                    const LanguageToggleButton(),
                  ],
                ),
                const Spacer(),
                
                // Onboarding Content
                Expanded(
                  flex: 12,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    children: [
                      _buildPageOne(loc),
                      _buildPageTwo(loc),
                    ],
                  ),
                ),
                
                const Spacer(),

                // Page Indicator Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (index) {
                    final isSelected = _currentIndex == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isSelected ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.grey700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: AppSize.spacingXL),

                // Action Buttons
                if (_currentIndex == 0)
                  CustomButton(
                    text: loc.translate('btn_next'),
                    textStyle: CustomTextStyle.size15W600(color: AppColors.black100),
                    onTap: _goToNextPage,
                  )
                else
                  CustomButton(
                    text: loc.translate('btn_get_started'),
                    textStyle: CustomTextStyle.size15W600(color: AppColors.black100),
                    onTap: _finishOnboarding,
                  ),
                const SizedBox(height: AppSize.paddingM),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageOne(AppLocalizations loc) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSize.spacingXL),
          Text(
            loc.translate('credibility_cycle'),
            style: CustomTextStyle.size24W600(color: AppColors.white100),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSize.spacingS),
          Text(
            loc.translate('credibility_cycle_desc'),
            style: CustomTextStyle.size14W400(color: AppColors.grey400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSize.spacingXL),
          
          // Stepper Sequence
          _buildFlowStep(
            number: '1',
            title: loc.translate('step_action'),
            desc: loc.translate('step_action_desc'),
            icon: Icons.bolt,
          ),
          _buildFlowArrow(),
          _buildFlowStep(
            number: '2',
            title: loc.translate('step_proof'),
            desc: loc.translate('step_proof_desc'),
            icon: Icons.upload_file,
          ),
          _buildFlowArrow(),
          _buildFlowStep(
            number: '3',
            title: loc.translate('step_validation'),
            desc: loc.translate('step_validation_desc'),
            icon: Icons.shield,
          ),
          _buildFlowArrow(),
          _buildFlowStep(
            number: '4',
            title: loc.translate('step_worth'),
            desc: loc.translate('step_worth_desc'),
            icon: Icons.verified_user,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPageTwo(AppLocalizations loc) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: AppSize.spacingXL),
            Text(
              loc.translate('proof_over_posts'),
              style: CustomTextStyle.size24W600(color: AppColors.white100),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSize.spacingS),
            Text(
              loc.translate('proof_over_posts_desc'),
              style: CustomTextStyle.size14W400(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSize.spacingXL),
            
            // Value Props List
            _buildValueItem(
              icon: Icons.directions_run,
              title: loc.translate('val_perform_actions'),
              desc: loc.translate('val_perform_actions_desc'),
            ),
            const SizedBox(height: AppSize.spacingL),
            _buildValueItem(
              icon: Icons.add_photo_alternate_outlined,
              title: loc.translate('val_upload_proof'),
              desc: loc.translate('val_upload_proof_desc'),
            ),
            const SizedBox(height: AppSize.spacingL),
            _buildValueItem(
              icon: Icons.people_outline,
              title: loc.translate('val_get_validated'),
              desc: loc.translate('val_get_validated_desc'),
            ),
            const SizedBox(height: AppSize.spacingL),
            _buildValueItem(
              icon: Icons.insights_outlined,
              title: loc.translate('val_build_reputation'),
              desc: loc.translate('val_build_reputation_desc'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowStep({
    required String number,
    required String title,
    required String desc,
    required IconData icon,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSize.paddingM),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(AppSize.radiusM),
        border: Border.all(color: AppColors.grey800),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: isLast ? AppColors.primaryGradient : null,
              color: isLast ? null : AppColors.grey800,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isLast ? AppColors.black100 : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSize.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number. $title',
                  style: CustomTextStyle.size15W600(color: AppColors.white100),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: CustomTextStyle.size12W400(color: AppColors.grey400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Icon(
        Icons.keyboard_double_arrow_down_rounded,
        color: AppColors.primary.withValues(alpha: 0.4),
        size: 20,
      ),
    );
  }

  Widget _buildValueItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSize.paddingM),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(AppSize.radiusM),
        border: Border.all(color: AppColors.grey800),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSize.radiusS),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSize.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CustomTextStyle.size15W600(color: AppColors.white100),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: CustomTextStyle.size12W400(color: AppColors.grey400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
