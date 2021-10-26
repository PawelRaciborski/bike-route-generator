import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:bike_route_generator/ors/url_launching.dart';

class CreditsRoute extends StatelessWidget {
  CreditsRoute({Key? key}) : super(key: key);

  final _libs = {
    "url_launcher": "https://pub.dev/packages/url_launcher",
    "map_launcher": "https://pub.dev/packages/map_launcher",
    "http": "https://pub.dev/packages/http",
    "geolocator": "https://pub.dev/packages/geolocator",
    "flutter_spinbox": "https://pub.dev/packages/flutter_spinbox",
    "Open Route Service": "https://openrouteservice.org/",
  }.entries.toList();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Credits"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
              child: Linkify(
                options: LinkifyOptions(humanize: false),
                text:
                    '''This app utilizes libraries ans services listed below. Source code can be found at https://github.com/PawelRaciborski/bike-route-generator''',
                onOpen: (link) => launchURL(link.url),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _libs.length,
                itemBuilder: (context, index) {
                  var entry = _libs[index];
                  return ListTile(
                    title: Text(entry.key),
                    onTap: () {
                      launchURL(entry.value);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );

}
