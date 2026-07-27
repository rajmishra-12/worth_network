import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              listener: (context, state) {
                if (state.isSignInSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.translate('welcome_back')),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  context.go(Routes.dashBoardScreen);
                } else if (state.signInError != null && state.signInError!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.signInError!),
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
                      vertical: AppSize.paddingXL,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Language Toggle on Top Right
                        Align(
                          alignment: Alignment.centerRight,
                          child: const LanguageToggleButton(),
                        ),
                        const SizedBox(height: AppSize.spacingM),

                        Image.asset(
                          AppIcons.appLogo,
                          width: 350.widthMultiplier,
                        ),
                        
                        // Email / Username Field
                        Text(
                          loc.translate('login_title'),
                          style: CustomTextStyle.size14W500(color: AppColors.white100),
                        ),
                        const SizedBox(height: AppSize.spacingS),
                        CustomTextField(
                          controller: _emailController,
                          hintText: loc.translate('login_placeholder'),
                          useLabelText: false,
                          borderColor: AppColors.grey800,
                          backgroundColor: AppColors.grey900,
                          textStyle: CustomTextStyle.size15W400(color: AppColors.white100),
                          hintTextStyle: CustomTextStyle.size14W400(color: AppColors.grey500),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: authCubit.updateLoginEmail,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return loc.translate('enter_email_error');
                            }
                            return null;
                          },
                          prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                        ),
                        if (state.loginEmailError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSize.spacingS),
                            child: Text(
                              state.loginEmailError,
                              style: CustomTextStyle.size12W400(color: AppColors.error),
                            ),
                          ),
                        
                        const SizedBox(height: AppSize.spacingL),
                        
                        // Password Field
                        Text(
                          loc.translate('password_title'),
                          style: CustomTextStyle.size14W500(color: AppColors.white100),
                        ),
                        const SizedBox(height: AppSize.spacingS),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: loc.translate('password_placeholder'),
                          useLabelText: false,
                          borderColor: AppColors.grey800,
                          backgroundColor: AppColors.grey900,
                          textStyle: CustomTextStyle.size15W400(color: AppColors.white100),
                          hintTextStyle: CustomTextStyle.size14W400(color: AppColors.grey500),
                          obscureText: !_showPassword,
                          onChanged: authCubit.updateLoginPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return loc.translate('enter_password_error');
                            }
                            return null;
                          },
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword ? Icons.visibility : Icons.visibility_off,
                              color: AppColors.grey500,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                        if (state.loginPasswordError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSize.spacingS),
                            child: Text(
                              state.loginPasswordError,
                              style: CustomTextStyle.size12W400(color: AppColors.error),
                            ),
                          ),
                        
                        const SizedBox(height: AppSize.spacingM),
                        
                        // Remember Me & Forgot Password Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Remember Me Checkbox
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    activeColor: AppColors.primary,
                                    checkColor: AppColors.black100,
                                    side: const BorderSide(color: AppColors.grey700),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                const SizedBox(width: AppSize.spacingS),
                                Text(
                                  loc.translate('remember_me'),
                                  style: CustomTextStyle.size13W500(
                                    color: AppColors.grey400,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Forgot Password Button
                            GestureDetector(
                              onTap: () {
                                context.push(Routes.forgetPasswordScreen);
                              },
                              child: Text(
                                loc.translate('forgot_password'),
                                style: CustomTextStyle.size13W500(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: AppSize.spacingXL),
                        
                        // Login Button
                        CustomButton(
                          text: loc.translate('login_button'),
                          isLoading: state.isLoading,
                          textStyle: CustomTextStyle.size16W600(color: AppColors.black100),
                          onTap: () {
                            if (_emailController.text.isEmpty) {
                              authCubit.updateLoginEmailError(loc.translate('enter_email_error'));
                              return;
                            }
                            if (_passwordController.text.isEmpty) {
                              authCubit.updateLoginPasswordError(loc.translate('enter_password_error'));
                              return;
                            }
                            
                            authCubit.signIn(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                          },
                        ),
                        
                        const SizedBox(height: AppSize.spacingXL),
                        
                        // Sign Up Link
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                loc.translate('dont_have_account'),
                                style: CustomTextStyle.size14W400(color: AppColors.grey400),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.push(Routes.signupScreen);
                                },
                                child: Text(
                                  loc.translate('signup_button'),
                                  style: CustomTextStyle.size14W600(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: AppSize.paddingL),
                        
                        // Version Info
                        Center(
                          child: Text(
                            'Version 1.0.0',
                            style: CustomTextStyle.size10W400(color: AppColors.grey700),
                          ),
                        ),
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