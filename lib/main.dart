import 'package:bike_route_generator/home/configuration_route.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(RouteGeneratorApp());
}

class RouteGeneratorApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bike Route Generator',
      theme: ThemeData(
        primarySwatch: Colors.lime,
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.lime,
        accentColor: Colors.lime,
        primaryColorDark: Colors.lime,
        primaryColorLight: Colors.lime,
        toggleableActiveColor: Colors.lime,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: ConfigurationRoute(),
    );
  }
}
