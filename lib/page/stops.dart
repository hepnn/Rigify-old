import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rigassat/utils/styles.dart';
import 'package:timelines/timelines.dart';
import '../data/route.dart';
import '../data/stop.dart';
import '../main.dart';
import '../utils/util.dart';
import 'time.dart';

class _StopsPageState extends State<StopsPage> {
  _StopsPageState(this._route);
  RouteType? _route;

  // Box? box = Hive.box('favorites');

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    setState(() => _route);
    _route = routes[_route!.getKeyForType(_route!.type)];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, RouteType> similarRoutes = Map.from(routes)
      ..removeWhere((k, _) {
        return !k.contains(RegExp('^${_route!.number};${_route!.transport}'));
      });

    final String oppositeRoute =
        _route!.getKeyForType(_route!.type!.split('-').reversed.join('-'));
    final List<Stop> stops = _route!.stops;
    final bool openModel =
        similarRoutes.length > (routes.containsKey(oppositeRoute) ? 2 : 1);
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        iconTheme: const IconThemeData(color: Colors.white),
        shape: customShapeBorder,
        elevation: Platform.isIOS ? 0 : 4,
        backgroundColor: colors[_route!.transport!],
        title: openModel
            ? GestureDetector(
                child: Text(
                  _route!.name!,
                ),
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (c) => ListView(
                          children: similarRoutes.values
                              .map((route) => ListTile(
                                    title: Text(route.name!),
                                    onTap: () {
                                      setState(() => _route = routes[
                                          _route!.getKeyForType(route.type)]);
                                      Navigator.pop(c);
                                    },
                                  ))
                              .toList()));
                },
              )
            : Text(
                _route!.name!,
              ),
        actions: routes.containsKey(oppositeRoute)
            ? [
                IconButton(
                  icon: Icon(
                      favoritesBox.containsKey(_route!.name)
                          ? Icons.favorite
                          : Icons.favorite_outline,
                      color: Colors.white),
                  onPressed: () async {
                    setState(() {
                      _isFavorite = !_isFavorite;
                      if (_isFavorite) {
                        favoritesBox.put(_route!.name, _route!);
                      } else {
                        favoritesBox.delete(_route!.name);
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.swap_vert),
                  onPressed: () =>
                      setState(() => _route = routes[oppositeRoute]),
                ),
              ]
            : [],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
        child: Timeline.tileBuilder(
          theme: TimelineThemeData(
              color: colors[_route!.transport!],
              nodePosition: 0,
              connectorTheme:
                  const ConnectorThemeData(space: 30.0, thickness: 2)),
          builder: TimelineTileBuilder.connectedFromStyle(
            connectionDirection: ConnectionDirection.after,
            connectorStyleBuilder: (context, index) {
              return ConnectorStyle.solidLine;
            },
            indicatorStyleBuilder: (context, index) => IndicatorStyle.dot,
            itemExtent: 60,
            itemCount: stops.length,
            contentsBuilder: (context, i) {
              final Stop stop = stops[i];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: double.infinity,
                  width: double.infinity / 2,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => TimePage(_route, stop)));
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        stop.name!,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class StopsPage extends StatefulWidget {
  const StopsPage(this._route, {Key? key}) : super(key: key);
  final RouteType _route;

  @override
  _StopsPageState createState() => _StopsPageState(_route);
}
