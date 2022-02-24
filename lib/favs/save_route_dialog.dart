import 'package:bike_route_generator/home/configuration_store.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';

class SaveRouteDialog extends StatefulWidget {
  final RouteOriginLocation selectedMode;
  final Coords? origin;
  final int seed;
  final int length;
  final int points;
  final Function(String) routeConfirmed;

  SaveRouteDialog(
      {required this.selectedMode,
      this.origin,
      required this.seed,
      required this.length,
      required this.points,
      required this.routeConfirmed});

  @override
  State<StatefulWidget> createState() => _SaveRouteDialogState();
}

class _SaveRouteDialogState extends State<SaveRouteDialog> {
  late TextEditingController _textController =
      TextEditingController(text: "route_$_defaultRouteName");

  String get _defaultRouteName {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd-hh-mm-ss');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text("Do you want to save this route?"),
        content: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetails(),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: _textController,
                  onChanged: (text) {
                    setState(() {
                      //no-op
                    });
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Route name",
                      errorText: _textController.text.isEmpty
                          ? "Please set name!"
                          : null),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: _textController.text.isNotEmpty
                  ? () {
                      widget.routeConfirmed(_textController.text);
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text("Save")),
        ],
      );

  Widget _buildDetails() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Origin"),
              const Text("Length"),
              const Text("Seed"),
              const Text("Points"),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Text(
                "${widget.selectedMode == RouteOriginLocation.custom ? widget.origin : "Current location"}",
              ),
              Text("${widget.length}"),
              Text("${widget.seed}"),
              Text("${widget.points}"),
            ],
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
