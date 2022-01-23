import 'dart:async';

import 'package:bike_route_generator/favs/model/fav_route.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

@Database(version: 1, entities: [FavRoute])
abstract class AppDatabase extends FloorDatabase {
  FavRouteDao get favRouteDao;
}
