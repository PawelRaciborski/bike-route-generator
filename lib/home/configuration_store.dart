import 'dart:math';

import 'package:bike_route_generator/ors/ors_api.dart';
import 'package:bike_route_generator/ors/url_launching.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'map_selection_dialog.dart';

part 'configuration_store.g.dart';

class Configuration = _Configuration with _$Configuration;

abstract class _Configuration with Store {
  final OrsApi _orsApi;
  final Future<SharedPreferences> _prefs;

  final random = Random();

  _Configuration(this._orsApi, this._prefs);

  @observable
  double? latitude;

  @observable
  double? longitude;

  @observable
  RouteOriginLocation locationMode = RouteOriginLocation.current;

  @computed
  bool get locationInputValid =>
      locationMode == RouteOriginLocation.current ||
      (latitude != null && longitude != null);

  @observable
  int length = 20;

  @observable
  int seed = 431;

  @observable
  List<AvailableMap> availableMaps = [];

  @observable
  bool showSelectionDialog = false;

  @action
  void refreshSeed() {
    seed = _generateNextSeed();
  }

  int _generateNextSeed() => random.nextInt(1000);

  @observable
  int points = 5;

  Future<Coords> get _originLocation async {
    if (locationMode == RouteOriginLocation.current) {
      return await _determinePosition()
          .then((value) => Coords(value.latitude, value.longitude));
    } else {
      return Coords(latitude!, longitude!);
    }
  }

  @action
  Future<void> navigate() async {
    final originLocation = await _originLocation;

    Future<void> Function(List<Coords> value) generatedRouteHandler =
        (vals) async {
      /*donothing*/
    };

    if (kIsWeb) {
      generatedRouteHandler = (value) async {
        launchURL(generateGoogleMapsUrl(value));
      };
    } else {
      availableMaps = await MapLauncher.installedMaps;

      final MapType? preselectedMap = await _prefs.then((prefs) {
        final String? selectedMapTypeString =
            prefs.getString(selectedMapPrefsKey);

        if (selectedMapTypeString == null) return null;

        return MapType.values.firstWhere(
          (element) => element.name == selectedMapTypeString,
        );
      });

      if (preselectedMap != null) {
        startNavigation(
          availableMaps,
          preselectedMap,
          generatedRouteHandler,
          originLocation,
        );
        return;
      }

      showSelectionDialog = true;
    }
  }

  void selectMap(AvailableMap selectedMap, bool rememberSelection) {
    _prefs.then((prefs) {
      if (rememberSelection) {
        prefs.setString(selectedMapPrefsKey, selectedMap.mapType.name);
      }
      showSelectionDialog = false;
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void startNavigation(
      List<AvailableMap> maps,
      MapType mapType,
      Future<void> Function(List<Coords> value) generatedRouteHandler,
      Coords originLocation) {
    AvailableMap map;

    try {
      map = maps.firstWhere(
        (element) => element.mapType == mapType,
      );
    } on Error {
      // final snackBar = SnackBar(
      //     content: Text(
      //         "Could not get a map, please try again or select different destination app."));
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      //TODO: propagate error information to the user
      return;
    }

    generatedRouteHandler = (value) => map.showDirections(
          origin: value.first,
          destination: value.last,
          waypoints: value.sublist(1, value.length - 1),
        );

    _orsApi
        .generateRoute(
          originLocation,
          length,
          seed,
          points,
        )
        .then(generatedRouteHandler);
  }
}

enum RouteOriginLocation {
  current,
  custom,
}
