import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:worth_network/components/common/common_button.dart';
import 'package:worth_network/components/common/custom_textfield.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/pages/authentication/cubit/auth_cubit.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Reset Password',
          style: CustomTextStyle.size18W600(color: AppColors.white100),
        ),
      ),
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.isResetSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📩 Reset email sent! Please check your inbox.'),
                  backgroundColor: AppColors.success,
                ),
              );
              context.pop();
            } else if (state.resetError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.resetError!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSize.paddingL,
              vertical: AppSize.paddingXL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recover Account',
                  style: CustomTextStyle.size22W500(color: AppColors.white100),
                ),
                const SizedBox(height: AppSize.spacingS),
                Text(
                  'Enter your email address and we will send you a link to reset your password.',
                  style: CustomTextStyle.size14W400(color: AppColors.grey400),
                ),
                const SizedBox(height: 40),

                // Email Field
                Text(
                  'Email Address',
                  style: CustomTextStyle.size14W500(color: AppColors.white100),
                ),
                const SizedBox(height: AppSize.spacingS),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Enter your registered email',
                  useLabelText: false,
                  borderColor: AppColors.grey800,
                  backgroundColor: AppColors.grey900,
                  textStyle: CustomTextStyle.size15W400(color: AppColors.white100),
                  hintTextStyle: CustomTextStyle.size14W400(color: AppColors.grey500),
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                ),
                const SizedBox(height: 40),

                // Submit Button
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return CustomButton(
                      text: state.isLoading ? 'Sending Link...' : 'Send Reset Link',
                      isLoading: state.isLoading,
                      textStyle: CustomTextStyle.size16W600(color: AppColors.black100),
                      onTap: () {
                        context.read<AuthCubit>().resetPassword(_emailController.text);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
