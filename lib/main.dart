import 'package:bike_route_generator/favs/model/fav_repo.dart';
import 'package:bike_route_generator/home/configuration_route.dart';
import 'package:bike_route_generator/home/configuration_store.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

GetIt injector = GetIt.instance;

Future<void> main() async {
  injector
    ..registerSingletonAsync<FavRouteRepository>(
      () => FavRouteRepository.initialize(),
    )
    ..registerFactory<Configuration>(() => Configuration());
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
