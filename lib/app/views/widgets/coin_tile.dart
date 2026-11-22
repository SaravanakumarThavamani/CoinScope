import 'package:flutter/material.dart';

import 'package:crypto_research_app/app/data/models/coin.dart';
import 'package:crypto_research_app/app/core/theme/app_theme.dart';
import 'package:crypto_research_app/app/core/utils/formatters.dart';
import 'package:crypto_research_app/app/views/widgets/common.dart';
import 'package:crypto_research_app/app/views/widgets/sparkline.dart';

/// One row of the coin list / watchlist.
class CoinTile extends StatelessWidget {
  final Coin coin;
  final VoidCallback onTap;
  final bool showSparkline;
  const CoinTile({super.key, required this.coin, required this.onTap, this.showSparkline = true});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text('${coin.rank ?? '-'}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ),
            CoinAvatar(coin: coin),
            const SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coin.symbol.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(coin.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
            if (showSparkline)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Sparkline(data: coin.sparkline, positive: (coin.change7d ?? coin.change24h ?? 0) >= 0),
              ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Fmt.price(coin.price),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  ChangeText(coin.change24h, fontSize: 12),
                ],
              ),
            ),
            SizedBox(
              width: 74,
              child: Text(Fmt.compactUsd(coin.marketCap),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            ),
          ],
        ),
      ),
    );
  }
}
