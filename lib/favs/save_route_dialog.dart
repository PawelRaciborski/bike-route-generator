import 'package:bike_route_generator/home/configuration_store.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

class SaveRouteDialog extends StatefulWidget {
  final RouteOriginLocation selectedMode;
  final Coords? origin;
  final int seed;
  final int length;
  final int points;

  SaveRouteDialog({
    required this.selectedMode,
    this.origin,
    required this.seed,
    required this.length,
    required this.points,
  });

  @override
  State<StatefulWidget> createState() => _SaveRouteDialogState();
}

class _SaveRouteDialogState extends State<SaveRouteDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Do you want to save this route?"),
      content: Container(

      ),
    );
  }
}
