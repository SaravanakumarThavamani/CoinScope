import 'package:get/get.dart';

import 'package:crypto_research_app/app/controllers/home_controller.dart';
import 'package:crypto_research_app/app/controllers/market_controller.dart';
import 'package:crypto_research_app/app/controllers/stats_controller.dart';
import 'package:crypto_research_app/app/controllers/watchlist_controller.dart';
import 'package:crypto_research_app/app/data/services/api_service.dart';
import 'package:crypto_research_app/app/data/services/storage_service.dart';

/// Dependency injection: everything is registered once here, then fetched with Get.find().
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put(HomeController(), permanent: true);
    Get.put(MarketController(), permanent: true);
    Get.put(StatsController(), permanent: true);
    Get.put(WatchlistController(), permanent: true);
  }
}
