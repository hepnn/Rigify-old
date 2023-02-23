import 'package:hive_flutter/hive_flutter.dart';
import 'package:rigassat/components/num_tile.dart';

import 'data/route.dart';
import 'data/stop.dart';
import 'main.dart';

List<RouteType> getFavoriteRoutes() {
  final List<String> keys = favoritesBox.keys.cast<String>().toList();
  final List<RouteType> favoriteRoutes = [];
  for (String key in keys) {
    final route = RouteType.fromJson(favoritesBox.get(key));
    favoriteRoutes.add(route);
  }
  return favoriteRoutes;
}

List<RouteType> filterFavoriteRoutes(String? stransport,
    [String snum = '', String stype = '']) {
  final List<RouteType> favoriteRoutes = [];

  for (RouteType route in routes.values) {
    if (favoritesBox.containsKey(route.name)) {
      if (stransport!.isNotEmpty && stransport != route.transport) continue;
      if (snum.isNotEmpty && snum != route.number) continue;
      if (stype.isNotEmpty && stype != route.type) continue;
      favoriteRoutes.add(route);
    }
  }

  return favoriteRoutes;
}

List<RouteType> filterRoutes(String? stransport,
    [String snum = '', String stype = '']) {
  final List<RouteType> results = [];
  final Map<String, RouteType> routesUnique = {};

  for (RouteType route in routes.values) {
    if (stransport!.isNotEmpty && stransport != route.transport) continue;
    if (snum.isNotEmpty && snum != route.number) continue;
    if (stype.isNotEmpty && stype != route.type) continue;

    final String? transport = route.transport;
    final int? order = route.order;
    final String? number = route.number;

    final String key = '$number;$transport';
    if (routesUnique.containsKey(key) && snum.isEmpty && order != 1) continue;

    results.add(route);
    if (stype.isEmpty && key.isNotEmpty) routesUnique[key] = route;
  }
  results.sort(sortRoutes);

  return results;
}

Future<List<RouteType>> getAllRoutes(String? transport) async {
  final box = await Hive.openBox<RouteType>('favorites');
  return box.values.toList();
}

Map<String?, Map<int, List<int>>> getTime(RouteType route, Stop? stop) {
  final Iterable<StopSchedule> schedules =
      route.times.where((time) => time.stop.id == stop!.id);
  final Map<String?, Map<int, List<int>>> sections = {};

  for (StopSchedule schedule in schedules) {
    sections[schedule.weekdays] = {};
    final List<String> times = schedule.times.split(',');
    for (final t in times) {
      final int time = int.parse(t);
      final int h = (time / 60).floor();
      final int m = time % 60;

      if (sections[schedule.weekdays]![h] == null) {
        sections[schedule.weekdays]![h] = [];
      }
      sections[schedule.weekdays]![h]!.add(m);
    }
  }

  return sections;
}

Map<String?, String> getTrip(RouteType route, String? weekdays, int index) {
  final Iterable<StopSchedule> schedules =
      route.times.where((t) => t.weekdays == weekdays);
  final Map<String?, String> times = {};

  for (StopSchedule schedule in schedules) {
    final int time = int.parse(schedule.times.split(',')[index]);
    final int h = (time / 60 % 24).floor();
    final String m = (time % 60).toString().padLeft(2, '0');
    times[schedule.stop.id] = '$h:$m';
  }

  return times;
}
