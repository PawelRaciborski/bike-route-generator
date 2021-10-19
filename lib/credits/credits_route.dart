import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

//TODO: Add ORS info
class CreditsRoute extends StatelessWidget {
  CreditsRoute({Key? key}) : super(key: key);

  final List<String> _libs = [
    "url_launcher",
    "map_launcher",
    "http",
    "geolocator",
    "flutter_spinbox",
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Credits"),
        ),
        body: ListView.builder(
          itemCount: _libs.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(_libs[index]),
            onTap: () {
              _launchURL("https://pub.dev/packages/${_libs[index]}");
            },
          ),
        ),
      );

  void _launchURL(String url) async => await canLaunch(url)
      ? await launch(
          url,
          forceSafariVC: false,
          forceWebView: false,
        )
      : throw 'Could not launch $url';
}
