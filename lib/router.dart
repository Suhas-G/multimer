import 'package:flutter/material.dart';
import 'package:multimer/pages/loading.dart';
import 'package:multimer/models/multitimer.dart';
import 'package:multimer/pages/add_multitimer.dart';
import 'package:multimer/pages/home/home.dart';
//import 'package:multimer/pages/home.dart';
import 'package:multimer/pages/play_multi_timer/play_multitimer.dart';

class Router {
  static const String INITIAL_ROUTE = '/';
  static const String HOME_ROUTE = '/home';
  static const String NEW_ROUTE = '/new';
  static const String PLAY_ROUTE = '/play';
  

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Map<String, dynamic> data = settings.arguments ?? {};
    switch (settings.name) {
      case INITIAL_ROUTE:
        return getLoadingScreen();
        break;
      case HOME_ROUTE:
        return getHomeScreen();
        break;
      case NEW_ROUTE:
        bool isUpdate = data.containsKey('isUpdate') ? data['isUpdate'] : false;
        MultiTimer multiTimer = data.containsKey('multiTimer') ? data['multiTimer'] : null;
        return MaterialPageRoute(builder: (_) => AddMultiTimer(isUpdate, multiTimer));
        break;
      case PLAY_ROUTE:
        return MaterialPageRoute(builder: (_) => PlayMultiTimer(data['multiTimer']));
        break;
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(child: Text('No route defined for ${settings.name}')),
                ));
    }
  }

  static getHomeScreen() {
    return MaterialPageRoute(builder: (_) => Home());
  }

  static getLoadingScreen() {
    return MaterialPageRoute(builder: (_) => LoadingScreen());
  }
}
