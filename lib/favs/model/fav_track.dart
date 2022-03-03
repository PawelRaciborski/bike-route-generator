import 'dart:async';

import 'package:floor/floor.dart';

@entity
class FavTrack {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;

  final int seed;

  final double latitude;

  final double longitude;

  final int points;

  FavTrack({
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

  FavTrack.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        seed = json['seed'],
        points = json['points'],
        id = null;
}

@dao
abstract class FavTrackDao {
  @Query('SELECT * FROM FavTrack')
  Future<List<FavTrack>> findAllTracks();

  @insert
  Future<void> insertTrack(FavTrack track);
}
