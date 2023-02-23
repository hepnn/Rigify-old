import 'package:flutter/material.dart';
import 'package:rigassat/rs.dart';

import '../data/route.dart';
import '../data/stop.dart';
import 'stops.dart';
import 'timetable_old.dart';

class StopTile extends StatefulWidget {
  final Stop stop;
  final RouteType route;

  const StopTile({required this.stop, required this.route});

  @override
  _StopTileState createState() => _StopTileState();
}

class _StopTileState extends State<StopTile> {
  Map<String?, Map<int, List<int>>>? _timetable;

  void _showTimetable() {
    setState(() {
      _timetable = getTime(widget.route, widget.stop);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyText2;

    return GestureDetector(
      onTap: _showTimetable,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.stop.name!,
                style: textStyle!.copyWith(fontWeight: FontWeight.bold)),
            if (_timetable != null) ...[
              for (var entry in _timetable!.entries) ...[
                const SizedBox(height: 5),
                Text(entry.key ?? 'No schedule',
                    style: textStyle.copyWith(fontWeight: FontWeight.bold)),
                for (var hourEntry in entry.value.entries) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(hourEntry.key.toString().padLeft(2, '0') + ':',
                          style:
                              textStyle.copyWith(fontWeight: FontWeight.bold)),
                      for (var minute in hourEntry.value) ...[
                        const SizedBox(width: 5),
                        Text(minute.toString().padLeft(2, '0'),
                            style: textStyle),
                      ],
                    ],
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class Tile extends StatelessWidget {
  final RouteType route;

  const Tile(this.route);

  void showTimetable(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StopsPage(route)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showTimetable(context),
      child: Column(
        children: [
          Row(
            children: [
              Text('${route.transport} ${route.number}'),
              const Spacer(),
            ],
          ),
          Row(
            children: [
              Text('${route.type}'),
              const Spacer(),
              Text('${route.stops.length} stops'),
            ],
          ),
          // Add a new row to display the timetable
          Row(
            children: [
              Expanded(
                child: Text(
                  'Timetable: ${route.times}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
