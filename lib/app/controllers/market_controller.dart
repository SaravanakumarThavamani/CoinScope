import 'dart:async';

import 'package:get/get.dart';

import 'package:crypto_research_app/app/core/config/app_config.dart';
import 'package:crypto_research_app/app/data/models/coin.dart';
import 'package:crypto_research_app/app/data/services/api_service.dart';

enum LoadStatus { loading, loaded, error }

enum SortKey { marketCap, price, change24h, volume, name }

extension SortKeyApi on SortKey {
  String get apiValue => switch (this) {
        SortKey.marketCap => 'market_cap',
        SortKey.price => 'price',
        SortKey.change24h => 'change_24h',
        SortKey.volume => 'volume',
        SortKey.name => 'name',
      };
  String get label => switch (this) {
        SortKey.marketCap => 'Market Cap',
        SortKey.price => 'Price',
        SortKey.change24h => '24h %',
        SortKey.volume => 'Volume',
        SortKey.name => 'Name',
      };
}

enum CoinFilter { all, trending, gainers, losers }

extension CoinFilterLabel on CoinFilter {
  String get apiValue => name;
  String get label => switch (this) {
        CoinFilter.all => 'All',
        CoinFilter.trending => 'Trending',
        CoinFilter.gainers => 'Top Gainers',
        CoinFilter.losers => 'Top Losers',
      };
}

/// Coin list state: search + filter + sort + pagination + auto refresh.
class MarketController extends GetxController {
  static const _pageSize = 20;

  final ApiService _api = Get.find<ApiService>();
  Timer? _timer;
  int _requestId = 0; // ignore out-of-order responses
  int _page = 1;
  String _lastQuery = '';

  // ---- observable state (UI rebuilds through Obx)
  final status = LoadStatus.loading.obs;
  final error = RxnString();
  final coins = <Coin>[].obs;
  final hasMore = false.obs;
  final loadingMore = false.obs;
  final source = ''.obs;

  final query = ''.obs;
  final filter = CoinFilter.all.obs;
  final sortKey = SortKey.marketCap.obs;
  final ascending = false.obs;

  bool get isEmpty => status.value == LoadStatus.loaded && coins.isEmpty;

  @override
  void onInit() {
    super.onInit();
    // GetX worker: wait 400 ms after the user stops typing, then hit the API.
    debounce(query, (_) {
      if (query.value != _lastQuery) load();
    }, time: const Duration(milliseconds: 400));
    _timer = Timer.periodic(AppConfig.autoRefresh, (_) => _silentRefresh());
    load();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> load() async {
    final id = ++_requestId;
    status.value = LoadStatus.loading;
    error.value = null;
    _page = 1;
    _lastQuery = query.value;
    try {
      final res = await _api.getCoins(
        query: query.value,
        filter: filter.value.apiValue,
        sort: sortKey.value.apiValue,
        ascending: ascending.value,
        perPage: _pageSize,
      );
      if (id != _requestId) return;
      coins.assignAll(res.coins);
      hasMore.value = res.hasMore;
      source.value = res.source;
      status.value = LoadStatus.loaded;
    } on ApiException catch (e) {
      if (id != _requestId) return;
      error.value = e.message;
      status.value = LoadStatus.error;
    }
  }

  Future<void> loadMore() async {
    if (loadingMore.value || !hasMore.value || status.value != LoadStatus.loaded) return;
    loadingMore.value = true;
    try {
      final res = await _api.getCoins(
        query: query.value,
        filter: filter.value.apiValue,
        sort: sortKey.value.apiValue,
        ascending: ascending.value,
        page: _page + 1,
        perPage: _pageSize,
      );
      _page++;
      coins.addAll(res.coins);
      hasMore.value = res.hasMore;
    } on ApiException {
      // keep what we have; scrolling again retries
    }
    loadingMore.value = false;
  }

  /// Pull-to-refresh: reloads the same number of rows the user already has.
  @override
  Future<void> refresh() async {
    try {
      final res = await _api.getCoins(
        query: query.value,
        filter: filter.value.apiValue,
        sort: sortKey.value.apiValue,
        ascending: ascending.value,
        perPage: coins.length.clamp(_pageSize, 100).toInt(),
      );
      coins.assignAll(res.coins);
      hasMore.value = res.hasMore;
      source.value = res.source;
      status.value = LoadStatus.loaded;
      error.value = null;
    } on ApiException catch (e) {
      if (coins.isEmpty) {
        error.value = e.message;
        status.value = LoadStatus.error;
      }
    }
  }

  Future<void> _silentRefresh() async {
    if (status.value != LoadStatus.loaded || loadingMore.value) return;
    await refresh();
  }

  void setQuery(String value) => query.value = value.trim();

  void setFilter(CoinFilter f) {
    if (f == filter.value) return;
    filter.value = f;
    load();
  }

  /// Tap the same column again -> flip direction. New column -> descending (name -> ascending).
  void setSort(SortKey key) {
    if (key == sortKey.value) {
      ascending.value = !ascending.value;
    } else {
      sortKey.value = key;
      ascending.value = key == SortKey.name;
    }
    load();
  }

  void resetFilters() {
    query.value = '';
    filter.value = CoinFilter.all;
    load();
  }
}
