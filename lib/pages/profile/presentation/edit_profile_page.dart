import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/constants/profile_constants.dart';
import 'package:worth_network/core/repo/auth_repo.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/core/utils/preferences.dart';
import 'package:worth_network/pages/profile/cubit/profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  File? _newAvatarFile;
  String? _currentAvatarUrl;
  String? _selectedAccountType;
  final List<String> _selectedRoles = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = Preferences();

    _nameController.text = prefs.name;
    _emailController.text = user?.email ?? prefs.email;
    _usernameController.text = prefs.username.isNotEmpty ? '@${prefs.username}' : '@user';

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          _nameController.text = data['name'] ?? _nameController.text;
          _bioController.text = data['bio'] ?? '';
          final uname = data['username'] ?? prefs.username;
          _usernameController.text = uname.isNotEmpty ? '@$uname' : '@user';
          _currentAvatarUrl = data['avatarUrl'];
          _selectedAccountType = data['accountType'];
          if (data['roles'] != null) {
            _selectedRoles.clear();
            _selectedRoles.addAll(List<String>.from(data['roles']));
          }
        }
      } catch (e) {
        print('Error loading user profile: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAvatar() async {
    final loc = AppLocalizations(context.read<LocaleCubit>().state);
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.grey900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.radiusL)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text(loc.translate('take_photo'), style: CustomTextStyle.size15W500(color: AppColors.white100)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: Text(loc.translate('choose_from_gallery'), style: CustomTextStyle.size15W500(color: AppColors.white100)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 70, // Compressed image quality
        maxWidth: 800,
        maxHeight: 800,
      );

      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.length();
        // Validation: max 10MB limit
        if (bytes > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.translate('image_size_exceeds_limit')),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        setState(() {
          _newAvatarFile = file;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = Preferences();
    final loc = AppLocalizations(context.read<LocaleCubit>().state);

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final newName = _nameController.text.trim();
      final newBio = _bioController.text.trim();
      final newUsername = _usernameController.text.trim();

      // Update user profile and sync past actions in Firestore
      if (user != null) {
        final repo = AuthRepository();
        await repo.updateProfile(
          uid: user.uid,
          username: newUsername,
          bio: newBio,
          name: newName,
          accountType: _selectedAccountType,
          roles: _selectedRoles,
          profileImage: _newAvatarFile,
        );
      }

      // Update Local Preferences
      prefs.name = newName;

      if (mounted) {
        context.read<ProfileCubit>().loadProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('profile_updated_success')),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        final errorMsg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              loc.translate('edit_profile_title'),
              style: CustomTextStyle.size18W600(color: AppColors.white100),
            ),
            actions: [
              TextButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : Text(
                        loc.translate('save_btn'),
                        style: CustomTextStyle.size15W600(color: AppColors.primary),
                      ),
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSize.paddingL),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar Picker
                        Center(
                          child: GestureDetector(
                            onTap: _pickAvatar,
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primary, width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: AppColors.grey800,
                                    backgroundImage: _newAvatarFile != null
                                        ? FileImage(_newAvatarFile!)
                                        : (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                                            ? NetworkImage(_currentAvatarUrl!)
                                            : null) as ImageProvider?,
                                    child: _newAvatarFile == null &&
                                            (_currentAvatarUrl == null || _currentAvatarUrl!.isEmpty)
                                        ? Text(
                                            _nameController.text.isNotEmpty
                                                ? _nameController.text[0].toUpperCase()
                                                : 'U',
                                            style: CustomTextStyle.size30W600(color: AppColors.white100),
                                          )
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt, size: 16, color: AppColors.black100),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.translate('tap_to_change_avatar'),
                          style: CustomTextStyle.size12W400(color: AppColors.grey500),
                        ),
                        const SizedBox(height: AppSize.spacingXL),

                        // Full Name (Editable)
                        _buildInputField(
                          label: loc.translate('full_name_label'),
                          controller: _nameController,
                          enabled: true,
                          loc: loc,
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? loc.translate('full_name_required') : null,
                        ),
                        const SizedBox(height: AppSize.spacingL),

                        // Bio (Editable)
                        _buildInputField(
                          label: loc.translate('bio_label'),
                          controller: _bioController,
                          enabled: true,
                          loc: loc,
                          maxLines: 3,
                          hint: loc.translate('bio_placeholder'),
                        ),
                        const SizedBox(height: AppSize.spacingL),

                        // Account Type (Optional)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.translate('account_type_label'),
                                  style: CustomTextStyle.size14W600(color: AppColors.white100),
                                ),
                                Text(
                                  loc.translate('optional'),
                                  style: CustomTextStyle.size11W400(color: AppColors.grey500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedAccountType,
                              dropdownColor: AppColors.grey900,
                              style: CustomTextStyle.size14W400(color: AppColors.white100),
                              decoration: InputDecoration(
                                hintText: loc.translate('select_account_type_hint'),
                                hintStyle: CustomTextStyle.size14W400(color: AppColors.grey600),
                                filled: true,
                                fillColor: AppColors.grey900,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text(loc.translate('not_specified'), style: const TextStyle(color: AppColors.grey500)),
                                ),
                                ...ProfileConstants.accountTypes.map(
                                  (type) => DropdownMenuItem<String>(
                                    value: type.key,
                                    child: Row(
                                      children: [
                                        Icon(type.icon, size: 18, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Text(type.getLocalizedLabel(loc), style: const TextStyle(color: AppColors.white100)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedAccountType = val;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSize.spacingL),

                        // Roles & Domains (Optional Multi-select)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.translate('roles_domains_label'),
                                  style: CustomTextStyle.size14W600(color: AppColors.white100),
                                ),
                                Text(
                                  loc.translate('optional_multi_select'),
                                  style: CustomTextStyle.size11W400(color: AppColors.grey500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ProfileConstants.roles.map((role) {
                                final isSelected = _selectedRoles.contains(role.key);
                                return FilterChip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        role.icon,
                                        size: 14,
                                        color: isSelected ? AppColors.black100 : AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(role.getLocalizedLabel(loc)),
                                    ],
                                  ),
                                  selected: isSelected,
                                  selectedColor: AppColors.primary,
                                  backgroundColor: AppColors.grey900,
                                  checkmarkColor: AppColors.black100,
                                  labelStyle: CustomTextStyle.size12W500(
                                    color: isSelected ? AppColors.black100 : AppColors.white100,
                                  ),
                                  side: BorderSide(
                                    color: isSelected ? AppColors.primary : AppColors.grey800,
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedRoles.add(role.key);
                                      } else {
                                        _selectedRoles.remove(role.key);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSize.spacingL),

                        // Username (Read-Only / Disabled)
                        _buildInputField(
                          label: loc.translate('username_label'),
                          controller: _usernameController,
                          enabled: false,
                          lockIcon: true,
                          loc: loc,
                          helperText: loc.translate('username_helper'),
                        ),
                        const SizedBox(height: AppSize.spacingL),

                        // Email Address (Read-Only / Disabled)
                        _buildInputField(
                          label: loc.translate('email_label'),
                          controller: _emailController,
                          enabled: false,
                          lockIcon: true,
                          loc: loc,
                          helperText: loc.translate('email_helper'),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required AppLocalizations loc,
    bool enabled = true,
    bool lockIcon = false,
    int maxLines = 1,
    String? hint,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: CustomTextStyle.size14W600(color: AppColors.white100),
            ),
            if (lockIcon)
              Row(
                children: [
                  const Icon(Icons.lock_outline, size: 14, color: AppColors.grey500),
                  const SizedBox(width: 4),
                  Text(
                    loc.translate('read_only'),
                    style: CustomTextStyle.size11W400(color: AppColors.grey500),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          style: CustomTextStyle.size14W400(
            color: enabled ? AppColors.white100 : AppColors.grey500,
          ),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: CustomTextStyle.size14W400(color: AppColors.grey600),
            filled: true,
            fillColor: enabled ? AppColors.grey900 : AppColors.grey900.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.radiusM),
              borderSide: const BorderSide(color: AppColors.grey800),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.radiusM),
              borderSide: const BorderSide(color: AppColors.grey800),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.radiusM),
              borderSide: BorderSide(color: AppColors.grey800.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.radiusM),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: CustomTextStyle.size11W400(color: AppColors.grey500),
          ),
        ],
      ],
    );
  }
}
