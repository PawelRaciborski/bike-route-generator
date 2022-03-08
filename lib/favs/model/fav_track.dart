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

  final int length;

  FavTrack({
    this.id,
    required this.name,
    required this.seed,
    required this.latitude,
    required this.longitude,
    required this.points,
    required this.length,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'seed': seed,
        'latitude': latitude,
        'longitude': longitude,
        'points': points,
        'length': length,
      };

  FavTrack.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        seed = json['seed'],
        points = json['points'],
        length = json['length'],
        id = null;
}

@dao
abstract class FavTrackDao {
  @Query('SELECT * FROM FavTrack')
  Future<List<FavTrack>> findAllTracks();

  @insert
  Future<void> insertTrack(FavTrack track);
}
