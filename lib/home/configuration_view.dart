import 'dart:math';

import 'package:bike_route_generator/ors/ors_api.dart';
import 'package:bike_route_generator/secrets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';

import 'reg_exp_text_field.dart';

class ConfigurationView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ConfigurationViewState();
}

class _ConfigurationViewState extends State<ConfigurationView> {
  static final api = const OrsApi(apiKey: orsApiKey);
  bool _useCustomLocation = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> mainViewChildren = [_buildOriginOptionSelector()];

    mainViewChildren.add(
      AnimatedCrossFade(
        duration: const Duration(milliseconds: 150),
        firstChild: _buildCustomLocationInput(),
        secondChild: Container(),
        // Second child just to made coords input disappear
        crossFadeState: _useCustomLocation
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
      ),
    );

    mainViewChildren
      ..add(SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _confirmButtonOnPressed,
          child: Text("Generate!"),
        ),
      ))
      ..add(_buildRoundTripDetailsInput());

    return Scaffold(
        appBar: AppBar(
          title: Text("Bike Route Generator"),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: mainViewChildren,
              )),
        ));
  }

  bool get _isInputValid =>
      !_useCustomLocation || (_latitude != null && _longitude != null);

  Function()? get _confirmButtonOnPressed => _isInputValid
      ? () {
          _generateRoute();
        }
      : null;

  void _generateRoute() async {
    Coords originLocation;

    if (!_useCustomLocation) {
      originLocation = await _determinePosition()
          .then((value) => Coords(value.latitude, value.longitude));
    } else {
      originLocation = Coords(_latitude!, _longitude!);
    }

    final maps = await MapLauncher.installedMaps;

    AvailableMap map;

    try {
      map = maps.firstWhere(
        (element) => element.mapType == MapType.google,
      );
    } on Error catch (error) {
      // TODO display no google maps error message
      return;
    }

    api
        .generateRoute(originLocation, _length, _safeSeed, _points)
        .then((value) => map.showDirections(
              origin: value.first,
              destination: value.last,
              waypoints: value.sublist(1, value.length - 1),
            ));
  }

  Widget _buildOriginOptionSelector() => Column(
        children: [
          Text("Select route origin:"),
          RadioListTile<bool>(
            value: false,
            groupValue: _useCustomLocation,
            title: Text("Current Location"),
            onChanged: (value) {
              setState(() {
                _useCustomLocation = value ?? false;
              });
            },
          ),
          RadioListTile<bool>(
            value: true,
            groupValue: _useCustomLocation,
            title: Text("Custom Location"),
            onChanged: (value) {
              setState(() {
                _useCustomLocation = value ?? false;
              });
            },
          ),
        ],
      );

  double? _latitude;
  double? _longitude;

  Widget _buildCustomLocationInput() => Column(
        children: [
          RegExpTextField(
            RegExp(r'^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?)$'),
            keyboardType: TextInputType.number,
            labelText: 'Latitude',
            enabled: _useCustomLocation,
            onChange: (isValid, value) {
              setState(() {
                _latitude = isValid ? double.parse(value) : null;
              });
            },
          ),
          RegExpTextField(
            RegExp(r'^\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$'),
            keyboardType: TextInputType.number,
            labelText: 'Longitude',
            enabled: _useCustomLocation,
            onChange: (isValid, value) {
              setState(() {
                _longitude = isValid ? double.parse(value) : null;
              });
            },
          ),
        ],
      );

  int _length = 20;
  int? _seed;

  int get _safeSeed {
    if (_seed == null) {
      _seed = generateNextSeed();
    }
    return _seed ?? 0;
  }

  final random = new Random();

  int generateNextSeed() => random.nextInt(1000);

  int _points = 5;

  Widget _buildRoundTripDetailsInput() {
    return Column(
      children: [
        Text('Roundtrip config'),
        SpinBox(
          min: 1,
          max: 1000,
          value: _length.toDouble(),
          decoration: InputDecoration(labelText: "Distance [km]"),
          onChanged: (value) => _length = value.toInt(),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 6,
              child: SpinBox(
                min: 1,
                max: 1023,
                value: _safeSeed.toDouble(),
                decoration: InputDecoration(labelText: "Seed"),
                onChanged: (value) => _seed = value.toInt(),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _seed = generateNextSeed();
                  });
                },
              ),
            )
          ],
        ),
        SpinBox(
          min: 3,
          max: 10,
          value: _points.toDouble(),
          decoration: InputDecoration(labelText: "Points"),
          onChanged: (value) => _points = value.toInt(),
        ),
      ],
    );
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
}
