import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:worth_network/core/navigator/app_pages.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/preferences.dart';
import 'package:worth_network/pages/authentication/cubit/auth_cubit.dart';

import 'package:worth_network/core/constants/profile_constants.dart';
import 'package:worth_network/pages/profile/cubit/profile_cubit.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  bool _isLoading = false;
  String? _currentAvatarUrl;
  String? _selectedAccountType;
  final List<String> _selectedRoles = [];

  @override
  void initState() {
    super.initState();
    _usernameController.text = Preferences().username;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        final data = doc.data();
        if (data != null) {
          setState(() {
            _usernameController.text = data['username'] ?? '';
            _bioController.text = data['bio'] ?? '';
            _currentAvatarUrl = data['avatarUrl'];
            _selectedAccountType = data['accountType'];
            if (data['roles'] != null) {
              _selectedRoles.clear();
              _selectedRoles.addAll(List<String>.from(data['roles']));
            }
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pageContext = context;
    showModalBottomSheet(
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
              title: Text(
                'Take a photo',
                style: CustomTextStyle.size15W500(color: AppColors.white100),
              ),
              onTap: () async {
                final authCubit = pageContext.read<AuthCubit>();
                Navigator.pop(context);
                final XFile? photo = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (photo != null) {
                  final file = File(photo.path);
                  final double sizeInMb = file.lengthSync() / (1024 * 1024);
                  if (sizeInMb > 2.0) {
                    if (pageContext.mounted) {
                      ScaffoldMessenger.of(pageContext).showSnackBar(
                        const SnackBar(
                          content: Text('Profile picture size must be less than 2MB'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                    return;
                  }
                  setState(() {
                    _profileImage = file;
                  });
                  authCubit.updateProfileImage(file);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: Text(
                'Choose from gallery',
                style: CustomTextStyle.size15W500(color: AppColors.white100),
              ),
              onTap: () async {
                final authCubit = pageContext.read<AuthCubit>();
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (image != null) {
                  final file = File(image.path);
                  final double sizeInMb = file.lengthSync() / (1024 * 1024);
                  if (sizeInMb > 2.0) {
                    if (pageContext.mounted) {
                      ScaffoldMessenger.of(pageContext).showSnackBar(
                        const SnackBar(
                          content: Text('Profile picture size must be less than 2MB'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                    return;
                  }
                  setState(() {
                    _profileImage = file;
                  });
                  authCubit.updateProfileImage(file);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username is required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final repo = context.read<AuthCubit>().repository;
        await repo.updateProfile(
          uid: uid,
          username: username,
          bio: _bioController.text.trim(),
          accountType: _selectedAccountType,
          roles: _selectedRoles,
          profileImage: _profileImage,
        );

        if (mounted) {
          context.read<ProfileCubit>().loadProfile();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile completed successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go(Routes.dashBoardScreen);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSize.paddingL,
            vertical: AppSize.paddingXL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Setup Profile',
                style: CustomTextStyle.size24W600(color: AppColors.white100),
              ),
              const SizedBox(height: AppSize.spacingS),
              Text(
                'Complete your public presence on the Worth Network.',
                style: CustomTextStyle.size14W400(color: AppColors.grey400),
              ),
              const SizedBox(height: AppSize.spacingXL),

              // Profile Photo Selector
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.grey900,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              image: _profileImage != null
                                  ? DecorationImage(
                                      image: FileImage(_profileImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : (_currentAvatarUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(_currentAvatarUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null),
                            ),
                            child: _profileImage == null && _currentAvatarUrl == null
                                ? const Icon(
                                    Icons.person_outline,
                                    size: 55,
                                    color: AppColors.grey500,
                                  )
                                : null,
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
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: AppColors.black100,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSize.spacingS),
                    Text(
                      'Choose Profile Picture',
                      style: CustomTextStyle.size13W500(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSize.spacingXL),

              // Username Form field
              Text(
                'Username',
                style: CustomTextStyle.size14W500(color: AppColors.white100),
              ),
              const SizedBox(height: AppSize.spacingS),
              TextField(
                controller: _usernameController,
                style: CustomTextStyle.size15W400(color: AppColors.white100),
                decoration: InputDecoration(
                  hintText: 'Enter username',
                  hintStyle: CustomTextStyle.size14W400(color: AppColors.grey500),
                  filled: true,
                  fillColor: AppColors.grey900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.radiusM),
                    borderSide: const BorderSide(color: AppColors.grey800),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.radiusM),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  prefixIcon: const Icon(Icons.alternate_email, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSize.spacingL),

              // Bio Form field
              Text(
                'Bio',
                style: CustomTextStyle.size14W500(color: AppColors.white100),
              ),
              const SizedBox(height: AppSize.spacingS),
              TextField(
                controller: _bioController,
                maxLines: 3,
                style: CustomTextStyle.size15W400(color: AppColors.white100),
                decoration: InputDecoration(
                  hintText: 'Tell us about yourself...',
                  hintStyle: CustomTextStyle.size14W400(color: AppColors.grey500),
                  filled: true,
                  fillColor: AppColors.grey900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.radiusM),
                    borderSide: const BorderSide(color: AppColors.grey800),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.radiusM),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppSize.spacingL),

              // Account Type (Optional)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Account Type',
                    style: CustomTextStyle.size14W500(color: AppColors.white100),
                  ),
                  Text(
                    'Optional',
                    style: CustomTextStyle.size12W400(color: AppColors.grey500),
                  ),
                ],
              ),
              const SizedBox(height: AppSize.spacingS),
              DropdownButtonFormField<String>(
                initialValue: _selectedAccountType,
                dropdownColor: AppColors.grey900,
                style: CustomTextStyle.size14W400(color: AppColors.white100),
                decoration: InputDecoration(
                  hintText: 'Select type (e.g. Particular, NGO, Business)',
                  hintStyle: CustomTextStyle.size14W400(color: AppColors.grey500),
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
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Not Specified', style: TextStyle(color: AppColors.grey500)),
                  ),
                  ...ProfileConstants.accountTypes.map(
                    (type) => DropdownMenuItem<String>(
                      value: type.key,
                      child: Row(
                        children: [
                          Icon(type.icon, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(type.label, style: const TextStyle(color: AppColors.white100)),
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
              const SizedBox(height: AppSize.spacingL),

              // Roles & Domains (Optional Multi-select)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Roles & Domains',
                    style: CustomTextStyle.size14W500(color: AppColors.white100),
                  ),
                  Text(
                    'Optional (Multi-select)',
                    style: CustomTextStyle.size12W400(color: AppColors.grey500),
                  ),
                ],
              ),
              const SizedBox(height: AppSize.spacingS),
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
                          size: 15,
                          color: isSelected ? AppColors.black100 : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(role.label),
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
              const SizedBox(height: 40),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.black100,
                    disabledBackgroundColor: AppColors.grey800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSize.radiusM),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.black100)
                      : Text(
                          'Save & Continue',
                          style: CustomTextStyle.size16W600(color: AppColors.black100),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
