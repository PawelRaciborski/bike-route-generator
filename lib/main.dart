import 'package:bike_route_generator/home/configuration_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(RouteGeneratorApp());
}

class RouteGeneratorApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ConfigurationView(),
    );
  }
}
