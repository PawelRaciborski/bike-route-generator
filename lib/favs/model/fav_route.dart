import 'dart:async';

import 'package:floor/floor.dart';

@entity
class FavRoute {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;

  final int seed;

  final double latitude;

  final double longitude;

  final int points;

  FavRoute({
    this.id,
    required this.name,
    required this.seed,
    required this.latitude,
    required this.longitude,
    required this.points,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'seed': seed,
        'latitude': latitude,
        'longitude': longitude,
        'points': points
      };

  FavRoute.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        seed = json['seed'],
        points = json['points'],
        id = null;
}

@dao
abstract class FavRouteDao {
  @Query('SELECT * FROM FavRoute')
  Future<List<FavRoute>> findAllRoutes();

  @insert
  Future<void> insertRoute(FavRoute route);
}
