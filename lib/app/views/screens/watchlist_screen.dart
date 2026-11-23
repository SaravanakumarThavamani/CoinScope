import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:crypto_research_app/app/controllers/home_controller.dart';
import 'package:crypto_research_app/app/controllers/market_controller.dart'
    show LoadStatus, SortKey, SortKeyApi;
import 'package:crypto_research_app/app/controllers/watchlist_controller.dart';
import 'package:crypto_research_app/app/core/theme/app_theme.dart';
import 'package:crypto_research_app/app/views/widgets/coin_tile.dart';
import 'package:crypto_research_app/app/views/widgets/state_views.dart';
import 'package:crypto_research_app/app/views/screens/coin_detail_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = Get.find<WatchlistController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Watchlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<SortKey>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: w.setSort,
            itemBuilder: (_) => [
              for (final k in SortKey.values)
                PopupMenuItem(
                  value: k,
                  child: Row(
                    children: [
                      Expanded(child: Text(k.label)),
                      if (k == w.sortKey.value)
                        Icon(
                          w.ascending.value
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 16,
                          color: AppColors.accent,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        switch (w.status.value) {
          case LoadStatus.loading:
            return const LoadingList(rows: 5);
          case LoadStatus.error:
            return ErrorView(
              message: w.error.value ?? 'Unknown error',
              onRetry: w.load,
            );
          case LoadStatus.loaded:
            final items = w.sortedCoins;
            if (items.isEmpty) {
              return EmptyView(
                icon: Icons.star_border_rounded,
                title: 'Your watchlist is empty',
                subtitle: 'Tap the star on any coin to track it here.',
                action: FilledButton(
                  onPressed: () => Get.find<HomeController>().tab.value = 0,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Browse coins'),
                ),
              );
            }
            return RefreshIndicator(
              color: AppColors.accent,
              onRefresh: w.refreshCoins,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (_, i) {
                  final coin = items[i];
                  return Dismissible(
                    key: ValueKey(coin.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: AppColors.down.withValues(alpha: 0.85),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (_) async {
                      await w.toggle(coin);
                      Get.closeAllSnackbars();
                      Get.snackbar(
                        'Removed',
                        '${coin.name} removed from watchlist',
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(12),
                        mainButton: TextButton(
                          onPressed: () {
                            w.toggle(coin);
                            Get.closeAllSnackbars();
                          },
                          child: const Text(
                            'UNDO',
                            style: TextStyle(color: AppColors.accent),
                          ),
                        ),
                      );
                    },
                    child: CoinTile(coin: coin, onTap: () => openCoin(coin)),
                  );
                },
              ),
            );
        }
      }),
    );
  }
}
