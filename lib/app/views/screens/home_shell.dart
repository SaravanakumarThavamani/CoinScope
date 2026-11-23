import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:crypto_research_app/app/controllers/home_controller.dart';
import 'package:crypto_research_app/app/controllers/watchlist_controller.dart';
import 'package:crypto_research_app/app/views/screens/coin_list_screen.dart';
import 'package:crypto_research_app/app/views/screens/stats_screen.dart';
import 'package:crypto_research_app/app/views/screens/watchlist_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final watch = Get.find<WatchlistController>();
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: home.tab.value,
          children: const [CoinListScreen(), StatsScreen(), WatchlistScreen()],
        ),
      ),
      bottomNavigationBar: Obx(() {
        final n = watch.count;
        return NavigationBar(
          selectedIndex: home.tab.value,
          onDestinationSelected: (i) => home.tab.value = i,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.show_chart),
              label: 'Markets',
            ),
            const NavigationDestination(
              icon: Icon(Icons.pie_chart_outline),
              selectedIcon: Icon(Icons.pie_chart),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: n > 0,
                label: Text('$n'),
                child: const Icon(Icons.star_border_rounded),
              ),
              selectedIcon: Badge(
                isLabelVisible: n > 0,
                label: Text('$n'),
                child: const Icon(Icons.star_rounded),
              ),
              label: 'Watchlist',
            ),
          ],
        );
      }),
    );
  }
}
