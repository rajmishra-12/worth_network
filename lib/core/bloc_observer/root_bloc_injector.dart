import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/pages/action/cubit/add_action_cubit.dart';
import 'package:worth_network/pages/authentication/cubit/auth_cubit.dart';
import 'package:worth_network/pages/dashboard/cubit/dashboard_cubit.dart';
import 'package:worth_network/pages/home/cubit/home_cubit.dart';
import 'package:worth_network/pages/network/cubit/network_cubit.dart';
import 'package:worth_network/pages/profile/cubit/profile_cubit.dart';

class RootBlocInjection extends StatelessWidget {
  final Widget child;
  const RootBlocInjection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => LocaleCubit()),
          BlocProvider(create: (context) => DashboardCubit() ),
         BlocProvider(create: (context) => HomeCubit()),
          BlocProvider(create: (context) => NetworkCubit()),
           BlocProvider(create: (context) => AddActionCubit()),
            BlocProvider(create: (context) => ProfileCubit()),
             BlocProvider(create: (context) => AuthCubit()),
        ],
        child: child,
      
    );
  }
}

// extension CubitResetX on BuildContext {
//   void resetAllCubits() {
//     read<HomeCubit>().resetState();
//     read<DashboardCubit>().resetState();
//     read<ProfileCubit>().resetState();
//     // read<CommunityCubit>().cancelListeners();
//     read<TestimonialCubit>().cancelListeners();
//   }
// }
