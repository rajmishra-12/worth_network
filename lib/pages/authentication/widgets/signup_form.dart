// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:go_router/go_router.dart';
// import 'package:worth_network/components/common/clickable_button.dart';
// import 'package:worth_network/components/common/common_button.dart';
// import 'package:worth_network/components/common/custom_textfield.dart';
// import 'package:worth_network/components/common/dismiss_keyboard.dart';
// import 'package:worth_network/core/constants/app_images.dart';
// import 'package:worth_network/core/content/content_moderation_service.dart';
// import 'package:worth_network/core/navigator/app_pages.dart';
// import 'package:worth_network/core/theme/app_colors.dart';
// import 'package:worth_network/core/theme/app_size.dart';
// import 'package:worth_network/core/theme/app_text.dart';
// import 'package:worth_network/pages/authentication/cubit/auth_cubit.dart';
// import 'package:worth_network/pages/authentication/cubit/auth_state.dart';
// import 'package:worth_network/pages/authentication/widgets/terms_of_use.dart';

// class SignUpForm extends StatefulWidget {
//   const SignUpForm({super.key});

//   @override
//   State<SignUpForm> createState() => _SignUpFormState();
// }

// class _SignUpFormState extends State<SignUpForm> {
//   final TextEditingController fullnameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmpasswordController =
//       TextEditingController();
//   bool acceptedTerms = false;


//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 600;
//     final authCubit = context.read<AuthCubit>();

//     return BlocBuilder<AuthCubit, AuthState>(
//       builder: (context, state) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// Logo
//             Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset(AppIcons.appLogo, height: 150.heightMultiplier),
//                 ],
//               ),
//             ),

//             /// Title
//             Container(
//               padding: EdgeInsets.symmetric(
//                 vertical: 20.heightMultiplier,
//                 horizontal: isMobile ? 8.widthMultiplier : 50.widthMultiplier,
//               ),

//               decoration: BoxDecoration(
//                 color: AppColors.white100,
//                 borderRadius: BorderRadius.circular(24.radiusMultiplier),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Align(
//                           alignment:
//                               isMobile
//                                   ? Alignment.center
//                                   : Alignment.centerLeft,
//                           child: Column(
//                             crossAxisAlignment:
//                                 isMobile
//                                     ? CrossAxisAlignment.center
//                                     : CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Créez Votre Compte',
//                                 style: CustomTextStyle.size20W600(
//                                   color: AppColors.black100,
//                                 ),
//                               ),
//                               8.verticalSpace,
//                               Text(
//                                 'Entrez votre email et mot de passe pour vous inscrire',
//                                 style: CustomTextStyle.size14W400(
//                                   color: AppColors.greyShade,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   32.verticalSpace,

//                   /// Full Name
//                   Text(
//                     'Nom Complet',
//                     style: CustomTextStyle.size14W400(
//                       color: AppColors.greyShade,
//                     ),
//                   ),
//                   4.verticalSpace,
//                   CustomTextField(
//                     onChanged: authCubit.updateFullName,
//                     borderRadius: 12.radiusMultiplier,
//                     useLabelText: false,
//                     borderColor:
//                         isMobile ? AppColors.newborder : AppColors.transperent,
//                     controller: fullnameController,
//                     hintText: 'Entrez votre nom',

//                     errorText:
//                         state.fullNameError.isNotEmpty
//                             ? state.fullNameError
//                             : null,

//                     // suffixIcon: SvgPicture.asset(AppIcons.profile),
//                   ),

//                   16.verticalSpace,

//                   /// Email
//                   Text(
//                     'Adresse email',
//                     style: CustomTextStyle.size14W400(
//                       color: AppColors.greyShade,
//                     ),
//                   ),
//                   4.verticalSpace,
//                   CustomTextField(
//                     onChanged: authCubit.updateEmail,
//                     borderRadius: 12.radiusMultiplier,
//                     useLabelText: false,
//                     borderColor:
//                         isMobile ? AppColors.newborder : AppColors.transperent,
//                     controller: emailController,
//                     hintText: 'Entrez votre email',

//                     errorText:
//                         state.signupEmailError.isNotEmpty
//                             ? state.signupEmailError
//                             : null,

//                     suffixIcon: Icon(Icons.email, color: AppColors.icon),
//                   ),
//                   16.verticalSpace,

//                   /// Password
//                   Text(
//                     'Mot de passe',
//                     style: CustomTextStyle.size14W400(
//                       color: AppColors.greyShade,
//                     ),
//                   ),
//                   4.verticalSpace,
//                   CustomTextField(
//                     obscureText: !state.showSignUpPassword,
//                     onChanged: authCubit.updatePassword,
//                     borderRadius: 12.radiusMultiplier,
//                     maxlines: 1,
//                     useLabelText: false,
//                     borderColor:
//                         isMobile ? AppColors.newborder : AppColors.transperent,
//                     controller: passwordController,
//                     hintText: 'Entrez votre mot de passe',

