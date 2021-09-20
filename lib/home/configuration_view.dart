import 'package:bike_route_generator/ors/ors_api.dart';
import 'package:bike_route_generator/secrets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:map_launcher/map_launcher.dart';

import 'reg_exp_text_field.dart';

class ConfigurationView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ConfigurationViewState();
}

class _ConfigurationViewState extends State<ConfigurationView> {
  bool _originLocationSelection = false;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text("Bike Route Generator"),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildOriginOptionSelector(),
                _buildCustomLocationInput(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirmButtonOnPressed,
                    child: Text("Generate!"),
                  ),
                ),
              ],
            )),
      ));

  bool get _isInputValid =>
      !_originLocationSelection || (_latitude != null && _longitude != null);

  Function()? get _confirmButtonOnPressed => _isInputValid
      ? () {
          _generateRoute();
        }
      : null;

  void _generateRoute() async {
    final api = const OrsApi(apiKey: orsApiKey);
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
    api.generateRoute().then((value) => map.showDirections(
          // origin: value.first,
          destination: value.last,
          waypoints: value.sublist(1, value.length - 2),
        ));
  }

  Widget _buildOriginOptionSelector() => Column(
        children: [
          Text("Select route origin:"),
          RadioListTile<bool>(
            value: false,
            groupValue: _originLocationSelection,
            title: Text("Current Location"),
            onChanged: (value) {
              setState(() {
                _originLocationSelection = value ?? false;
              });
            },
          ),
          RadioListTile<bool>(
            value: true,
            groupValue: _originLocationSelection,
            title: Text("Custom Location"),
            onChanged: (value) {
              setState(() {
                _originLocationSelection = value ?? false;
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
            enabled: _originLocationSelection,
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
            enabled: _originLocationSelection,
            onChange: (isValid, value) {
              setState(() {
                _longitude = isValid ? double.parse(value) : null;
              });
            },
          ),
        ],
      );
}
