import 'package:bike_route_generator/credits/credits_route.dart';
import 'package:bike_route_generator/favs/favs_route.dart';
import 'package:bike_route_generator/favs/model/fav_repo.dart';
import 'package:bike_route_generator/favs/save_route_dialog.dart';
import 'package:bike_route_generator/home/map_selection_dialog.dart';
import 'package:bike_route_generator/main.dart';
import 'package:bike_route_generator/ui/OrientationAwareBuilder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:mobx/mobx.dart';

import 'configuration_store.dart';
import 'reg_exp_text_field.dart';

class ConfigurationRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ConfigurationRouteState();
}

class _ConfigurationRouteState extends State<ConfigurationRoute> {
  final Configuration _configuration = injector.get<Configuration>();

  final List<ReactionDisposer> _disposers = [];

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text("Bike Route Generator"),
            actions: [
              IconButton(
                  onPressed: () async {
                    final repo = await injector.getAsync<FavRouteRepository>();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FavouriteRoute(repo),
                        ));
                  },
                  icon: Icon(Icons.favorite)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreditsRoute(),
                        ));
                  },
                  icon: Icon(Icons.info_outline)),
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: buildOrientationAwareContent(),
                ),
              ),
            ),
          ),
          floatingActionButton: _configuration.locationInputValid
              ? FloatingActionButton(
                  onPressed: _confirmButtonOnPressed,
                  child: Icon(
                    !_configuration.isProcessing
                        ? Icons.directions_bike
                        : Icons.hourglass_bottom,
                  ),
                )
              : null,
        ),
      );

  Widget buildOrientationAwareContent() => OrientationAwareBuilder(
      builder: (context, orientation) => orientation == Orientation.portrait
          ? Column(
              children: [
                _buildRouteOriginSection(),
                _buildRoundTripDetailsInput()
              ],
            )
          : Row(
              children: [
                Flexible(flex: 1, child: _buildRouteOriginSection()),
                Flexible(flex: 1, child: _buildRoundTripDetailsInput())
              ],
            ));

  Widget _buildRouteOriginSection() {
    return Column(
      children: [
        _buildOriginOptionSelector(),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 150),
          firstChild: _buildCustomLocationInput(),
          secondChild: Container(),
          // Second child just to made coords input disappear
          crossFadeState: _configuration.locationMode.asBool
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
        ),
      ],
    );
  }

  Function()? get _confirmButtonOnPressed =>
      _configuration.locationInputValid && !_configuration.isProcessing
          ? () {
              _configuration.navigate();
            }
          : null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disposers.add(reaction((_) => _configuration.showSelectionDialog, (_) {
      if (_configuration.showSelectionDialog) {
        showDialog(
          context: context,
          builder: (context) =>
              _buildMapSelectionDialog(_configuration.availableMaps),
        );
      }
    }));
  }

  Widget _buildMapSelectionDialog(List<AvailableMap> maps) =>
      MapSelectionDialog(
        maps: maps,
        configuration: _configuration,
      );

  Widget _buildOriginOptionSelector() => Observer(
        builder: (_) => Column(
          children: [
            Text("Select route origin:"),
            RadioListTile<bool>(
              value: false,
              groupValue: _configuration.locationMode.asBool,
              title: Text("Current Location"),
              onChanged: (value) {
                _configuration.locationMode = RouteOriginLocation.current;
              },
            ),
            RadioListTile<bool>(
              value: true,
              groupValue: _configuration.locationMode.asBool,
              title: Text("Custom Location"),
              onChanged: (value) {
                _configuration.locationMode = RouteOriginLocation.custom;
              },
            ),
          ],
        ),
      );

  Widget _buildCustomLocationInput() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: RegExpTextField(
              RegExp(r'^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?)$'),
              keyboardType: TextInputType.number,
              labelText: 'Latitude',
              enabled: _configuration.locationMode.asBool,
              onChange: (isValid, value) {
                _configuration.latitude = isValid ? double.parse(value) : null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: RegExpTextField(
              RegExp(r'^\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$'),
              keyboardType: TextInputType.number,
              labelText: 'Longitude',
              enabled: _configuration.locationMode.asBool,
              onChange: (isValid, value) {
                _configuration.longitude = isValid ? double.parse(value) : null;
              },
            ),
          ),
        ],
      );

  Widget _buildRoundTripDetailsInput() {
    return Observer(
      builder: (_) => Column(
        children: [
          Text('Roundtrip config'),
          SpinBox(
            min: 1,
            max: 1000,
            value: _configuration.length.toDouble(),
            decoration: InputDecoration(labelText: "Distance [km]"),
            onChanged: (value) => _configuration.length = value.toInt(),
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
                  value: _configuration.seed.toDouble(),
                  decoration: InputDecoration(labelText: "Seed"),
                  onChanged: (value) => _configuration.seed = value.toInt(),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(
                    Icons.casino_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    _configuration.refreshSeed();
                  },
                ),
              )
            ],
          ),
          SpinBox(
            min: 3,
            max: 10,
            value: _configuration.points.toDouble(),
            decoration: InputDecoration(labelText: "Points"),
            onChanged: (value) => _configuration.points = value.toInt(),
          ),
          ElevatedButton.icon(
            onPressed: _configuration.locationInputValid
                ? () => showDialog(
                      context: context,
                      builder: (context) => SaveRouteDialog(
                        selectedMode: _configuration.locationMode,
                        length: _configuration.length,
                        points: _configuration.points,
                        seed: _configuration.seed,
                        routeConfirmed: (routeName) {
                          _configuration.saveRoute(routeName);
                        },
                      ),
                    )
                : null,
            icon: Icon(Icons.favorite_border),
            label: Text("add route to favourite"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _disposers.forEach((disposer) => disposer());
    super.dispose();
  }
}

extension LocationModeConversion on RouteOriginLocation {
  bool get asBool => this == RouteOriginLocation.custom;
}
