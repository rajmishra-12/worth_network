// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:worth_network/core/navigator/app_pages.dart';
// import 'package:worth_network/core/theme/app_colors.dart';
// import 'package:worth_network/pages/authentication/cubit/auth_cubit.dart';


// class OfflineScreen extends StatefulWidget {
//   const OfflineScreen({super.key});

//   @override
//   State<OfflineScreen> createState() => _OfflineScreenState();
// }

// class _OfflineScreenState extends State<OfflineScreen> {
//   bool _isChecking = false;

//   Future<void> _retryConnection() async {
//     setState(() {
//       _isChecking = true;
//     });

//     final authCubit = context.read<AuthCubit>();
//     final isConnected = await authCubit.repository.isConnected();

//     setState(() {
//       _isChecking = false;
//     });

//     if (isConnected) {
//       // Check login status and navigate accordingly
//       authCubit.checkAuthStatus();
//       if (authCubit.state.isLoggedIn) {
//         Pages.appRouter.go(Routes.dashBoardScreen);
//       } else {
//         Pages.appRouter.go(Routes.welcomeScreenPage);
//       }
//     } else {
//       // Optionally show a snackbar or alert
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Still offline. Please try again.")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primary, // your primary color
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.wifi_off, // or use your custom icon
//                   size: 120,
//                   color: Colors.white,
//                 ),
//                 const SizedBox(height: 24),
//                 const Text(
//                   "No Internet Connection",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   "Please check your internet connection and try again.",
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 16,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 32),
//                 ElevatedButton.icon(
//                   onPressed: _isChecking ? null : _retryConnection,
//                   icon: _isChecking
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : const Icon(Icons.refresh),
//                   label: Text(_isChecking ? "Checking..." : "Retry"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: AppColors.primary,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 32, vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     textStyle: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
