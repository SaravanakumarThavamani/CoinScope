import 'package:get/get.dart';

import 'package:crypto_research_app/app/data/models/coin.dart';
import 'package:crypto_research_app/app/data/services/api_service.dart';
import 'package:crypto_research_app/app/controllers/market_controller.dart' show LoadStatus, SortKey;

/// Watchlist is stored on the Flask backend (watchlist.json), so it survives restarts.
class WatchlistController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final status = LoadStatus.loading.obs;
  final error = RxnString();
  final ids = <String>{}.obs;
  final coins = <Coin>[].obs;

  // local sorting for the watchlist screen
  final sortKey = SortKey.marketCap.obs;
  final ascending = false.obs;

  bool isWatched(String id) => ids.contains(id);
  int get count => ids.length;
  bool get isEmpty => status.value == LoadStatus.loaded && coins.isEmpty;

  List<Coin> get sortedCoins {
    int cmp(Coin a, Coin b) => switch (sortKey.value) {
          SortKey.marketCap => (a.marketCap ?? 0).compareTo(b.marketCap ?? 0),
          SortKey.price => (a.price ?? 0).compareTo(b.price ?? 0),
          SortKey.change24h => (a.change24h ?? 0).compareTo(b.change24h ?? 0),
          SortKey.volume => (a.volume ?? 0).compareTo(b.volume ?? 0),
          SortKey.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        };
    final list = coins.toList();
    list.sort((a, b) => ascending.value ? cmp(a, b) : cmp(b, a));
    return list;
  }

  void setSort(SortKey k) {
    if (k == sortKey.value) {
      ascending.value = !ascending.value;
    } else {
      sortKey.value = k;
      ascending.value = k == SortKey.name;
    }
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    status.value = LoadStatus.loading;
    error.value = null;
    try {
      final idList = await _api.getWatchlistIds();
      final list = await _api.getWatchlistCoins();
      ids.clear();
      ids.addAll(idList);
      coins.assignAll(list);
      status.value = LoadStatus.loaded;
    } on ApiException catch (e) {
      error.value = e.message;
      status.value = LoadStatus.error;
    }
  }

  Future<void> refreshCoins() async {
    try {
      coins.assignAll(await _api.getWatchlistCoins());
      status.value = LoadStatus.loaded;
      error.value = null;
    } on ApiException catch (e) {
      if (coins.isEmpty) {
        error.value = e.message;
        status.value = LoadStatus.error;
      }
    }
  }

  /// Optimistic toggle: update UI instantly, roll back if the server call fails.
  /// Returns an error message, or null on success.
  Future<String?> toggle(Coin coin) async {
    final wasWatched = ids.contains(coin.id);
    _apply(coin, add: !wasWatched);
    try {
      if (wasWatched) {
        await _api.removeFromWatchlist(coin.id);
      } else {
        await _api.addToWatchlist(coin.id);
      }
      return null;
    } on ApiException catch (e) {
      _apply(coin, add: wasWatched); // rollback
      return e.message;
    }
  }

  void _apply(Coin coin, {required bool add}) {
    if (add) {
      ids.add(coin.id);
      if (!coins.any((c) => c.id == coin.id)) coins.add(coin);
    } else {
      ids.remove(coin.id);
      coins.removeWhere((c) => c.id == coin.id);
    }
  }
}
