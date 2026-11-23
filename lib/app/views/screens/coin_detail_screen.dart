import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:crypto_research_app/app/controllers/coin_detail_controller.dart';
import 'package:crypto_research_app/app/controllers/watchlist_controller.dart';
import 'package:crypto_research_app/app/data/models/coin.dart';
import 'package:crypto_research_app/app/core/theme/app_theme.dart';
import 'package:crypto_research_app/app/core/utils/formatters.dart';
import 'package:crypto_research_app/app/views/widgets/common.dart';
import 'package:crypto_research_app/app/views/widgets/price_chart.dart';

void openCoin(Coin coin) => Get.to(() => CoinDetailScreen(coin: coin));

class CoinDetailScreen extends StatefulWidget {
  final Coin coin;
  const CoinDetailScreen({super.key, required this.coin});

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  late final CoinDetailController c;
  final w = Get.find<WatchlistController>();

  @override
  void initState() {
    super.initState();
    c = Get.put(CoinDetailController(widget.coin), tag: widget.coin.id);
  }

  @override
  void dispose() {
    Get.delete<CoinDetailController>(tag: widget.coin.id);
    super.dispose();
  }

  Future<void> _toggleWatch() async {
    final err = await w.toggle(c.coin.value);
    if (err != null) {
      Get.snackbar(
        'Watchlist',
        'Could not update: $err',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Row(
            children: [
              CoinAvatar(coin: c.coin.value, size: 26),
              const SizedBox(width: 10),
              Text(c.coin.value.name),
            ],
          ),
        ),
        actions: [
          Obx(() {
            final watched = w.isWatched(widget.coin.id);
            return IconButton(
              tooltip: watched ? 'Remove from watchlist' : 'Add to watchlist',
              onPressed: _toggleWatch,
              icon: Icon(
                watched ? Icons.star_rounded : Icons.star_border_rounded,
                color: watched ? AppColors.accent : null,
                size: 28,
              ),
            );
          }),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () => Future.wait([c.loadDetail(), c.loadChart()]),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            Obx(_header),
            const SizedBox(height: 12),
            Obx(_rangeChips),
            const SizedBox(height: 8),
            SizedBox(height: 260, child: Obx(_chartArea)),
            const SizedBox(height: 20),
            Obx(_statsCard),
            const SizedBox(height: 14),
            Obx(_supplyCard),
            const SizedBox(height: 14),
            Obx(_aboutCard),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final coin = c.coin.value;
    final sel = c.selected.value;
    final chart = c.chart.value;
    final price = sel?.price ?? coin.price;
    final change = chart != null && !c.chartLoading.value
        ? chart.changePercent
        : coin.change24h;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Rank #${coin.rank ?? '-'}',
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              coin.symbol.toUpperCase(),
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          Fmt.price(price),
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            ChangeText(change, fontSize: 15),
            const SizedBox(width: 8),
            Text(
              sel != null
                  ? Fmt.dateTime(sel.time, withTime: c.days.value <= 30)
                  : 'past ${c.rangeLabel}',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _rangeChips() {
    final current = c.days.value;
    return Row(
      children: [
        for (final e in CoinDetailController.ranges.entries)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => c.setRange(e.value),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: current == e.value
                        ? AppColors.accent.withValues(alpha: 0.18)
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: current == e.value
                          ? AppColors.accent
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    e.key,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: current == e.value
                          ? AppColors.accent
                          : Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _chartArea() {
    if (c.chartLoading.value) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    final err = c.chartError.value;
    if (err != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.show_chart, color: AppColors.muted, size: 40),
            const SizedBox(height: 8),
            Text(
              err,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
            TextButton.icon(
              onPressed: c.loadChart,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    final data = c.chart.value;
    if (data == null || data.isEmpty) {
      return const Center(
        child: Text(
          'No chart data available',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }
    return PriceChart(
      data: data,
      rangeLong: c.days.value > 30,
      onSelect: c.select,
    );
  }

  Widget _statsCard() {
    final k = c.coin.value;
    final cells = <Widget>[
      StatCell(label: 'Market Cap', value: Fmt.compactUsd(k.marketCap)),
      StatCell(label: '24h Trading Volume', value: Fmt.compactUsd(k.volume)),
      StatCell(
        label: 'Volume / Market Cap',
        value: k.volumeToMarketCap == null
            ? '—'
            : k.volumeToMarketCap!.toStringAsFixed(4),
      ),
      StatCell(
        label: '7d Change',
        value: Fmt.percent(k.change7d),
        valueColor: (k.change7d ?? 0) >= 0 ? AppColors.up : AppColors.down,
      ),
      StatCell(label: '24h High', value: Fmt.price(k.high24h)),
      StatCell(label: '24h Low', value: Fmt.price(k.low24h)),
      StatCell(label: 'All-Time High', value: Fmt.price(k.ath)),
      StatCell(
        label: 'From ATH',
        value: Fmt.percent(k.athChange),
        valueColor: AppColors.down,
      ),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Statistics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, box) {
              final width = (box.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 16,
                children: [
                  for (final cell in cells) SizedBox(width: width, child: cell),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _supplyCard() {
    final k = c.coin.value;
    final cap = k.maxSupply ?? k.totalSupply;
    final ratio = (k.circulatingSupply != null && cap != null && cap > 0)
        ? (k.circulatingSupply! / cap).clamp(0.0, 1.0)
        : null;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Supply',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          if (ratio != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio.toDouble(),
                minHeight: 8,
                backgroundColor: AppColors.border,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(ratio * 100).toStringAsFixed(1)}% of ${k.maxSupply != null ? 'max' : 'total'} supply in circulation',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 14),
          ],
          LayoutBuilder(
            builder: (context, box) {
              final width = (box.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: width,
                    child: StatCell(
                      label: 'Circulating Supply',
                      value: Fmt.supply(k.circulatingSupply, k.symbol),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: StatCell(
                      label: 'Total Supply',
                      value: Fmt.supply(k.totalSupply, k.symbol),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: StatCell(
                      label: 'Max Supply',
                      value: Fmt.supply(k.maxSupply, k.symbol),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _aboutCard() {
    final k = c.coin.value;
    final expanded = c.expanded.value;
    final text = (k.description ?? '')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${k.name}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (text.isEmpty)
            Text(
              c.descError.value != null
                  ? 'Could not load description.'
                  : 'No description available.',
              style: const TextStyle(color: AppColors.muted),
            )
          else ...[
            Text(
              text,
              maxLines: expanded ? null : 5,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, height: 1.45),
            ),
            if (text.length > 200)
              TextButton(
                onPressed: () => c.expanded.toggle(),
                child: Text(expanded ? 'Show less' : 'Read more'),
              ),
          ],
        ],
      ),
    );
  }
}
