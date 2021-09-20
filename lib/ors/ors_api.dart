import 'dart:convert';

import 'package:map_launcher/map_launcher.dart';
import 'package:http/http.dart' as http;

class OrsApi {
  static const String baseUrl =
      "https://api.openrouteservice.org/v2/directions/driving-car/geojson";

  final String apiKey;

  const OrsApi({required this.apiKey});

  Future<List<Coords>> generateRoute() async {
    final String response = await _callBackend();

    final coordsList = _extractCoordsFromResponse(response);

    final step = 100;

    final minimizedCoordsList = List<Coords>.generate(
        (coordsList.length / step).floor(), (index) => coordsList[index * step]);

    minimizedCoordsList.add(coordsList.last);

    return minimizedCoordsList;
  }

  Future<String> _callBackend() async {
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept':
          'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
      'Authorization': apiKey,
    };

    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body:
          '{"coordinates":[[8.681495,49.41461]],"options":{"round_trip":{"length":10000,"points":5,"seed":123}}}',
    );

    return response.body;
  }

  List<Coords> _extractCoordsFromResponse(String response) {
    final responseJson = jsonDecode(response);
    final List<dynamic> coords =
        responseJson['features'][0]['geometry']['coordinates'];
    final list = coords.map((e) => Coords(e[1], e[0])).toList(growable: false);
    return list;
  }
}
