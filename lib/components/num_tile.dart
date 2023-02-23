import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/route.dart';
import '../main.dart';
import '../utils/util.dart';
import '../page/stops.dart';

//   List tile showing the route number, name and transport type

class Tile extends StatefulWidget {
  const Tile(this._route, {Key? key}) : super(key: key);
  final RouteType _route;

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => StopsPage(widget._route))),
      onLongPress: () {
        _addFavDialog(context);
      },
      child: Consumer(builder: (context, ref, child) {
        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(
                height: 60,
                width: 60,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: colors[widget._route.transport],
                  elevation: 4,
                  child: Center(
                    child: ClipRRect(
                      child: Text(
                        widget._route.number!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  widget._route.name!,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
        );
      }),
    );
  }

  _addFavDialog(context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: [
            SimpleDialogOption(
              onPressed: () async {
                print('${widget._route.name}added to favorites');
                favoritesBox.containsKey(widget._route.name)
                    ? favoritesBox.delete(widget._route.name)
                    : favoritesBox.put(widget._route.name, widget._route);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text(favoritesBox.containsKey(widget._route.name)
                  ? 'Remove from favorites'
                  : 'Add to favorites'),
            ),
          ],
          elevation: 10,
          //backgroundColor: Colors.green,
        );
      },
    );
  }
}
