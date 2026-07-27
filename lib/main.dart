import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:worth_network/firebase_options.dart';
import 'package:worth_network/core/utils/preferences.dart';
import 'package:worth_network/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // await configureDependencies();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // await configureDependencies();
  
  // setUrlStrategy(PathUrlStrategy());
  GoRouter.optionURLReflectsImperativeAPIs = true;

  // Initialize SharedPreferences singleton
  await Preferences().init();

  await Future.delayed(const Duration(seconds: 1));
  runApp(const App());
}
