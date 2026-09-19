import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:worth_network/core/utils/preferences.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  /// Check if a username is available (case-insensitive check)
  Future<bool> isUsernameAvailable(String username, {String? excludeUid}) async {
    final cleanUsername = username.trim().replaceAll('@', '').toLowerCase();
    if (cleanUsername.isEmpty) return false;

    // 1. Check by lowercased username
    final queryByLower = await _firestore
        .collection('users')
        .where('username_lowercase', isEqualTo: cleanUsername)
        .get();

    if (queryByLower.docs.isNotEmpty) {
      return queryByLower.docs.every((doc) => doc.id == excludeUid);
    }

    // 2. Fallback check by legacy username field
    final legacyQuery = await _firestore
        .collection('users')
        .where('username', isEqualTo: username.trim().replaceAll('@', ''))
        .get();

    if (legacyQuery.docs.isNotEmpty) {
      return legacyQuery.docs.every((doc) => doc.id == excludeUid);
    }

    return true;
  }

  /// Register user in Firebase Auth and create profile in Firestore
  Future<User?> signUp({
    required String fullName,
    required String username,
    required String email,
    required String password,
    File? profileImage,
  }) async {
    try {
      final emailStr = email.trim();
      final usernameStr = username.trim().replaceAll('@', '');
      final cleanUsername = usernameStr.toLowerCase();

      // Check username availability BEFORE creating Firebase Auth user
      final isAvailable = await isUsernameAvailable(usernameStr);
      if (!isAvailable) {
        throw Exception("Username '@$usernameStr' is already taken. Please choose another username.");
      }

      // 1. Create Firebase Auth user
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: emailStr, password: password);

      final user = userCredential.user;

      // 2. Set Firebase Auth Display Name
      await user?.updateDisplayName(fullName);

      // 3. Upload profile picture if provided
      String? avatarUrl;
      if (profileImage != null && user != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child('${user.uid}.jpg');
        await storageRef.putFile(profileImage);
        avatarUrl = await storageRef.getDownloadURL();
      }

      // 4. Create document in 'users' Firestore collection
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'name': fullName,
          'username': usernameStr,
          'username_lowercase': cleanUsername,
          'email': emailStr,
          'bio': 'New to Worth Network! 🚀',
          'avatarUrl': avatarUrl ?? 'https://i.pravatar.cc/150?img=10',
          'score': 0,
          'level': 1,
          'xp': 0,
          'nextLevelXp': 100,
          'totalActions': 0,
          'validatedPercentage': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 5. Save details locally in SharedPreferences
        final prefs = Preferences();
        prefs.isLoggedIn = true;
        prefs.userId = user.uid;
        prefs.email = emailStr;
        prefs.username = usernameStr;
        prefs.name = fullName;
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Update user profile details (username, bio, profile photo uploader)
  Future<void> updateProfile({
    required String uid,
    required String username,
    required String bio,
    File? profileImage,
  }) async {
    try {
      final usernameStr = username.trim().replaceAll('@', '');
      final cleanUsername = usernameStr.toLowerCase();

      final isAvailable = await isUsernameAvailable(usernameStr, excludeUid: uid);
      if (!isAvailable) {
        throw Exception("Username '@$usernameStr' is already taken. Please choose another username.");
      }

      final updates = <String, dynamic>{
        'username': usernameStr,
        'username_lowercase': cleanUsername,
        'bio': bio.trim(),
      };

      if (profileImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child('$uid.jpg');
        await storageRef.putFile(profileImage);
        final avatarUrl = await storageRef.getDownloadURL();
        updates['avatarUrl'] = avatarUrl;
      }

      await _firestore.collection('users').doc(uid).update(updates);

      // Cache changes locally in Shared Preferences
      final prefs = Preferences();
      prefs.username = usernameStr;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Sign in user using Email or Username
  Future<User?> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      String resolvedEmail = emailOrUsername.trim();

      // If it doesn't contain '@', resolve the username from Firestore
      if (!resolvedEmail.contains('@')) {
        final cleanUsername = resolvedEmail.replaceAll('@', '').toLowerCase();

        var querySnapshot = await _firestore
            .collection('users')
            .where('username_lowercase', isEqualTo: cleanUsername)
            .get();

        if (querySnapshot.docs.isEmpty) {
          querySnapshot = await _firestore
              .collection('users')
              .where('username', isEqualTo: resolvedEmail.replaceAll('@', ''))
              .get();
        }

        if (querySnapshot.docs.isEmpty) {
          throw Exception("No account found with username '$emailOrUsername'.");
        }

        resolvedEmail = querySnapshot.docs.first.data()['email'] as String;
      }

      // Authenticate with Firebase Auth
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: resolvedEmail, password: password);

      final user = userCredential.user;

      // Save details locally in SharedPreferences
      if (user != null) {
        final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null) {
            final prefs = Preferences();
            prefs.isLoggedIn = true;
            prefs.userId = user.uid;
            prefs.email = data['email'] ?? '';
            prefs.username = data['username'] ?? '';
            prefs.name = data['name'] ?? '';
          }
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    } catch (e) {
      throw Exception("Failed to send password reset email. Please try again.");
    }
  }

  /// Sign out the current user and clear Preferences
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await Preferences().clear();
    } catch (e) {
      throw Exception("Logout failed. Please try again.");
    }
  }

  /// Delete user account from Firestore & Firebase Auth
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final uid = user.uid;
        // 1. Delete user document from Firestore
        await _firestore.collection('users').doc(uid).delete();
        // 2. Delete user authentication record
        await user.delete();
        // 3. Clear local cache
        await Preferences().clear();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('For security reasons, please log in again before deleting your account.');
      }
      throw Exception(_mapFirebaseError(e));
    } catch (e) {
      throw Exception("Failed to delete account. Please try again.");
    }
  }

  /// Internet connectivity check
  Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Map Firebase Auth exceptions to user-friendly messages
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email address is already in use by another account.';
      case 'invalid-email':
        return 'The email address format is invalid.';
      case 'operation-not-allowed':
        return 'Email/Password accounts are not enabled. Contact support.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      case 'user-disabled':
        return 'This user account has been disabled by an administrator.';
      case 'user-not-found':
        return 'No account was found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid login credentials. Please double-check your email and password.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
