import 'package:hive/hive.dart';

import 'stop.dart';
import '../utils/util.dart';

part 'route.g.dart';

final Map<String, RouteType> routes = {};
final Map<String, bool> usedStops = {};
final Map<String, int> transportOrder = {
  'tram': 1,
  'trol': 2,
  'bus': 3,
  'minibus': 4,
  'expressbus': 5,
  'nightbus': 6,
};

class StopSchedule {
  late Stop stop;
  String? weekdays;
  late String times;
}

@HiveType(typeId: 1)
class RouteType {
  String? id;
  int? order;
  @HiveField(0)
  String? transport;
  @HiveField(1)
  String? number;
  @HiveField(2)
  String? name;
  @HiveField(3)
  String? type;
  late List<Stop> stops = [];
  late List<StopSchedule> times = [];

  String getKeyForType(String? type) {
    return '$number;$transport;$type';
  }

  static fromJson(RouteType? routeType) {
    return RouteType()
      ..id = routeType!.id
      ..order = routeType.order
      ..transport = routeType.transport
      ..number = routeType.number
      ..name = routeType.name
      ..type = routeType.type
      ..stops = routeType.stops
      ..times = routeType.times;
  }
}

void loadRoutes(String text) {
  final List<String> lines = text.split('\n');

  final List<String> fields = lines[0].toUpperCase().split(';');
  final Map<String, int> fld = {};
  for (int i = 0; i < fields.length; i++) {
    fld[fields[i].trim()] = i;
  }

  int order = 0;
  List<String?> done = [];
  String? number = '', directionName, transport;
  for (int i = 1; i < lines.length; i += 2) {
    final String line = lines[i];
    final List<String> parts = line.split(';');

    ++order;

    if (parts[fld['ROUTENUM']!].isNotEmpty) {
      number = parts[fld['ROUTENUM']!];
      order = 1;
    }

    if (parts[fld['TRANSPORT']!].isNotEmpty) {
      transport = parts[fld['TRANSPORT']!];
      order = 1;
    }

    if (number!.length == 3) {
      if (number[0] == '3' && transport != 'expressbus') {
        transport = 'expressbus';
        order = 1;
      }
      if (number[0] == '2' && transport != 'minibus') {
        transport = 'minibus';
        order = 1;
      }
    } else if (transport == 'expressbus' || transport == 'minibus') {
      transport = 'bus';
    }

    final int idx = done.indexOf(transport);
    if (idx > -1 && transport != done[done.length - 1]) continue;
    if (idx == -1) done.add(transport);

    if (parts[fld['ROUTENAME']!].isNotEmpty) {
      directionName = parts[fld['ROUTENAME']!];
    }

    final String type = parts[fld['ROUTETYPE']!];
    final String key = '$number;$transport;$type';

    if (routes.containsKey(key)) continue;

    List<Stop> rstops = [];
    Stop? prevStop;

    for (String sid in parts[fld['ROUTESTOPS']!].split(',')) {
      final Stop? stop = stops[sid];
      if (stop == null) continue;

      usedStops[sid] = true;
      if (prevStop != null && prevStop.name == stop.name) continue;
      prevStop = stop;
      stop.routes.add(key);
      rstops.add(stop);
    }

    final RouteType route = RouteType();
    route.id = key;
    route.transport = transport;
    route.number = number;
    route.name = directionName;
    route.stops = rstops;
    route.type = type;
    route.order = order;
    route.times = explodeTimes(lines[i + 1], rstops);

    routes[key] = route;
  }

  stops.removeWhere((id, _) => !usedStops.containsKey(id));
}

List<int> getAccumulatedTimes(String times) {
  final Iterable<int> array = times.split(',').map(int.parse);
  final List<int> result = [];
  int sum = 0;
  for (int i in array) {
    sum += i;
    result.add(sum);
  }
  return result;
}

List<StopSchedule> explodeTimes(String timesString, List<Stop> stops) {
  final List<StopSchedule> list = [];
  final List<String> timesArray = timesString.split(',,');
  final List<int> times = getAccumulatedTimes(timesArray[0]);
  final List<String> weekdayMetadata = timesArray[3].split(',');
  for (int m = 0; m < stops.length; m++) {
    int timesStartIndex = 0;
    final List<int> correctionItems =
        timesArray[m + 3].split(',').map(int.parse).toList();
    int timeCorrection = m > 0 ? correctionItems[0] : 0;
    int countLimit =
        (m <= 0 || correctionItems.length <= 1) ? 1000 : correctionItems[1];
    int correctionIndex = 1;
    int count = 0;
    for (int i = 0; i < weekdayMetadata.length; i += 2) {
      String timesValue = '';
      final int timesEndIndex = i + 1 >= weekdayMetadata.length
          ? times.length
          : int.parse(weekdayMetadata[i + 1]);
      for (int k = timesStartIndex; k < timesEndIndex; k++) {
        if (k != timesStartIndex) timesValue += ',';
        count++;
        if (count > countLimit) {
          correctionIndex++;
          timeCorrection += correctionItems[correctionIndex] - 5;
          if (correctionIndex + 1 < correctionItems.length) {
            correctionIndex++;
            countLimit = correctionItems[correctionIndex];
          } else {
            countLimit = 1000;
          }
          count = 1;
        }
        final int newTime = times[k] + timeCorrection;
        timesValue += newTime.toString();
        times[k] = newTime;
      }
      if (timesValue.isNotEmpty) {
        final s = StopSchedule();
        s.stop = stops[m];
        s.weekdays = weekdayMetadata[i];
        s.times = timesValue;
        list.add(s);
      }
      timesStartIndex = timesEndIndex;
    }
  }

  return list;
}

int sortRoutes(RouteType? a, RouteType? b) {
  final int diff =
      transportOrder[a!.transport!]! - transportOrder[b!.transport!]!;
  if (diff != 0) return diff;
  if (a.number != b.number) return compare(a.number!, b.number!);

  final List<String> typesA = a.type!.split('-');
  final List<String> typesB = b.type!.split('-');
  if (typesA[0] != typesB[0]) return compare(typesA[0], typesB[0]);
  return compare(typesA[1], typesB[1]);
}
