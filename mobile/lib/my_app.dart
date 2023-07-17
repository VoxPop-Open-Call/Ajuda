import 'package:ajuda/Ui/bottombarScreen/HomeMainScreen.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:ajuda/route_helper.dart';
import 'package:ajuda/main.dart' as main;

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'Ui/authScreens/login/login_screen.dart';
import 'Ui/Utils/misc_functions.dart';
import 'Ui/Utils/theme/theme.dart';
import 'notification/firebase_notification.dart';
import 'notification/push_notification_handler.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {

    LocalNotification().configureDidReceiveLocalNotificationSubject(context);
    LocalNotification().configureSelectNotificationSubject();
    FirebaseNotifications().firebaseInitialization();
    LocalNotification().initialize();
    FlutterNativeSplash.remove();
    hideKeyboard();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final botToastBuilder = BotToastInit();
    return MaterialApp(
      builder: (context, child) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        final noInternet = Provider.of<ConnectivityResult?>(context) ==
            ConnectivityResult.none;
        if (noInternet) {
          BotToast.showCustomNotification(
            duration: const Duration(milliseconds: 1500),
            align: Alignment.bottomCenter,
            enableSlideOff: false,
            toastBuilder: (_) => Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              child: const Text(
                'No internet connection',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20.0,
                ),
              ),
            ),
          );
          // Toast.showNoInternetToast(context);
        }

        return botToastBuilder(context, child!);
      },
      title: 'Ajuda',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: themeData,
      navigatorObservers: [main.routeObserver],
      routes: context.read<RouteHelper>().createRoutes(),
      initialRoute: _getInitialRoute(),
    );
  }

  String _getInitialRoute() {
    if (SharedPrefHelper.isLoggedIn) {
      return HomeMainScreen.route;
    } else {
      if (SharedPrefHelper.onBoardingShown) {
        return HomeMainScreen.route;
      } else {
        return LoginScreen.route;
      }
    }
  }
}
