import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:worth_network/core/bloc_observer/root_bloc_injector.dart';
import 'package:worth_network/core/navigator/app_pages.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_theme.dart';




class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {

    
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );

    return ScreenUtilInit(
      designSize: Size(size.width, size.height),
      builder: (BuildContext context, Widget? child) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return OrientationBuilder(
              builder: (BuildContext context, Orientation orientation) {
                AppScreenUtil().init(constraints, orientation);
                return
                 RootBlocInjection(
                  child:
                   MaterialApp.router(
                    title: 'Title',
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.lightTheme,
                    debugShowCheckedModeBanner: false,
                    routerConfig: Pages.appRouter,
                    locale: const Locale("en"),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
