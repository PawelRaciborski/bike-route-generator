import 'package:bike_route_generator/favs/model/database.dart';
import 'package:bike_route_generator/favs/model/fav_track.dart';

class FavRouteRepository {
  final AppDatabase _favRouteDatabase;

  FavTrackDao get _favRouteDao => _favRouteDatabase.favRouteDao;

  FavRouteRepository(this._favRouteDatabase);

  static Future<FavRouteRepository> initialize() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('brg_database.db').build();
    return FavRouteRepository(database);
  }

  // Decouple DB model from logic model
  Future<void> insertLocation(FavTrack favRoute) =>
      _favRouteDao.insertTrack(favRoute);

  Future<List<FavTrack>> getAll() => _favRouteDao.findAllTracks();
}
