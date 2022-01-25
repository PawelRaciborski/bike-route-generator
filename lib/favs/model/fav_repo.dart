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

  // Decouple DB model from logic model
  Future<void> insertLocation(FavRoute favRoute) =>
      _favRouteDao.insertRoute(favRoute);

  Future<List<FavRoute>> getAll() => _favRouteDao.findAllRoutes();
}
