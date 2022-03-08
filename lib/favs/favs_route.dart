import 'package:bike_route_generator/favs/model/fav_repo.dart';
import 'package:bike_route_generator/favs/model/fav_track.dart';
import 'package:flutter/material.dart';

class FavouriteRoute extends StatelessWidget {
  final FavRouteRepository routeRepository;

  FavouriteRoute(this.routeRepository, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text("Favourite routs"),
      ),
      body: FutureBuilder<List<FavTrack>>(
        builder: (context, snapshot) {
          if(snapshot.data == null) {
            return Text('No Data!');
          }

          final List<FavTrack> tracks = snapshot.data as List<FavTrack>;

          return ListView.builder(
            itemBuilder: (context, index) {
              var selectedElement = tracks.elementAt(index);
              return ListTile(
              title: Text(selectedElement.name),
              onTap: () {
                Navigator.pop(context, selectedElement);
              },
            );
            },
            itemCount: tracks.length,
          );
        },
        future: routeRepository.getAll(),
        initialData: List.empty(),
      ));
}
