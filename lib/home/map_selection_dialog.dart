import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:map_launcher/map_launcher.dart';

import 'configuration_store.dart';

var selectedMapPrefsKey = "SELECTED_MAP";

class MapSelectionDialog extends StatefulWidget {
  final List<AvailableMap> maps;
  final Configuration configuration;



  const MapSelectionDialog({
    Key? key,
    required this.maps,
    required this.configuration
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapSelectionDialogState();
}

class _MapSelectionDialogState extends State<MapSelectionDialog> {
  bool _rememberSelection = true;

  @override
  Widget build(BuildContext context) => AlertDialog(
        content: Container(
          width: double.minPositive,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.maps.length,
                itemBuilder: (context, index) {
                  var map = widget.maps[index];
                  return ListTile(
                    onTap: () {
                      widget.configuration.selectMap(map, _rememberSelection);
                      Navigator.pop(context, map.mapType);
                    },
                    title: Text(map.mapName),
                    leading: SvgPicture.asset(
                      map.icon,
                      height: 30.0,
                      width: 30.0,
                    ),
                  );
                },
              ),
              CheckboxListTile(
                title: Text("Save selection"),
                value: _rememberSelection,
                onChanged: (value) => setState(() {
                  _rememberSelection = value ?? false;
                }),
              ),
            ],
          ),
        ),
      );
}
