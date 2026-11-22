import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_research_app/app/data/models/coin.dart';
import 'package:crypto_research_app/app/core/utils/formatters.dart';

void main() {
  test('Coin.fromJson parses numbers and tolerates nulls', () {
    final c = Coin.fromJson({
      'id': 'bitcoin',
      'symbol': 'btc',
      'name': 'Bitcoin',
      'current_price': 59000,
      'market_cap': 1.1e12,
      'total_volume': 2.8e10,
      'max_supply': null,
      'sparkline': [1, 2.5, 3],
    });
    expect(c.price, 59000.0);
    expect(c.maxSupply, isNull);
    expect(c.sparkline.length, 3);
    expect(c.volumeToMarketCap, closeTo(0.0255, 0.001));
  });

  test('Formatters', () {
    expect(Fmt.compactUsd(1.167e12), '\$1.167T');
    expect(Fmt.compactUsd(28.4e9), '\$28.40B');
    expect(Fmt.percent(2.14), '+2.1%');
    expect(Fmt.percent(-0.5), '-0.5%');
    expect(Fmt.supply(null, 'eth'), '∞');
    expect(Fmt.price(0.0000085), '\$0.00000850');
  });
}
