import 'package:flutter/material.dart';

import 'package:crypto_research_app/app/data/models/coin.dart';
import 'package:crypto_research_app/app/core/theme/app_theme.dart';
import 'package:crypto_research_app/app/core/utils/formatters.dart';

class CoinAvatar extends StatelessWidget {
  final Coin coin;
  final double size;
  const CoinAvatar({super.key, required this.coin, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final letter = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent.withValues(alpha: 0.15),
      ),
      child: Text(
        coin.symbol.isEmpty ? '?' : coin.symbol[0].toUpperCase(),
        style: TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.42,
        ),
      ),
    );
    if (coin.image == null) return letter;
    return ClipOval(
      child: Image.network(
        coin.image!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => letter,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : letter,
      ),
    );
  }
}

class ChangeText extends StatelessWidget {
  final double? value;
  final double fontSize;
  final bool bold;
  const ChangeText(
    this.value, {
    super.key,
    this.fontSize = 13,
    this.bold = true,
  });

  @override
  Widget build(BuildContext context) {
    final v = value;
    final color = v == null || v == 0
        ? AppColors.muted
        : (v > 0 ? AppColors.up : AppColors.down);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (v != null && v != 0)
          Icon(
            v > 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: color,
            size: fontSize + 6,
          ),
        Text(
          v == null ? '—' : '${v.abs().toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class SourceBadge extends StatelessWidget {
  final String source;
  const SourceBadge(this.source, {super.key});

  @override
  Widget build(BuildContext context) {
    if (source.isEmpty) return const SizedBox.shrink();
    final live = source == 'live';
    final color = live ? AppColors.up : Colors.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: color),
          const SizedBox(width: 5),
          Text(
            live ? 'LIVE' : 'MOCK',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const StatCell({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

String fmtPct(double? v) => Fmt.percent(v);
