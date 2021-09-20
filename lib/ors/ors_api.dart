import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:map_launcher/map_launcher.dart';

class OrsApi {
  static const String baseUrl =
      "https://api.openrouteservice.org/v2/directions/driving-car/geojson";

  final String apiKey;

  const OrsApi({required this.apiKey});

  Future<List<Coords>> generateRoute(Coords origin) async {
    final String response = await _callBackend(origin);

    final coordsList = _extractCoordsFromResponse(response);

    final step = 100;

    final minimizedCoordsList = List<Coords>.generate(
        (coordsList.length / step).floor(),
        (index) => coordsList[index * step]);

    minimizedCoordsList.add(coordsList.last);

    return minimizedCoordsList;
  }

  Future<String> _callBackend(Coords origin) async {
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept':
          'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
      'Authorization': apiKey,
    };

    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: _RequestBody(origin).toJsonString(),
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

class _RequestBody {
  final Coords origin;
  final int length;
  final int points;
  final int seed;

  _RequestBody(
    this.origin, {
    this.length = 10,
    this.points = 5,
    this.seed = 123,
  });

  String toJsonString() {
    return '''
    {
    	"coordinates": [
    		[${origin.longitude},${origin.latitude}]
    	],
    	"options": {
    		"round_trip": {
    			"length": ${length * 1000},
    			"points": $points,
    			"seed": $seed
    		}
    	}
    }
    ''';
  }
}
