import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:rigassat/components/reodrable_listview.dart';
import 'package:rigassat/rs.dart';
import '../components/num_tile.dart';
import '../components/shimmer_skeleton_card.dart';
import '../data/route.dart';
import '../main.dart';
import '../utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  ScrollController _scrollController = ScrollController();
  final GlobalKey _reorderableListKey = GlobalKey();

  bool _reorderEnabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
          shape: customShapeBorder,
          title: Text(lang.favRoutesTitle),
          actions: [
            IconButton(
              icon: Icon(
                  _reorderEnabled ? Icons.reorder : Icons.reorder_outlined),
              onPressed: () {
                setState(() {
                  _reorderEnabled = !_reorderEnabled;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _dialog();
              },
            )
          ]),
      body: favoritesBox.isEmpty
          ? Center(
              child: Container(
                alignment: Alignment.center,
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Icon(Icons.info, size: 50),
                      const SizedBox(height: 20),
                      Text(lang.favRoutesEmpty,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 20),
                      Text(lang.favRoutesInfo,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ]),
              ),
            )
          // : ValueListenableBuilder(
          //     valueListenable: favoritesBox.listenable(),
          //     builder: (context, dynamic box, child) {
          //       final List<RouteType> favoriteRouted = getFavoriteRoutes();
          //       return Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: RefreshIndicator(
          //           onRefresh: () async {
          //             await Future.delayed(const Duration(milliseconds: 500));
          //             setState(() {});
          //           },
          //           child: ListView.separated(
          //             padding: const EdgeInsets.all(5.0),
          //             itemCount: favoritesBox.length,
          //             itemBuilder: (context, i) {
          //               final RouteType route = favoriteRouted[i];
          //               final List<RouteType> filterRouted =
          //                   filterFavoriteRoutes(route.transport);
          //               if (filterRouted.isEmpty) {
          //                 return const NumTileSkeleton();
          //               } else {
          //                 return Tile(route);
          //               }
          //             },
          //             separatorBuilder: (context, index) => const SizedBox(
          //               height: 5,
          //             ),
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          : ValueListenableBuilder(
              valueListenable: favoritesBox.listenable(),
              builder: (context, dynamic box, child) {
                final List<RouteType> favoriteRouted = getFavoriteRoutes();

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(milliseconds: 500));
                      setState(() {});
                    },
                    child: CustomReorderableListView.separated(
                      buildDefaultDragHandles: _reorderEnabled,
                      physics: const BouncingScrollPhysics(),
                      itemCount: favoritesBox.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 2),
                      itemBuilder: (context, i) {
                        final RouteType route = favoriteRouted[i];
                        final List<RouteType> filterRouted =
                            filterFavoriteRoutes(route.transport);
                        if (filterRouted.isEmpty) {
                          return const NumTileSkeleton();
                        } else {
                          return Stack(
                            key: ValueKey('abcd - $i'),
                            children: [
                              Tile(route),
                            ],
                          );
                        }
                      },
                      shrinkWrap: true,
                      onReorder: _reorderEnabled
                          ? (int oldIndex, int newIndex) {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              setState(() {
                                final oldItem = favoritesBox.getAt(oldIndex);
                                final newItem = favoritesBox.getAt(newIndex);

                                favoritesBox.putAt(oldIndex, newItem!);
                                favoritesBox.putAt(newIndex, oldItem!);
                              });
                            }
                          : (int oldIndex, int newIndex) {},
                      scrollController: _scrollController,
                      proxyDecorator: (Widget child, _, animation) {
                        return AnimatedBuilder(
                          child: child,
                          animation: animation,
                          builder: (BuildContext context, Widget? child) {
                            final animValue =
                                Curves.easeInOut.transform(animation.value);
                            final scale = lerpDouble(1, 1.05, animValue)!;
                            final elevation = lerpDouble(0, 6, animValue)!;
                            return Transform.scale(
                              scale: scale,
                              child: Material(
                                elevation: elevation,
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.transparent,
                                child: child,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  _dialog() async {
    await showDialog(
      builder: (context) {
        final lang = AppLocalizations.of(context);
        // Box? box = Hive.box('favorites');
        return AlertDialog(
          title: Text(lang.deleteTitle),
          content: Text(lang.deleteMsg),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text(lang.no),
            ),
            TextButton(
              onPressed: () {
                favoritesBox.deleteAll(favoritesBox.keys);
                Navigator.of(context, rootNavigator: true).pop();
                setState(() {});
              },
              child: Text(lang.yes),
            ),
          ],
        );
      },
      context: context,
    );
  }
}

class NumTileSkeleton extends StatelessWidget {
  const NumTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
          Skeleton(
            width: 60,
            height: 60,
          ),
          SizedBox(width: 12),
          Flexible(
            child: Skeleton(
              height: 15,
              width: 150,
            ),
          ),
        ]),
      ),
    );
  }
}
