import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:worth_network/core/repo/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository = AuthRepository();

  AuthCubit() : super(const AuthState());

  // ==================== LOGIN METHODS ====================
  void updateLoginEmail(String email) {
    emit(state.copyWith(loginemail: email, loginEmailError: '', signInError: null));
  }

  void updateLoginPassword(String password) {
    emit(state.copyWith(loginpassword: password, loginPasswordError: '', signInError: null));
  }

  void updateLoginEmailError(String error) {
    emit(state.copyWith(loginEmailError: error));
  }

  void updateLoginPasswordError(String error) {
    emit(state.copyWith(loginPasswordError: error));
  }

  void toggleShowLoginPassword() {
    emit(state.copyWith(showLoginPassword: !state.showLoginPassword));
  }

  Future<void> signIn({required String email, required String password}) async {
    // Clear previous errors
    emit(state.copyWith(
      isLoading: true,
      signInError: null,
      loginEmailError: '',
      loginPasswordError: '',
      isSignInSuccess: false,
    ));
    
    // Basic validation
    if (email.isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        loginEmailError: 'Please enter your email or username',
      ));
      return;
    }
    
    if (password.isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        loginPasswordError: 'Please enter your password',
      ));
      return;
    }
    
    try {
      await repository.signIn(emailOrUsername: email, password: password);
      
      emit(state.copyWith(
        isLoading: false,
        isSignInSuccess: true,
        signInError: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isSignInSuccess: false,
        signInError: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  // ==================== SIGNUP METHODS ====================
  void updateSignUpFullName(String fullName) {
    emit(state.copyWith(signUpFullName: fullName, signUpFullNameError: '', signUpError: null));
  }

  void updateSignUpUsername(String username) {
    emit(state.copyWith(signUpUsername: username, signUpUsernameError: '', signUpError: null));
  }

  void updateSignUpEmail(String email) {
    emit(state.copyWith(signUpEmail: email, signUpEmailError: '', signUpError: null));
  }

  void updateSignUpPassword(String password) {
    emit(state.copyWith(signUpPassword: password, signUpPasswordError: '', signUpError: null));
  }

  void updateAccountType(String? accountType) {
    emit(state.copyWith(accountType: accountType));
  }

  void updateRoles(List<String> roles) {
    emit(state.copyWith(roles: roles));
  }

  void updateProfileImage(File? image) {
    emit(state.copyWith(profileImage: image));
  }

  void updateTermsAccepted(bool accepted) {
    emit(state.copyWith(termsAccepted: accepted));
  }

  Future<void> signUp() async {
    // Clear previous errors
    emit(state.copyWith(
      isLoading: true,
      signUpError: null,
      signUpFullNameError: '',
      signUpUsernameError: '',
      signUpEmailError: '',
      signUpPasswordError: '',
      isSignUpSuccess: false,
    ));
    
    // Validate fields
    if (state.signUpFullName.isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        signUpFullNameError: 'Full name is required',
      ));
      return;
    }
    
    if (state.signUpFullName.length < 3) {
      emit(state.copyWith(
        isLoading: false,
        signUpFullNameError: 'Full name must be at least 3 characters',
      ));
      return;
    }
    
    if (state.signUpUsername.isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        signUpUsernameError: 'Username is required',
      ));
      return;
    }
    
    if (state.signUpUsername.length < 3) {
      emit(state.copyWith(
        isLoading: false,
        signUpUsernameError: 'Username must be at least 3 characters',
      ));
      return;
    }
    
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(state.signUpUsername)) {
      emit(state.copyWith(
        isLoading: false,
        signUpUsernameError: 'Only letters, numbers, and underscores allowed',
      ));
      return;
    }
    
    if (state.signUpEmail.isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        signUpEmailError: 'Email is required',
      ));
      return;
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(state.signUpEmail)) {
      emit(state.copyWith(
        isLoading: false,
        signUpEmailError: 'Enter a valid email address',
      ));
      return;
    }
    
    if (state.signUpPassword.isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        signUpPasswordError: 'Password is required',
      ));
      return;
    }
    
    if (state.signUpPassword.length < 6) {
      emit(state.copyWith(
        isLoading: false,
        signUpPasswordError: 'Password must be at least 6 characters',
      ));
      return;
    }
    
    if (!state.termsAccepted) {
      emit(state.copyWith(
        isLoading: false,
        signUpError: 'Please accept the terms and conditions',
      ));
      return;
    }

    try {
      await repository.signUp(
        fullName: state.signUpFullName,
        username: state.signUpUsername,
        email: state.signUpEmail,
        password: state.signUpPassword,
        accountType: state.accountType,
        roles: state.roles,
        profileImage: state.profileImage,
      );
      
      emit(state.copyWith(
        isLoading: false,
        isSignUpSuccess: true,
      ));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      final isUsernameError = errorMsg.toLowerCase().contains('username');
      emit(state.copyWith(
        isLoading: false,
        signUpError: errorMsg,
        signUpUsernameError: isUsernameError ? errorMsg : null,
      ));
    }
  }

  // ==================== PASSWORD RESET ====================
  Future<void> resetPassword(String email) async {
    emit(state.copyWith(
      isLoading: true,
      isResetSuccess: false,
      resetError: null,
    ));

    if (email.trim().isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        resetError: 'Please enter your email address.',
      ));
      return;
    }

    try {
      await repository.sendPasswordResetEmail(email: email);
      emit(state.copyWith(
        isLoading: false,
        isResetSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isResetSuccess: false,
        resetError: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  // ==================== COMMON METHODS ====================
  void resetState() {
    emit(const AuthState());
  }

  Future<void> logout() async {
    try {
      await repository.logout();
      resetState();
    } catch (_) {}
  }

  Future<void> deleteAccount() async {
    try {
      await repository.deleteAccount();
      resetState();
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}