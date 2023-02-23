import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:rigassat/utils/util.dart';
import '../page/favorites.dart';
import '../page/home.dart';
import '../page/news_feed.dart';

class ConvexBottomBar extends StatefulWidget {
  const ConvexBottomBar({super.key});

  @override
  State<ConvexBottomBar> createState() => _ConvexBottomBarState();
}

class _ConvexBottomBarState extends State<ConvexBottomBar>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: const [
          FavoritePage(),
          HomePage(),
          TwitterEmbed(),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        activeColor: colors['bus'],
        color: Colors.grey,
        style: TabStyle.reactCircle,
        items: const [
          TabItem(icon: Icons.favorite),
          TabItem(icon: Icons.home),
          TabItem(icon: Icons.newspaper),
        ],
        initialActiveIndex: 1,
        controller: _tabController,
        onTap: (clickedIndex) {
          setState(() {});
        },
      ),
    );
  }
}
