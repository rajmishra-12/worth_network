import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/utils/preferences.dart';

class LocaleCubit extends Cubit<String> {
  LocaleCubit() : super(Preferences().language); // Defaults to saved preference or French

  void toggleLanguage() {
    setLanguage(state == 'en' ? 'fr' : 'en');
  }

  void setLanguage(String lang) {
    if (lang == 'en' || lang == 'fr') {
      Preferences().language = lang;
      emit(lang);

      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null && uid.isNotEmpty) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set({'preferredLanguage': lang}, SetOptions(merge: true))
              .catchError((e) {
            print('Warning syncing preferredLanguage to Firestore: $e');
          });
        }
      } catch (e) {
        // Safe fallback when Firebase is not initialized or in testing
      }
    }
  }
}
