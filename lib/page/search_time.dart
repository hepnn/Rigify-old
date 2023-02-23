import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rigassat/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/util.dart';
import 'time.dart';
import '../rs.dart';
import '../data/stop.dart';
import '../data/route.dart';

class SearchTimePage extends StatelessWidget {
  const SearchTimePage(this._routes, this._stop, {super.key});
  final List<RouteType?> _routes;
  final Stop _stop;

  List<Widget> timeToWidget(BuildContext context, Map<int, List<int>?> times) {
    final double max = MediaQuery.of(context).size.width;
    double size = 32.0;

    List<Widget> children = [];
    const int oneH = 13;
    const int twoH = 25;
    const int twoM = 16;

    Widget createText(String text, double size, FontWeight bold,
            [bool large = false]) =>
        Container(
          margin: EdgeInsets.only(right: large ? 5.0 : 2.0),
          child: Text(text,
              style: TextStyle(
                fontSize: size,
                fontWeight: bold,
              )),
        );

    for (int h in times.keys) {
      final List<Widget> temp = [];

      double hSize = ((h % 24) < 10 ? oneH : twoH) + 2.0;
      temp.add(Column(children: [
        createText((h % 24).toString(), 22.0, FontWeight.bold),
      ]));

      for (int m in times[h]!) {
        final bool large = m == times[h]!.last;
        hSize += twoM + (large ? 5.0 : 2.0);
        temp.add(createText(
          m.toString().padLeft(2, '0'),
          14.0,
          FontWeight.normal,
          large,
        ));
      }

      size += hSize;
      if (size > max) break;

      children += temp;
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    final Map<String?, Stop> stops = {};
    final List<String> ids = _stop.id!.split(',');
    for (var route in _routes) {
      stops[route!.id] = route.stops.firstWhere((s) => ids.contains(s.id));
    }

    return Scaffold(
        appBar: AppBar(
          shape: customShapeBorder,
          elevation: Platform.isIOS ? 0 : 4,
          title: Text(_stop.name!),
        ),
        body: ListView.separated(
          itemCount: _routes.length * 2,
          separatorBuilder: (context, i) => i % 2 == 1
              ? Divider(color: Theme.of(context).textTheme.titleLarge!.color)
              : Container(),
          itemBuilder: (context, i) {
            final RouteType route = _routes[(i / 2).floor()]!;
            final Stop? stop = stops[route.id];

            ListTile createTile(Widget title) => ListTile(
                  dense: true,
                  title: title,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => TimePage(route, stop))),
                );

            if (i % 2 == 0) {
              return createTile(Row(children: [
                SizedBox(
                  height: 30,
                  width: 40,
                  child: Card(
                    margin: const EdgeInsets.only(right: 10.0),
                    color: colors[route.transport],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    child: Center(
                        child: Text(route.number!,
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Theme.of(context).canvasColor,
                              fontWeight: FontWeight.w600,
                            ))),
                  ),
                ),
                Flexible(
                    child: Text(route.name!,
                        style: const TextStyle(fontSize: 18.0))),
              ]));
            }

            final Map<String?, Map<int, List<int>>> _times =
                getTime(route, stop);

            final DateTime now = DateTime.now();
            final int hour = now.hour;
            final int minute = now.minute;

            final Iterable<String?> weekdays =
                _times.keys.where((w) => w!.contains(now.weekday.toString()));
            if (weekdays.isEmpty) {
              return createTile(Text(lang.noOperate));
            }

            final String? weekday = weekdays.first;
            final Iterable<int> hours = _times[weekday]!.keys;

            if (hour <= hours.first) {
              return createTile(Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: timeToWidget(context, _times[weekday]!),
              ));
            }

            final List<int>? minutesL = _times[weekday]![hours.last];
            if (hour > hours.last ||
                hour == hours.last && minute > minutesL!.last) {
              return createTile(Text(
                  '${lang.lastDeparture} ${hours.last.toString().padLeft(2, '0')}:${minutesL!.last.toString().padLeft(2, '0')}'));
            }

            final Map<int, List<int>?> times = {};
            for (int h in hours) {
              if (h > hour) times[h] = _times[weekday]![h];
              if (h != hour) continue;

              final List<int> temp = [];
              for (int m in _times[weekday]![h]!) {
                if (m >= minute) temp.add(m);
              }
              if (temp.isNotEmpty) times[h] = temp;
            }

            return createTile(Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: timeToWidget(context, times),
            ));
          },
        ));
  }
}
