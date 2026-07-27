// lib/pages/dashboard/cubit/dashboard_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:worth_network/pages/action/presentation/action_page.dart';
import 'package:worth_network/pages/home/presentation/home_page.dart';
import 'package:worth_network/pages/network/presentation.dart/history_page.dart';
import 'package:worth_network/pages/profile/presentation/profile_page.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState());

  void initializePages() {
    final pages = [
      const HomeScreen(),
         const NetworkScreen(),
       const AddActionScreen(),
   
     
      const ProfileScreen(),
    ];
    emit(state.copyWith(pages: pages));
  }

  void changeTab(int index) {
    emit(state.copyWith(currentIndex: index));
  }
}