// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:worth_network/components/common/clickable_button.dart';
// import 'package:worth_network/components/common/common_button.dart';
// import 'package:worth_network/components/common/custom_textfield.dart';
// import 'package:worth_network/components/common/dismiss_keyboard.dart';
// import 'package:worth_network/core/constants/app_images.dart';
// import 'package:worth_network/core/navigator/app_pages.dart';
// import 'package:worth_network/core/theme/app_colors.dart';
// import 'package:worth_network/core/theme/app_size.dart';
// import 'package:worth_network/core/theme/app_text.dart';
// import 'package:worth_network/pages/authentication/cubit/auth_cubit.dart';
// import 'package:worth_network/pages/authentication/cubit/auth_state.dart';

// class LoginForm extends StatefulWidget {
//   const LoginForm({super.key});

//   @override
//   State<LoginForm> createState() => _LoginFormState();
// }

// class _LoginFormState extends State<LoginForm> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool rememberMe = false;

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 600;
//     final authCubit = context.read<AuthCubit>();
//     return BlocBuilder<AuthCubit, AuthState>(
//       builder: (context, state) {
//         return DismissKeyboard(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// Logo
//               Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset(AppIcons.appLogo, height: 150.heightMultiplier),
//                   ],
//                 ),
//               ),

//               /// Title
//               Container(
//                 padding: EdgeInsets.symmetric(
//                   vertical: 20.heightMultiplier,
//                   horizontal: isMobile ? 8.widthMultiplier : 60.widthMultiplier,
//                 ),

//                 decoration: BoxDecoration(
//                   color: AppColors.white100,
//                   borderRadius: BorderRadius.circular(24.radiusMultiplier),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Align(
//                       alignment:
//                           isMobile ? Alignment.center : Alignment.centerLeft,
//                       child: Column(
//                         crossAxisAlignment:
//                             isMobile
//                                 ? CrossAxisAlignment.center
//                                 : CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Connectez-vous à votre compte', // Log In To Your Account
//                             textAlign: TextAlign.center,
//                             style: CustomTextStyle.size20W600(
//                               color: AppColors.black100,
//                             ),
//                           ),
//                           8.verticalSpace,
//                           Text(
//                             'Entrez votre email et mot de passe pour vous connecter', // Enter your email and password to log in
//                             textAlign: TextAlign.center,
//                             style: CustomTextStyle.size14W400(
//                               color: AppColors.greyShade,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     32.verticalSpace,

//                     /// Email
//                     Text(
//                       'Email', // Enter Email
//                       style: CustomTextStyle.size14W400(
//                         color: AppColors.greyShade,
//                       ),
//                     ),
//                     4.verticalSpace,
//                     CustomTextField(
//                       onChanged: authCubit.updateLoginEmail,
//                       borderRadius: 12.radiusMultiplier,
//                       useLabelText: false,
//                       borderColor: AppColors.primary2,
//                       controller: emailController,
//                       hintText: 'Entrez votre email', // Enter Email

//                       errorText:
//                           state.loginEmailError.isNotEmpty
//                               ? state.loginEmailError
//                               : null,
//                       suffixIcon: Icon(Icons.email, color: AppColors.primary),
//                     ),

//                     16.verticalSpace,

//                     /// Password
//                     Text(
//                       'Mot de passe', // Enter Password
//                       style: CustomTextStyle.size14W400(
//                         color: AppColors.greyShade,
//                       ),
//                     ),
//                     4.verticalSpace,
//                     CustomTextField(
//                       obscureText: !state.showLoginPassword,
//                       maxlines: 1,
//                       onChanged: authCubit.updateLoginPassword,
//                       borderRadius: 12.radiusMultiplier,
//                       useLabelText: false,
//                       borderColor: AppColors.primary2,
//                       controller: passwordController,
//                       hintText: 'Entrez votre mot de passe', // Enter Password
//                       // backgroundColor: AppColors.tbackground,
//                       errorText:
//                           state.loginPasswordError.isNotEmpty
//                               ? state.loginPasswordError
//                               : null,
//                       suffixIcon: ClickableButton(
//                         onTap: () {
//                           authCubit.toggleShowLoginPassword();
//                         },
//                         child: Icon(
//                           state.showLoginPassword
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                     ),
//                     // 4.verticalSpace,
//                     24.verticalSpace,

