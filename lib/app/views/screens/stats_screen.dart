import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:crypto_research_app/app/data/models/coin.dart';
import 'package:crypto_research_app/app/data/models/market_stats.dart';
import 'package:crypto_research_app/app/controllers/market_controller.dart' show LoadStatus;
import 'package:crypto_research_app/app/controllers/stats_controller.dart';
import 'package:crypto_research_app/app/core/theme/app_theme.dart';
import 'package:crypto_research_app/app/core/utils/formatters.dart';
import 'package:crypto_research_app/app/views/widgets/coin_tile.dart';
import 'package:crypto_research_app/app/views/widgets/common.dart';
import 'package:crypto_research_app/app/views/widgets/state_views.dart';
import 'package:crypto_research_app/app/views/screens/coin_detail_screen.dart';

/// Screen 3: global market statistics.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Get.find<StatsController>();
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('Market Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Obx(() => SourceBadge(p.stats.value?.source ?? '')),
        ]),
      ),
      body: Obx(() {
        switch (p.status.value) {
          case LoadStatus.loading:
            return const LoadingList(rows: 6);
          case LoadStatus.error:
            return ErrorView(message: p.error.value ?? 'Unknown error', onRetry: p.load);
          case LoadStatus.loaded:
            return RefreshIndicator(
              color: AppColors.accent,
              onRefresh: () => p.load(showSpinner: false),
              child: _content(context, p.stats.value!),
            );
        }
      }),
    );
  }

  Widget _content(BuildContext context, MarketStats s) {
    final others = (100 - s.btcDominance - s.ethDominance).clamp(0, 100).toDouble();
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Row(children: [
          Expanded(
            child: _MetricCard(
                label: 'Global Market Cap',
                value: Fmt.compactUsd(s.totalMarketCap),
                change: s.marketCapChange24h),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MetricCard(label: '24h Volume', value: Fmt.compactUsd(s.totalVolume)),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _MetricCard(label: 'Active Coins', value: _n(s.activeCoins)),
          ),
          const SizedBox(width: 12),
          Expanded(child: _MetricCard(label: 'Markets', value: _n(s.markets))),
        ]),
        const SizedBox(height: 12),
        _dominanceCard(s, others),
        const SizedBox(height: 12),
        _fearGreedCard(s),
        const SizedBox(height: 20),
        _coinSection(context, 'Top Gainers (24h)', s.topGainers),
        const SizedBox(height: 16),
        _coinSection(context, 'Top Losers (24h)', s.topLosers),
      ],
    );
  }

  String _n(int v) => v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  Widget _dominanceCard(MarketStats s, double others) {
    const btcColor = Color(0xFFF7931A);
    const ethColor = Color(0xFF627EEA);
    final otherColor = AppColors.accent;
    Widget legend(Color c, String label, double v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label),
            const Spacer(),
            Text('${v.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
        );
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Market Dominance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(children: [
          SizedBox(
            width: 130,
            height: 130,
            child: PieChart(PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 34,
              sections: [
                PieChartSectionData(value: s.btcDominance, color: btcColor, radius: 28, showTitle: false),
                PieChartSectionData(value: s.ethDominance, color: ethColor, radius: 28, showTitle: false),
                PieChartSectionData(value: others, color: otherColor, radius: 28, showTitle: false),
              ],
            )),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(children: [
              legend(btcColor, 'Bitcoin', s.btcDominance),
              legend(ethColor, 'Ethereum', s.ethDominance),
              legend(otherColor, 'Others', others),
            ]),
          ),
        ]),
      ]),
    );
  }

  Widget _fearGreedCard(MarketStats s) {
    final v = s.fearGreedValue.clamp(0, 100);
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Fear & Greed Index',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text('$v · ${s.fearGreedLabel}',
              style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 16),
        Stack(clipBehavior: Clip.none, children: [
          Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(colors: [
                AppColors.down,
                Colors.orange,
                Colors.yellow,
                AppColors.up,
              ]),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment((v / 100) * 2 - 1, 0),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bg, width: 3),
                ),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Extreme Fear', style: TextStyle(color: AppColors.muted, fontSize: 11)),
          Text('Extreme Greed', style: TextStyle(color: AppColors.muted, fontSize: 11)),
        ]),
      ]),
    );
  }

  Widget _coinSection(BuildContext context, String title, List<Coin> coins) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      AppCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          for (var i = 0; i < coins.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            CoinTile(
              coin: coins[i],
              showSparkline: false,
              onTap: () => openCoin(coins[i]),
            ),
          ],
        ]),
      ),
    ]);
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final double? change;
  const _MetricCard({required this.label, required this.value, this.change});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        if (change != null) ...[const SizedBox(height: 2), ChangeText(change, fontSize: 12)],
      ]),
    );
  }
}
