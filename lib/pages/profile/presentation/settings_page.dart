import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:worth_network/components/common/language_toggle_button.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/navigator/app_pages.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/pages/authentication/cubit/auth_cubit.dart';
import 'package:worth_network/pages/profile/cubit/profile_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _profilePrivate = false;
  bool _hideScore = false;
  bool _allowInvites = true;

  void _showLogoutDialog(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.grey900,
        title: Text(
          loc.translate('logout_dialog_title'),
          style: CustomTextStyle.size18W600(color: AppColors.white100),
        ),
        content: Text(
          loc.translate('logout_dialog_desc'),
          style: CustomTextStyle.size14W400(color: AppColors.grey400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              loc.translate('cancel'),
              style: CustomTextStyle.size14W500(color: AppColors.grey400),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
              context.go(Routes.loginScreen);
            },
            child: Text(
              loc.translate('logout_btn'),
              style: CustomTextStyle.size14W600(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.grey900,
        title: Text(
          loc.translate('delete_account_dialog_title'),
          style: CustomTextStyle.size18W600(color: AppColors.error),
        ),
        content: Text(
          loc.translate('delete_account_dialog_desc'),
          style: CustomTextStyle.size14W400(color: AppColors.grey300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              loc.translate('cancel'),
              style: CustomTextStyle.size14W500(color: AppColors.grey400),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await context.read<AuthCubit>().deleteAccount();
                if (mounted) {
                  context.go(Routes.loginScreen);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete account: $e')),
                  );
                }
              }
            },
            child: Text(
              loc.translate('delete_account_btn'),
              style: CustomTextStyle.size14W600(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.grey900,
        title: Text(
          loc.translate('about_worth_popup_title'),
          style: CustomTextStyle.size18W600(color: AppColors.white100),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.translate('about_worth_popup_text'),
                style: CustomTextStyle.size13W400(color: AppColors.grey300),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              loc.translate('dismiss'),
              style: CustomTextStyle.size14W600(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        final currentUserEmail = FirebaseAuth.instance.currentUser?.email?.toLowerCase();
        final profileState = context.watch<ProfileCubit>().state;
        final isAdmin = currentUserEmail == 'admin@gmail.com' ||
            (profileState.profile != null &&
                (profileState.profile!.roles.contains('admin') || profileState.profile!.accountType == 'admin'));

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
              loc.translate('settings_title'),
              style: CustomTextStyle.size18W600(color: AppColors.white100),
            ),
            actions: [
              const Padding(
                padding: EdgeInsets.only(right: AppSize.paddingM),
                child: Center(child: LanguageToggleButton()),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
            children: [
              // Edit Profile Option
              _buildSettingsHeader(loc.translate('sec_account')),
              _buildSettingsTile(
                icon: Icons.person_outline,
                title: loc.translate('edit_profile_details'),
                subtitle: loc.translate('edit_profile_desc'),
                onTap: () {
                  context.pushNamed(Routes.profilesetup);
                },
              ),
              const SizedBox(height: AppSize.spacingL),

              // Safety & Moderation Section
              _buildSettingsHeader('Safety & Moderation'),
              _buildSettingsTile(
                icon: Icons.block,
                title: 'Blocked Users',
                subtitle: 'Manage users you have blocked',
                onTap: () {
                  context.push('/blocked-users');
                },
              ),
              if (isAdmin)
                _buildSettingsTile(
                  icon: Icons.admin_panel_settings,
                  title: 'Admin Moderation Console',
                  subtitle: 'Review reports, word filters & moderation logs',
                  onTap: () {
                    context.push('/admin');
                  },
                ),
              const SizedBox(height: AppSize.spacingL),

              // About & Policy Settings
              _buildSettingsHeader(loc.translate('sec_general')),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: loc.translate('about_worth_concept'),
                subtitle: loc.translate('about_worth_desc'),
                onTap: () => _showAboutDialog(loc),
              ),
              _buildSettingsTile(
                icon: Icons.security_outlined,
                title: loc.translate('privacy_policy'),
                subtitle: loc.translate('privacy_policy_desc'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.translate('privacy_policy_coming_soon')),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSize.spacingXL),

              // Logout & Delete Account Actions
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.paddingS,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(loc),
                        icon: const Icon(Icons.logout, color: AppColors.primary),
                        label: Text(
                          loc.translate('logout_btn'),
                          style: CustomTextStyle.size15W600(color: AppColors.primary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSize.radiusM),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSize.paddingM,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSize.spacingM),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeleteAccountDialog(loc),
                        icon: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
                        label: Text(
                          loc.translate('delete_account_btn'),
                          style: CustomTextStyle.size15W600(color: AppColors.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSize.radiusM),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSize.paddingM,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSize.paddingXL),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSize.paddingS,
        top: AppSize.paddingM,
        bottom: AppSize.paddingS,
      ),
      child: Text(
        title.toUpperCase(),
        style: CustomTextStyle.size12W600(color: AppColors.primary),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSize.paddingS),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(AppSize.radiusM),
        border: Border.all(color: AppColors.grey800),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: CustomTextStyle.size14W600(color: AppColors.white100),
        ),
        subtitle: Text(
          subtitle,
          style: CustomTextStyle.size12W400(color: AppColors.grey500),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.grey500),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSize.paddingS),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(AppSize.radiusM),
        border: Border.all(color: AppColors.grey800),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: CustomTextStyle.size14W600(color: AppColors.white100),
        ),
        subtitle: Text(
          subtitle,
          style: CustomTextStyle.size12W400(color: AppColors.grey500),
        ),
        value: value,
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
        inactiveThumbColor: AppColors.grey500,
        inactiveTrackColor: AppColors.grey800,
        onChanged: onChanged,
      ),
    );
  }
}
