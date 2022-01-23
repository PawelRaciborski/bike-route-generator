import 'package:bike_route_generator/favs/model/fav_repo.dart';
import 'package:bike_route_generator/favs/model/fav_route.dart';
import 'package:flutter/material.dart';

class FavouriteRoute extends StatelessWidget {
  final FavRouteRepository routeRepository;

  FavouriteRoute(this.routeRepository, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text("Favourite routs"),
      ),
      body: FutureBuilder<List<FavRoute>>(
        builder: (context, snapshot) {
          final routesNames = snapshot.data?.map((e) => e.name) ?? ['No data'];

          return ListView.builder(
            itemBuilder: (context, index) {
              return Text(routesNames.elementAt(index));
            },
            itemCount: routesNames.length,
          );
        },
        future: routeRepository.getAll(),
        initialData: List.empty(),
      ));
}
