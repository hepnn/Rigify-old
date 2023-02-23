import 'package:flutter/material.dart';
import 'num_tile.dart';
import '../data/route.dart';
import '../rs.dart';

class NumList extends StatelessWidget {
  const NumList(this._transport, {Key? key}) : super(key: key);
  final String? _transport;

  @override
  Widget build(BuildContext context) {
    final List<RouteType> routes = filterRoutes(_transport);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.separated(
        padding: const EdgeInsets.all(5.0),
        itemCount: routes.length,
        itemBuilder: (context, i) {
          final RouteType route = routes[i];
          return Tile(route);
        },
        separatorBuilder: (context, index) => const SizedBox(
          height: 5,
        ),
      ),
    );
  }
}
