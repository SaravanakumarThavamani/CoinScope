import 'package:get/get.dart';

import 'package:crypto_research_app/app/data/models/market_stats.dart';
import 'package:crypto_research_app/app/data/services/api_service.dart';
import 'package:crypto_research_app/app/modules/market/market_controller.dart' show LoadStatus;

class StatsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final status = LoadStatus.loading.obs;
  final error = RxnString();
  final stats = Rxn<MarketStats>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool showSpinner = true}) async {
    if (showSpinner) {
      status.value = LoadStatus.loading;
      error.value = null;
    }
    try {
      stats.value = await _api.getStats();
      status.value = LoadStatus.loaded;
      error.value = null;
    } on ApiException catch (e) {
      if (stats.value == null) {
        error.value = e.message;
        status.value = LoadStatus.error;
      }
    }
  }
}