//                     /// Remember Me + Forgot
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             SizedBox(
//                               width: 20.widthMultiplier,
//                               height: 20.heightMultiplier,
//                               child: Checkbox(
//                                 value: rememberMe,
//                                 activeColor: AppColors.primary,
//                                 side: BorderSide(color: AppColors.primary2),
//                                 materialTapTargetSize:
//                                     MaterialTapTargetSize.shrinkWrap,
//                                 // <= important!
//                                 onChanged: (val) {
//                                   setState(() {
//                                     rememberMe = val ?? false;
//                                   });
//                                 },
//                               ),
//                             ),
//                             10.horizontalSpace,
//                             Text(
//                               'Se souvenir de moi', // Remember Me
//                               style: CustomTextStyle.size14W400(
//                                 color: AppColors.black100,
//                               ),
//                             ),
//                           ],
//                         ),

//                         InkWell(
//                           onTap: () {
//                             context.pushNamed(Routes.forgetPasswordScreen);
//                           },
//                           child: Text(
//                             'Mot de passe oublié ?', // Forget Password?
//                             style: CustomTextStyle.size14W400(
//                               color: AppColors.primary,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     24.verticalSpace,

//                     /// Login Btn
//                     CustomButton(
//                       text: 'Se connecter', // Log In
//                       isLoading: state.isLoading,
//                       textStyle: CustomTextStyle.size14W500(
//                         color: AppColors.white100,
//                       ),
//                       onTap: () {
//                         // final validateLogin = authCubit.validateSignin();
//                         // if (validateLogin) {
//                         authCubit.signIn(
//                           email: state.loginemail,
//                           password: state.loginpassword,
//                         );
//                         // }

//                         // if (authCubit.validate()) {
//                         // Pages.appRouter.goNamed(Routes.dashBoardScreen);
//                         // }
//                       },
//                     ),

//                     24.verticalSpace,

//                     /// Create Account
//                     Center(
//                       child: RichText(
//                         text: TextSpan(
//                           text: 'Pas encore inscrit ? ', // Not Registered Yet?
//                           style: CustomTextStyle.size14W400(
//                             color: AppColors.greyShade,
//                           ),
//                           children: [
//                             TextSpan(
//                               text: 'Créer un compte', // Create An Account
//                               style: CustomTextStyle.size14W500(
//                                 color: AppColors.primary,
//                               ),
//                               recognizer:
//                                   TapGestureRecognizer()
//                                     ..onTap = () {
//                                       context.pushNamed(Routes.signupScreen);
//                                     },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
// // import 'package:flutter/gestures.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:flutter_svg/flutter_svg.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:trop_cest/components/common/clickable_button.dart';
// // import 'package:trop_cest/components/common/common_button.dart';
// // import 'package:trop_cest/components/common/custom_textfield.dart';
// // import 'package:trop_cest/core/constants/app_images.dart';
// // import 'package:trop_cest/core/navigator/app_pages.dart';
// // import 'package:trop_cest/core/theme/app_colors.dart';
// // import 'package:trop_cest/core/theme/app_size.dart';
// // import 'package:trop_cest/core/theme/app_text.dart';
// // import 'package:trop_cest/pages/authentication/cubit/auth_cubit.dart';
// // import 'package:trop_cest/pages/authentication/cubit/auth_state.dart';

// // class LoginForm extends StatefulWidget {
// //   const LoginForm({super.key});

// //   @override
// //   State<LoginForm> createState() => _LoginFormState();
// // }

// // class _LoginFormState extends State<LoginForm> {
// //   final TextEditingController emailController = TextEditingController();
// //   final TextEditingController passwordController = TextEditingController();
// //   bool rememberMe = false;

// //   @override
// //   Widget build(BuildContext context) {
// //     final isMobile = MediaQuery.of(context).size.width < 600;
// //     // final authCubit = context.read<AuthCubit>();
// //     return BlocBuilder<AuthCubit, AuthState>(
// //       builder: (context, state) {
// //         return Column(
// //           mainAxisSize: MainAxisSize.min,
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             /// Logo
// //             Center(
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Image.asset(AppIcons.appLogo, height: 150.heightMultiplier),
// //                 ],
// //               ),
// //             ),

// //             /// Title
// //             Container(
// //               padding: EdgeInsets.symmetric(
// //                 vertical: 20.heightMultiplier,
// //                 horizontal: isMobile ? 8.widthMultiplier : 60.widthMultiplier,
// //               ),

// //               decoration: BoxDecoration(
// //                 color: AppColors.tbackground,
// //                 borderRadius: BorderRadius.circular(24.radiusMultiplier),
// //               ),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Align(
// //                     alignment:
// //                         isMobile ? Alignment.center : Alignment.centerLeft,
// //                     child: Column(
// //                       crossAxisAlignment:
// //                           isMobile
// //                               ? CrossAxisAlignment.center
// //                               : CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           'Log In To Your Account',
// //                           style: CustomTextStyle.size20W600(
// //                             color: AppColors.black100,
// //                           ),
// //                         ),
// //                         8.verticalSpace,
// //                         Text(
// //                           'Enter your email and password to log in',
// //                           style: CustomTextStyle.size14W400(
// //                             color: AppColors.greyShade,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   32.verticalSpace,

// //                   /// Email
// //                   Text(
// //                     'Enter Email',
// //                     style: CustomTextStyle.size14W400(
// //                       color: AppColors.greyShade,
// //                     ),
// //                   ),
// //                   4.verticalSpace,
// //                   CustomTextField(
// //                     // onChanged: authCubit.updateLoginEmail,
// //                     borderRadius: 12.radiusMultiplier,
// //                     useLabelText: false,
// //                     borderColor: AppColors.primary2,
// //                     controller: emailController,
// //                     hintText: 'Enter Email',
// //                     backgroundColor: AppColors.tbackground,

// //                     // errorText:
// //                     //     state.loginEmailError.isNotEmpty
// //                     //         ? state.loginEmailError
// //                     //         : null,
// //                     suffixIcon: Icon(Icons.email, color: AppColors.primary),
// //                   ),

// //                   16.verticalSpace,

// //                   /// Password
// //                   Text(
// //                     'Enter Password',
// //                     style: CustomTextStyle.size14W400(
// //                       color: AppColors.greyShade,
// //                     ),
// //                   ),
// //                   4.verticalSpace,
// //                   CustomTextField(
// //                     obscureText: !state.showLoginPassword,
// //                     maxlines: 1,
// //                     // onChanged: authCubit.updateLoginPassword,
// //                     borderRadius: 12.radiusMultiplier,
// //                     useLabelText: false,
// //                     borderColor: AppColors.primary2,
// //                     controller: passwordController,
// //                     hintText: 'Enter Password',
// //                     backgroundColor: AppColors.tbackground,

// //                     // errorText:
// //                     //     state.loginPasswordError.isNotEmpty
// //                     //         ? state.loginPasswordError
// //                     //         : null,
// //                     suffixIcon: ClickableButton(
// //                       onTap: () {
// //                         // authCubit.toggleLoginPasswordIcon(
// //                         //   toggle: ShowPassword.login,
// //                         // );
// //                       },
// //                       child: Icon(
// //                         state.showLoginPassword
// //                             ? Icons.visibility
// //                             : Icons.visibility_off,
// //                         color: AppColors.primary,
// //                       ),
// //                     ),
// //                   ),
// //                   // 4.verticalSpace,
// //                   24.verticalSpace,

// //                   /// Remember Me + Forgot
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           SizedBox(
// //                             width: 20.widthMultiplier,
// //                             height: 20.heightMultiplier,
// //                             child: Checkbox(
// //                               value: rememberMe,
// //                               activeColor: AppColors.primary,
// //                               side: BorderSide(color: AppColors.primary2),
// //                               materialTapTargetSize:
// //                                   MaterialTapTargetSize.shrinkWrap,
// //                               // <= important!
// //                               onChanged: (val) {
// //                                 setState(() {
// //                                   rememberMe = val ?? false;
// //                                 });
// //                               },
// //                             ),
// //                           ),
// //                           10.horizontalSpace,
// //                           Text(
// //                             'Remember Me',
// //                             style: CustomTextStyle.size14W400(
// //                               color: AppColors.black100,
// //                             ),
// //                           ),
// //                         ],
// //                       ),

// //                       InkWell(
// //                         onTap: () {
// //                           // context.pushNamed(Routes.forgetPasswordScreen);
// //                         },
// //                         child: Text(
// //                           'Forget Password?',
// //                           style: CustomTextStyle.size14W400(
// //                             color: AppColors.primary,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   24.verticalSpace,

// //                   /// Login Btn
// //                   CustomButton(
// //                     text: 'Log In',
// //                     isLoading: state.isLoading,
// //                     textStyle: CustomTextStyle.size14W500(
// //                       color: AppColors.white100,
// //                     ),
// //                     onTap: () {
// //                       Pages.appRouter.goNamed(Routes.dashBoardScreen);
// //                       // final validateLogin = authCubit.validateSignin();
// //                       // if (validateLogin) {
// //                       //   authCubit.login(
// //                       //     email: state.loginemail,
// //                       //     password: state.loginpassword,
// //                       //   );
// //                       // }

// //                       // if (authCubit.validate()) {
// //                       // Pages.appRouter.goNamed(Routes.dashBoardScreen);
// //                       // }
// //                     },
// //                   ),

// //                   24.verticalSpace,

// //                   /// Create Account
// //                   Center(
// //                     child: RichText(
// //                       text: TextSpan(
// //                         text: 'Not Registered Yet? ',
// //                         style: CustomTextStyle.size14W400(
// //                           color: AppColors.greyShade,
// //                         ),
// //                         children: [
// //                           TextSpan(
// //                             text: 'Create An Account',
// //                             style: CustomTextStyle.size14W500(
// //                               color: AppColors.primary,
// //                             ),
// //                             recognizer:
// //                                 TapGestureRecognizer()
// //                                   ..onTap = () {
// //                                     // context.pushNamed(Routes.signupScreen);
// //                                   },
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// // }
