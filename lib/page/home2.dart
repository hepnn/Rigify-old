import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:rigassat/page/settings.dart';
import 'package:rigassat/services/gtfs_fetch.dart';
import 'package:rigassat/components/num_list.dart';
import '../data/stop.dart';
import 'timetable_old.dart';
import '../utils/styles.dart';
import 'package:rigassat/utils/util.dart';
import '../data/route.dart';
import 'search_time.dart';

HomePageTwoState? homepageState;

class HomePageTwo extends StatefulWidget {
  const HomePageTwo(this.choice, {Key? key}) : super(key: key);

  final String choice;

  @override
  HomePageTwoState createState() => HomePageTwoState();
}

class HomePageTwoState extends State<HomePageTwo> {
  bool update = false;
  bool searching = false;

  final TextEditingController searchController = TextEditingController();
  List<Stop> searchResults = [];

  void rebuild() {
    setState(() => update = !update);
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

  Widget showRoutes(String? choice) {
    homepageState = this;
    return stops.keys.isEmpty
        ? FutureBuilder<FetchResponse>(
            future: fetchData(),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return BrackPage(
                  snapshot.data,
                  choice: widget.choice,
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          )
        : BrackPage(
            FetchResponse(true),
            choice: choice,
          );
  }

  @override
  Widget build(BuildContext context) {
    final String name = transportNames[widget.choice]!;
    final lang = AppLocalizations.of(context);

    String getLocalizedString(String key, context) {
      // Weird implementation of localization, but it works lol
      switch (key) {
        case 'Autobuss':
          return lang.bus;
        case 'Tramvajs':
          return lang.tramway;
        case 'Trolejbuss':
          return lang.trolleybus;
      }
      return key;
    }

    List<String?> getTransportNames() {
      final List<String?> names = [];
      for (var t in transportNames.values) {
        names.add(getLocalizedString(t, context));
      }
      return names;
    }

    String localizedString = getLocalizedString(name, context);

    return WillPopScope(
      onWillPop: searching ? closeSearch : () => Future.value(true),
      child: Scaffold(
        appBar: AppBar(
          shape: customShapeBorder,
          title: searching
              ? TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                  ),
                  onChanged: (text) {
                    setState(() {
                      searchResults = stops.values
                          .where((stop) => stop.name!
                              .toLowerCase()
                              .contains(text.toLowerCase()))
                          .toList();
                    });
                  },
                )
              : getTransportNames().contains(localizedString)
                  ? Text(localizedString)
                  : Text(name),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: openSearch,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
        ),
        body: searching ? showResults() : showRoutes(widget.choice),
      ),
    );
  }
}

class BrackPage extends StatelessWidget {
  const BrackPage(this._response, {Key? key, this.choice}) : super(key: key);
  final FetchResponse? _response;
  final String? choice;

  @override
  Widget build(BuildContext context) {
    final FetchResponse response = _response!;

    if (response.success) {
      return NumList(choice);
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
