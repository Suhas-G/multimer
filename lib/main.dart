import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:multimer/router.dart';


const String HOME_ROUTE = '/';
const String NEW_ROUTE = '/new';
const String PLAY_ROUTE = '/play';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MaterialApp(
      theme: ThemeData(fontFamily: 'Oxanium', brightness: Brightness.dark),
      initialRoute: '/',
      onGenerateRoute: Router.generateRoute,
    ));
}

