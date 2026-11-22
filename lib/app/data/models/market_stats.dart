import 'package:crypto_research_app/app/data/models/coin.dart';

double _d(dynamic v) => v is num ? v.toDouble() : 0;

class MarketStats {
  final double totalMarketCap;
  final double totalVolume;
  final double marketCapChange24h;
  final double btcDominance;
  final double ethDominance;
  final int activeCoins;
  final int markets;
  final int fearGreedValue;
  final String fearGreedLabel;
  final List<Coin> topGainers;
  final List<Coin> topLosers;
  final String source;

  const MarketStats({
    required this.totalMarketCap,
    required this.totalVolume,
    required this.marketCapChange24h,
    required this.btcDominance,
    required this.ethDominance,
    required this.activeCoins,
    required this.markets,
    required this.fearGreedValue,
    required this.fearGreedLabel,
    required this.topGainers,
    required this.topLosers,
    required this.source,
  });

  factory MarketStats.fromJson(Map<String, dynamic> j) {
    final g = j['global'] as Map<String, dynamic>;
    final f = j['fear_greed'] as Map<String, dynamic>;
    List<Coin> coins(String k) =>
        ((j[k] as List?) ?? const []).map((e) => Coin.fromJson(e as Map<String, dynamic>)).toList();
    return MarketStats(
      totalMarketCap: _d(g['total_market_cap']),
      totalVolume: _d(g['total_volume']),
      marketCapChange24h: _d(g['market_cap_change_24h']),
      btcDominance: _d(g['btc_dominance']),
      ethDominance: _d(g['eth_dominance']),
      activeCoins: (g['active_cryptocurrencies'] as num?)?.toInt() ?? 0,
      markets: (g['markets'] as num?)?.toInt() ?? 0,
      fearGreedValue: (f['value'] as num?)?.toInt() ?? 50,
      fearGreedLabel: (f['label'] ?? '') as String,
      topGainers: coins('top_gainers'),
      topLosers: coins('top_losers'),
      source: (j['source'] ?? 'mock') as String,
    );
  }
}
