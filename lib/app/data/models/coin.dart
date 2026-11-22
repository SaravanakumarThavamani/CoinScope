double? _d(dynamic v) => v is num ? v.toDouble() : null;

class Coin {
  final String id;
  final String symbol;
  final String name;
  final String? image;
  final int? rank;
  final double? price;
  final double? marketCap;
  final double? volume;
  final double? circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;
  final double? change24h;
  final double? change7d;
  final double? high24h;
  final double? low24h;
  final double? ath;
  final double? athChange;
  final List<double> sparkline;
  final String? description;

  const Coin({
    required this.id,
    required this.symbol,
    required this.name,
    this.image,
    this.rank,
    this.price,
    this.marketCap,
    this.volume,
    this.circulatingSupply,
    this.totalSupply,
    this.maxSupply,
    this.change24h,
    this.change7d,
    this.high24h,
    this.low24h,
    this.ath,
    this.athChange,
    this.sparkline = const [],
    this.description,
  });

  factory Coin.fromJson(Map<String, dynamic> j) => Coin(
        id: j['id'] as String,
        symbol: (j['symbol'] ?? '') as String,
        name: (j['name'] ?? '') as String,
        image: j['image'] as String?,
        rank: (j['market_cap_rank'] as num?)?.toInt(),
        price: _d(j['current_price']),
        marketCap: _d(j['market_cap']),
        volume: _d(j['total_volume']),
        circulatingSupply: _d(j['circulating_supply']),
        totalSupply: _d(j['total_supply']),
        maxSupply: _d(j['max_supply']),
        change24h: _d(j['price_change_percentage_24h']),
        change7d: _d(j['price_change_percentage_7d']),
        high24h: _d(j['high_24h']),
        low24h: _d(j['low_24h']),
        ath: _d(j['ath']),
        athChange: _d(j['ath_change_percentage']),
        sparkline: ((j['sparkline'] as List?) ?? const [])
            .whereType<num>()
            .map((e) => e.toDouble())
            .toList(),
        description: j['description'] as String?,
      );

  /// Volume / market cap - a quick liquidity indicator.
  double? get volumeToMarketCap =>
      (volume != null && marketCap != null && marketCap! > 0) ? volume! / marketCap! : null;
}
