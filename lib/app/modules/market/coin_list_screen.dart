import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:crypto_research_app/app/modules/market/market_controller.dart';
import 'package:crypto_research_app/app/core/theme/app_theme.dart';
import 'package:crypto_research_app/app/shared/widgets/coin_tile.dart';
import 'package:crypto_research_app/app/shared/widgets/common.dart';
import 'package:crypto_research_app/app/shared/widgets/state_views.dart';
import 'package:crypto_research_app/app/modules/coin_detail/coin_detail_screen.dart';

class CoinListScreen extends StatefulWidget {
  const CoinListScreen({super.key});

  @override
  State<CoinListScreen> createState() => _CoinListScreenState();
}

class _CoinListScreenState extends State<CoinListScreen> {
  final m = Get.find<MarketController>();
  final _search = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
        m.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  OutlineInputBorder get _border => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.border),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.currency_bitcoin, color: AppColors.accent),
            const SizedBox(width: 8),
            const Text(
              'CoinScope',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            Obx(() => SourceBadge(m.source.value)),
          ],
        ),
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (v) {
                m.setQuery(v);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search coins (e.g. bitcoin, eth)',
                prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          m.setQuery('');
                          setState(() {});
                        },
                      ),
                filled: true,
                fillColor: AppColors.card,
                contentPadding: EdgeInsets.zero,
                border: _border,
                enabledBorder: _border,
              ),
            ),
          ),

          SizedBox(
            height: 40,
            child: Obx(() {
              final current = m.filter.value;
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final f in CoinFilter.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f.label),
                        selected: current == f,
                        onSelected: (_) => m.setFilter(f),
                        selectedColor: AppColors.accent.withValues(alpha: 0.2),
                        side: BorderSide(
                          color: current == f
                              ? AppColors.accent
                              : AppColors.border,
                        ),
                        labelStyle: TextStyle(
                          color: current == f
                              ? AppColors.accent
                              : Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),

          SizedBox(
            height: 40,
            child: Obx(() {
              final active = m.sortKey.value;
              final asc = m.ascending.value;
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.sort, size: 18, color: AppColors.muted),
                    ),
                  ),
                  for (final k in SortKey.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(k.label),
                            if (active == k) ...[
                              const SizedBox(width: 4),
                              Icon(
                                asc ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 14,
                                color: AppColors.accent,
                              ),
                            ],
                          ],
                        ),
                        onPressed: () => m.setSort(k),
                        backgroundColor: AppColors.card,
                        side: BorderSide(
                          color: active == k
                              ? AppColors.accent
                              : AppColors.border,
                        ),
                        labelStyle: TextStyle(
                          color: active == k
                              ? AppColors.accent
                              : Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
          const Divider(height: 8),
          Expanded(child: Obx(_body)),
        ],
      ),
    );
  }

  Widget _body() {
    switch (m.status.value) {
      case LoadStatus.loading:
        return const LoadingList();
      case LoadStatus.error:
        return ErrorView(
          message: m.error.value ?? 'Unknown error',
          onRetry: m.load,
        );
      case LoadStatus.loaded:
        final items = m.coins.toList();
        if (items.isEmpty) {
          final q = m.query.value;
          return EmptyView(
            icon: Icons.search_off,
            title: 'No coins found',
            subtitle: q.isEmpty
                ? 'Nothing matches the "${m.filter.value.label}" filter right now.'
                : 'Nothing matches "$q". Try another name or symbol.',
            action: OutlinedButton(
              onPressed: () {
                _search.clear();
                m.resetFilters();
                setState(() {});
              },
              child: const Text('Clear search & filters'),
            ),
          );
        }
        final more = m.hasMore.value;
        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: m.refresh,
          child: ListView.separated(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: items.length + (more ? 1 : 0),
            separatorBuilder: (_, _) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (_, i) {
              if (i >= items.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return CoinTile(coin: items[i], onTap: () => openCoin(items[i]));
            },
          ),
        );
    }
  }
}