//                     errorText:
//                         state.signupPasswordError.isNotEmpty
//                             ? state.signupPasswordError
//                             : null,
//                     suffixIcon: ClickableButton(
//                       onTap: () {
//                         authCubit.toggleShowSignUpPassword();
//                       },
//                       child: Icon(
//                         state.showSignUpPassword
//                             ? Icons.visibility
//                             : Icons.visibility_off,
//                         color: AppColors.icon,
//                       ),
//                     ),
//                   ),

//                   16.verticalSpace,

//                   /// Confirm Password
//                   Text(
//                     'Confirmez le mot de passe',
//                     style: CustomTextStyle.size14W400(
//                       color: AppColors.greyShade,
//                     ),
//                   ),
//                   4.verticalSpace,
//                   CustomTextField(
//                     obscureText: !state.showConfSignUpPassword,
//                     onChanged: authCubit.updateConfirmPassword,
//                     maxlines: 1,
//                     borderRadius: 12.radiusMultiplier,
//                     useLabelText: false,
//                     borderColor:
//                         isMobile ? AppColors.newborder : AppColors.transperent,
//                     controller: confirmpasswordController,
//                     hintText: 'Confirmez votre mot de passe',

//                     errorText:
//                         state.confirmPasswordError.isNotEmpty
//                             ? state.confirmPasswordError
//                             : null,
//                     suffixIcon: ClickableButton(
//                       onTap: () {
//                         authCubit.toggleShowConfSignUpPassword();
//                       },
//                       child: Icon(
//                         state.showConfSignUpPassword
//                             ? Icons.visibility
//                             : Icons.visibility_off,
//                         color: AppColors.icon,
//                       ),
//                     ),
//                   ),

//                   8.verticalSpace,

//                   Text(
//                     'Utilisez au moins 6 caractères avec une lettre majuscule',
//                     style: CustomTextStyle.size10W400(
//                       color: AppColors.greyShade,
//                     ),
//                   ),
//                   16.verticalSpace,
//  CheckboxListTile(
//   value: acceptedTerms,
//   activeColor: AppColors.primary,
//   onChanged: (value) {
//     setState(() {
//       acceptedTerms = value ?? false;
//     });
//   },
//   controlAffinity: ListTileControlAffinity.leading,
//   contentPadding: EdgeInsets.zero,
//   dense: true,
//   title: GestureDetector(
//     onTap: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const TermsOfUsePage(),
//         ),
//       );
//     },
//     child: RichText(
//       text: TextSpan(
//         style: CustomTextStyle.size14W400(
//           color: AppColors.greyShade,
//         ),
//         children: [
//           const TextSpan(
//             text: 'I have read and agree to the ',
//           ),
//           TextSpan(
//             text: 'Terms of Use / Conditions d’utilisation',
//             style: CustomTextStyle.size14W500(
//               color: AppColors.primary,
             
//             ).copyWith(
//                decoration: TextDecoration.underline,
//             ),
//           ),
//         ],
//       ),
//     ),
//   ),
// ),


// 16.verticalSpace,

//                   /// Sign Up Button
//                   CustomButton(
//                     text: 'S\'inscrire',
//                     isLoading: state.isLoading,
//                     textStyle: CustomTextStyle.size14W500(
//                       color: AppColors.white100,
//                     ),
//                   onTap: () async {
//   if (!acceptedTerms) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("Vous devez accepter les conditions d'utilisation pour continuer / You must accept the Terms of Use to continue"),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//     return;
//   }

//   final name = fullnameController.text.trim();


//   if (name.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Le nom complet est requis.")),
//     );
//     return;
//   }

  
//   final ok = await ModerationUiHelper.validateAndShow(
//     context,
//     name,
//     message: "Le nom contient un mot interdit.",
//     closeBeforeShow: false,
//   );
//   if (!ok) return;

//   authCubit.signUp();
// },


//                   ),

//                   24.verticalSpace,

//                   /// Login Link
//                   Center(
//                     child: RichText(
//                       text: TextSpan(
//                         text: 'Vous avez déjà un compte ? ',
//                         style: CustomTextStyle.size14W400(
//                           color: AppColors.greyShade,
//                         ),
//                         children: [
//                           TextSpan(
//                             text: 'Se connecter',
//                             style: CustomTextStyle.size14W500(
//                               color: AppColors.primary,
//                             ),
//                             recognizer:
//                                 TapGestureRecognizer()
//                                   ..onTap = () {
//                                     context.go(Routes.loginScreen);
//                                   },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
