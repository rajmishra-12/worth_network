// lib/pages/auth/signup_screen.dart
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:worth_network/components/common/common_button.dart';
import 'package:worth_network/components/common/custom_textfield.dart';
import 'package:worth_network/components/common/language_toggle_button.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/constants/app_images.dart';
import 'package:worth_network/core/navigator/app_pages.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/pages/authentication/cubit/auth_cubit.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final pageContext = context;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.grey900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSize.radiusL),
        ),
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
                          content: Text(
                            'Profile picture size must be less than 2MB',
                          ),
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
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
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
                          content: Text(
                            'Profile picture size must be less than 2MB',
                          ),
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final authCubit = context.read<AuthCubit>();

    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: BlocListener<AuthCubit, AuthState>(
              listenWhen: (previous, current) =>
                  previous.isSignUpSuccess != current.isSignUpSuccess ||
                  previous.signUpError != current.signUpError,
              listener: (context, state) {
                if (state.isSignUpSuccess) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(loc.translate('account_created_success')),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  context.go(Routes.dashBoardScreen);
                } else if (state.signUpError != null &&
                    state.signUpError!.isNotEmpty) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(state.signUpError!),
                        backgroundColor: AppColors.error,
                      ),
                    );
                }
              },
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? AppSize.paddingL : 60.widthMultiplier,
                      vertical: AppSize.paddingL,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Language Toggle on Top Right & Back Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: AppColors.white100,
                              ),
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                            ),
                            const LanguageToggleButton(),
                          ],
                        ),

                        // Title
                        Center(
                          child: Column(
                            children: [
                              Image.asset(
                                AppIcons.crappLogo,
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: AppSize.spacingM),
                              Text(
                                loc.translate('create_account'),
                                style: CustomTextStyle.size22W500(
                                  color: AppColors.white100,
                                ),
                              ),
                              const SizedBox(height: AppSize.spacingS),
                              Text(
                                loc.translate('create_account_desc'),
                                textAlign: TextAlign.center,
                                style: CustomTextStyle.size14W400(
                                  color: AppColors.grey400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSize.spacingXL),

                        // Profile Photo (Optional)
                        Center(
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _profileImage == null
                                        ? AppColors.grey800
                                        : null,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                    image: _profileImage != null
                                        ? DecorationImage(
                                            image: FileImage(_profileImage!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _profileImage == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 50,
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
                        ),

                        const SizedBox(height: AppSize.spacingS),
                        Center(
                          child: Text(
                            loc.translate('profile_photo_optional'),
                            style: CustomTextStyle.size12W400(
                              color: AppColors.grey500,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSize.spacingXL),

                        // Full Name Field
                        Text(
                          loc.translate('full_name_title'),
                          style: CustomTextStyle.size14W500(
                            color: AppColors.white100,
                          ),
                        ),
                        const SizedBox(height: AppSize.spacingS),
                        CustomTextField(
                          controller: _fullNameController,
                          hintText: loc.translate('full_name_placeholder'),
                          useLabelText: false,
                          borderColor: AppColors.grey800,
                          backgroundColor: AppColors.grey900,
                          textStyle: CustomTextStyle.size15W400(
                            color: AppColors.white100,
                          ),
                          hintTextStyle: CustomTextStyle.size14W400(
                            color: AppColors.grey500,
                          ),
                          onChanged: authCubit.updateSignUpFullName,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            if (value.length < 3) {
                              return 'Name must be at least 3 characters';
                            }
                            return null;
                          },
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: AppColors.primary,
                          ),
                        ),
                        if (state.signUpFullNameError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSize.spacingS),
                            child: Text(
                              state.signUpFullNameError,
                              style: CustomTextStyle.size12W400(
                                color: AppColors.error,
                              ),
                            ),
                          ),

                        const SizedBox(height: AppSize.spacingL),

                        // Username Field
                        Text(
                          loc.translate('username_title'),
                          style: CustomTextStyle.size14W500(
                            color: AppColors.white100,
                          ),
                        ),
                        const SizedBox(height: AppSize.spacingS),
                        CustomTextField(
                          controller: _usernameController,
                          hintText: loc.translate('username_placeholder'),
                          useLabelText: false,
                          borderColor: AppColors.grey800,
                          backgroundColor: AppColors.grey900,
                          textStyle: CustomTextStyle.size15W400(
                            color: AppColors.white100,
                          ),
                          hintTextStyle: CustomTextStyle.size14W400(
                            color: AppColors.grey500,
                          ),
                          onChanged: authCubit.updateSignUpUsername,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9_]'),
                            ),
                            LengthLimitingTextInputFormatter(20),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please choose a username';
                            }
                            if (value.length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                              return 'Only letters, numbers, and underscores';
                            }
                            return null;
                          },
                          prefixIcon: const Icon(
                            Icons.alternate_email,
                            color: AppColors.primary,
                          ),
                        ),
                        if (state.signUpUsernameError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSize.spacingS),
                            child: Text(
                              state.signUpUsernameError,
                              style: CustomTextStyle.size12W400(
                                color: AppColors.error,
                              ),
                            ),
                          ),

                        const SizedBox(height: AppSize.spacingL),

                        // Email Field
                        Text(
                          loc.translate('email_title'),
                          style: CustomTextStyle.size14W500(
                            color: AppColors.white100,
                          ),
                        ),
                        const SizedBox(height: AppSize.spacingS),
                        CustomTextField(
                          controller: _emailController,
                          hintText: loc.translate('email_placeholder'),
                          useLabelText: false,
                          borderColor: AppColors.grey800,
                          backgroundColor: AppColors.grey900,
                          textStyle: CustomTextStyle.size15W400(
                            color: AppColors.white100,
                          ),
                          hintTextStyle: CustomTextStyle.size14W400(
                            color: AppColors.grey500,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: authCubit.updateSignUpEmail,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        if (state.signUpEmailError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSize.spacingS),
                            child: Text(
                              state.signUpEmailError,
                              style: CustomTextStyle.size12W400(
                                color: AppColors.error,
                              ),
                            ),
                          ),

                        const SizedBox(height: AppSize.spacingL),

                        // Password Field
                        Text(
                          loc.translate('password_title'),
                          style: CustomTextStyle.size14W500(
                            color: AppColors.white100,
                          ),
                        ),
                        const SizedBox(height: AppSize.spacingS),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: loc.translate('password_placeholder'),
                          useLabelText: false,
                          borderColor: AppColors.grey800,
                          backgroundColor: AppColors.grey900,
                          textStyle: CustomTextStyle.size15W400(
                            color: AppColors.white100,
                          ),
                          hintTextStyle: CustomTextStyle.size14W400(
                            color: AppColors.grey500,
                          ),
                          obscureText: !_showPassword,
                          onChanged: authCubit.updateSignUpPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppColors.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.grey500,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                        if (state.signUpPasswordError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSize.spacingS),
                            child: Text(
                              state.signUpPasswordError,
                              style: CustomTextStyle.size12W400(
                                color: AppColors.error,
                              ),
                            ),
                          ),

                        const SizedBox(height: AppSize.spacingL),

                        // Confirm Password Field
                        Text(
                          loc.translate('confirm_password_title'),
                          style: CustomTextStyle.size14W500(
                            color: AppColors.white100,
                          ),
                        ),
                        const SizedBox(height: AppSize.spacingS),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: loc.translate('confirm_password_placeholder'),
                          useLabelText: false,
                          borderColor: AppColors.grey800,
                          backgroundColor: AppColors.grey900,
                          textStyle: CustomTextStyle.size15W400(
                            color: AppColors.white100,
                          ),
                          hintTextStyle: CustomTextStyle.size14W400(
                            color: AppColors.grey500,
                          ),
                          obscureText: !_showConfirmPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppColors.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.grey500,
                            ),
                            onPressed: () {
                              setState(() {
                                _showConfirmPassword = !_showConfirmPassword;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: AppSize.spacingL),

                        // Terms and Conditions
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _acceptedTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptedTerms = value ?? false;
                                  });
                                  authCubit.updateTermsAccepted(_acceptedTerms);
                                },
                                activeColor: AppColors.primary,
                                checkColor: AppColors.black100,
                                side: const BorderSide(color: AppColors.grey700),
                              ),
                            ),
                            const SizedBox(width: AppSize.spacingS),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: loc.translate('agree_terms'),
                                  style: CustomTextStyle.size13W500(
                                    color: AppColors.grey400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: loc.translate('terms_of_service'),
                                      style: CustomTextStyle.size13W500(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: loc.translate('and_text'),
                                      style: CustomTextStyle.size13W500(
                                        color: AppColors.grey400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: loc.translate('privacy_policy'),
                                      style: CustomTextStyle.size13W500(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSize.spacingXL),

                        // Sign Up Button
                        CustomButton(
                          text: loc.translate('signup_button'),
                          isLoading: state.isLoading,
                          textStyle: CustomTextStyle.size16W600(
                            color: AppColors.black100,
                          ),
                          onTap: () {
                            if (_acceptedTerms) {
                              authCubit.signUp();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    loc.translate('accept_terms_warning'),
                                  ),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                            }
                          },
                        ),

                        const SizedBox(height: AppSize.spacingL),

                        // Login Link
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: loc.translate('already_have_account_signup'),
                              style: CustomTextStyle.size14W400(
                                color: AppColors.grey400,
                              ),
                              children: [
                                TextSpan(
                                  text: loc.translate('login_button'),
                                  style: CustomTextStyle.size14W600(
                                    color: AppColors.primary,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      context.push(Routes.loginScreen);
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSize.paddingL),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
