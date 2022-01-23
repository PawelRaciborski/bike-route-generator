import 'package:bike_route_generator/favs/model/database.dart';
import 'package:bike_route_generator/favs/model/fav_route.dart';

class FavRouteRepository {
  final AppDatabase _favRouteDatabase;

  FavRouteDao get _favRouteDao => _favRouteDatabase.favRouteDao;

  FavRouteRepository(this._favRouteDatabase);

  static Future<FavRouteRepository> initialize() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('brg_database.db').build();
    return FavRouteRepository(database);
  }

  Future<void> insertLocation(String name) => _favRouteDao.insertRoute(FavRoute(
        latitude: 1.0,
        longitude: 1.0,
        name: name,
        seed: 1,
      ));

  Future<List<FavRoute>> getAll() => _favRouteDao.findAllRoutes();
}
