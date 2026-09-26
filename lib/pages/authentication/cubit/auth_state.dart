// lib/pages/auth/cubit/auth_state.dart (Updated with login errors)
part of 'auth_cubit.dart';

class AuthState extends Equatable {
  // ==================== LOGIN FIELDS ====================
  final String loginemail;
  final String loginpassword;
  final bool showLoginPassword;
  final bool isSignInSuccess;
  final String? signInError;
  final String loginEmailError;
  final String loginPasswordError;
  
  // ==================== SIGNUP FIELDS ====================
  final String signUpFullName;
  final String signUpUsername;
  final String signUpEmail;
  final String signUpPassword;
  final File? profileImage;
  final String? accountType;
  final List<String> roles;
  final bool termsAccepted;
  final bool isSignUpSuccess;
  final String? signUpError;

  // Signup validation errors
  final String signUpFullNameError;
  final String signUpUsernameError;
  final String signUpEmailError;
  final String signUpPasswordError;
  
  // ==================== PASSWORD RESET ====================
  final bool isResetSuccess;
  final String? resetError;
  
  // ==================== COMMON ====================
  final bool isLoading;

  const AuthState({
    // Login
    this.loginemail = '',
    this.loginpassword = '',
    this.showLoginPassword = false,
    this.isSignInSuccess = false,
    this.signInError,
    this.loginEmailError = '',
    this.loginPasswordError = '',
    // Signup
    this.signUpFullName = '',
    this.signUpUsername = '',
    this.signUpEmail = '',
    this.signUpPassword = '',
    this.profileImage,
    this.accountType,
    this.roles = const [],
    this.termsAccepted = false,
    this.isSignUpSuccess = false,
    this.signUpError,
    // Signup validation errors
    this.signUpFullNameError = '',
    this.signUpUsernameError = '',
    this.signUpEmailError = '',
    this.signUpPasswordError = '',
    // Password reset
    this.isResetSuccess = false,
    this.resetError,
    // Common
    this.isLoading = false,
  });

  AuthState copyWith({
    // Login
    String? loginemail,
    String? loginpassword,
    bool? showLoginPassword,
    bool? isSignInSuccess,
    String? signInError,
    String? loginEmailError,
    String? loginPasswordError,
    // Signup
    String? signUpFullName,
    String? signUpUsername,
    String? signUpEmail,
    String? signUpPassword,
    File? profileImage,
    String? accountType,
    List<String>? roles,
    bool? termsAccepted,
    bool? isSignUpSuccess,
    String? signUpError,
    // Signup validation errors
    String? signUpFullNameError,
    String? signUpUsernameError,
    String? signUpEmailError,
    String? signUpPasswordError,
    // Password reset
    bool? isResetSuccess,
    String? resetError,
    // Common
    bool? isLoading,
  }) {
    return AuthState(
      // Login
      loginemail: loginemail ?? this.loginemail,
      loginpassword: loginpassword ?? this.loginpassword,
      showLoginPassword: showLoginPassword ?? this.showLoginPassword,
      isSignInSuccess: isSignInSuccess ?? this.isSignInSuccess,
      signInError: signInError ?? this.signInError,
      loginEmailError: loginEmailError ?? this.loginEmailError,
      loginPasswordError: loginPasswordError ?? this.loginPasswordError,
      // Signup
      signUpFullName: signUpFullName ?? this.signUpFullName,
      signUpUsername: signUpUsername ?? this.signUpUsername,
      signUpEmail: signUpEmail ?? this.signUpEmail,
      signUpPassword: signUpPassword ?? this.signUpPassword,
      profileImage: profileImage ?? this.profileImage,
      accountType: accountType ?? this.accountType,
      roles: roles ?? this.roles,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      isSignUpSuccess: isSignUpSuccess ?? this.isSignUpSuccess,
      signUpError: signUpError ?? this.signUpError,
      // Signup validation errors
      signUpFullNameError: signUpFullNameError ?? this.signUpFullNameError,
      signUpUsernameError: signUpUsernameError ?? this.signUpUsernameError,
      signUpEmailError: signUpEmailError ?? this.signUpEmailError,
      signUpPasswordError: signUpPasswordError ?? this.signUpPasswordError,
      // Password reset
      isResetSuccess: isResetSuccess ?? this.isResetSuccess,
      resetError: resetError ?? this.resetError,
      // Common
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    // Login
    loginemail,
    loginpassword,
    showLoginPassword,
    isSignInSuccess,
    signInError,
    loginEmailError,
    loginPasswordError,
    // Signup
    signUpFullName,
    signUpUsername,
    signUpEmail,
    signUpPassword,
    profileImage,
    accountType,
    roles,
    termsAccepted,
    isSignUpSuccess,
    signUpError,
    // Signup validation errors
    signUpFullNameError,
    signUpUsernameError,
    signUpEmailError,
    signUpPasswordError,
    // Password reset
    isResetSuccess,
    resetError,
    // Common
    isLoading,
  ];
}