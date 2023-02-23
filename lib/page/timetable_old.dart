import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/util.dart';
import '../components/num_list.dart';
import 'settings.dart';
import '../services/gtfs_fetch.dart';
import 'search_time.dart';
import '../data/stop.dart';
import '../data/route.dart';

late TimetablePageState timetableState;

class TimetablePageState extends State<TimetablePage> {
  bool update = false;
  bool searching = false;

  final TextEditingController searchController = TextEditingController();
  List<Stop> searchResults = [];

  void rebuild() {
    setState(() => update = !update);
  }

  Widget showRoutes() {
    timetableState = this;
    return stops.keys.isEmpty
        ? FutureBuilder<FetchResponse>(
            future: fetchData(),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return StackPage(snapshot.data);
              }
              return const Center(child: CircularProgressIndicator());
            },
          )
        : StackPage(FetchResponse(true));
  }

  Widget getStopSubtitle(List<RouteType?> routes) {
    final Map<String?, RouteType?> rs = {};

    for (var route in routes) {
      if (rs[route!.number] == null) rs[route.number] = route;
    }

    return GridView.extent(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 5),
      maxCrossAxisExtent: 25.0,
      childAspectRatio: 1.5,
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      children: rs.values
          .map((m) => Container(
                color: colors[m!.transport!],
                child: Center(
                    child: Text(m.number!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).canvasColor,
                          fontWeight: FontWeight.w600,
                        ))),
              ))
          .toList(),
    );
  }

  List<RouteType?> getStopRoutes(Stop stop) {
    final List<String> ids = stop.id!.split(',');
    final Map<String, RouteType?> rs = {};

    for (String id in ids) {
      for (var r in stops[id]!.routes) {
        rs[r] = routes[r];
      }
    }

    return rs.values.toList()..sort(sortRoutes);
  }

  Widget showResults() {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, i) {
        final Stop stop = searchResults[i];
        final List<RouteType?> routes = getStopRoutes(stop);
        return ListTile(
          dense: true,
          title: Text(stop.name!, style: const TextStyle(fontSize: 18)),
          subtitle: getStopSubtitle(routes),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => SearchTimePage(routes, stop))),
        );
      },
    );
  }

  void openSearch() {
    /*
      FIXME: Hide and show keyboard to get rid of "[...] on inactive InputConnection" errors
            https://github.com/flutter/flutter/issues/23749
    */
    setState(() => searching = true);
  }

  Future<bool> closeSearch() async {
    searchController.clear();
    searchResults = [];
    setState(() => searching = false);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: WillPopScope(
        onWillPop: searching ? closeSearch : null,
        child: Scaffold(
          appBar: AppBar(
            elevation: Platform.isIOS ? 0 : 4,
            title: searching
                ? TextField(
                    autofocus: true,
                    controller: searchController,
                    onChanged: (val) =>
                        setState(() => searchResults = searchStops(val)),
                    decoration: const InputDecoration(
                        hintText: 'Search...', border: InputBorder.none),
                  )
                : const Text('Timetable'),
            bottom: searching
                ? null
                : TabBar(tabs: [
                    Tab(icon: Icon(Icons.directions_bus, color: colors['bus'])),
                    Tab(icon: Icon(Icons.tram, color: colors['tram'])),
                    Tab(
                        icon:
                            Icon(Icons.directions_bus, color: colors['trol'])),
                  ]),
            actions: [
              IconButton(
                icon: Icon(searching ? Icons.close : Icons.search),
                onPressed: searching ? closeSearch : openSearch,
              ),
              IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()));
                  })
            ],
          ),
          body: searching ? showResults() : showRoutes(),
        ),
      ),
    );
  }
}

class TimetablePage extends StatefulWidget {
  const TimetablePage({Key? key}) : super(key: key);

  @override
  TimetablePageState createState() => TimetablePageState();
}

class StackPage extends StatelessWidget {
  const StackPage(this._response, {Key? key}) : super(key: key);
  final FetchResponse? _response;

  @override
  Widget build(BuildContext context) {
    final FetchResponse response = _response!;

    if (response.success) {
      return const TabBarView(children: [
        NumList('bus'),
        NumList('tram'),
        NumList('trol'),
      ]);
    }

    Container createLine(String str) =>
        Container(child: Text(str), margin: const EdgeInsets.only(bottom: 10));

    final List<Widget?> errorLines = [
      createLine('ERROR'),
      (response.error ?? '').isNotEmpty ? createLine(response.error!) : null,
      ElevatedButton(
          child: const Text('Try again'),
          onPressed: () => timetableState.rebuild()),
    ]..removeWhere((widget) => widget == null);

    return Center(
        child: IntrinsicHeight(
            child: Column(children: errorLines as List<Widget>)));
  }
}
