import 'dart:math';

import 'package:bike_route_generator/favs/model/fav_repo.dart';
import 'package:bike_route_generator/favs/model/fav_route.dart';
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
  final Future<FavRouteRepository> _favRouteRepository;

  final random = Random();

  _Configuration(this._orsApi, this._prefs, this._favRouteRepository);

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
  ObservableList<AvailableMap> availableMaps = ObservableList.of([]);

  @observable
  bool showSelectionDialog = false;

  @observable
  bool isProcessing = false;

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
  Future<void> navigate({MapType? mapType}) async {
    isProcessing = true;

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
      var list = await MapLauncher.installedMaps;
      availableMaps = ObservableList.of(list);

      final MapType? preselectedMap = mapType ??
          await _prefs.then((prefs) {
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
        isProcessing = false;
        return;
      }

      isProcessing = false;
      showSelectionDialog = true;
    }
  }

  @action
  Future saveRoute(String name) async {
    final repo = await _favRouteRepository;
    final origin = await _originLocation;

    repo.insertLocation(
      FavRoute(
        name: name,
        seed: seed,
        latitude: origin.latitude,
        longitude: origin.longitude,
        points: points,
      ),
    );
  }

  void selectMap(AvailableMap selectedMap, bool rememberSelection) {
    if (rememberSelection) {
      _prefs.then((prefs) {
        prefs.setString(selectedMapPrefsKey, selectedMap.mapType.name);

        showSelectionDialog = false;
        navigate(mapType: selectedMap.mapType);
      });
    } else {
      showSelectionDialog = false;
      navigate(mapType: selectedMap.mapType);
    }
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
