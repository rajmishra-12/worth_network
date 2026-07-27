import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleCubit extends Cubit<String> {
  LocaleCubit() : super('en'); // Defaults to English

  void toggleLanguage() {
    emit(state == 'en' ? 'fr' : 'en');
  }

  void setLanguage(String lang) {
    if (lang == 'en' || lang == 'fr') {
      emit(lang);
    }
  }
}
