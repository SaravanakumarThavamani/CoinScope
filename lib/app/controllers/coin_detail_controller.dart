import 'package:get/get.dart';

import 'package:crypto_research_app/app/data/models/chart_data.dart';
import 'package:crypto_research_app/app/data/models/coin.dart';
import 'package:crypto_research_app/app/data/services/api_service.dart';

/// One instance per opened coin (created with tag = coin id, deleted when the screen closes).
class CoinDetailController extends GetxController {
  CoinDetailController(Coin initial) : coin = initial.obs;

  static const ranges = {'24H': 1, '7D': 7, '1M': 30, '3M': 90, '1Y': 365};

  final ApiService _api = Get.find<ApiService>();
  int _chartReq = 0;

  final Rx<Coin> coin; // list data shows instantly, then gets refreshed
  final days = 7.obs;
  final chart = Rxn<ChartData>();
  final chartLoading = true.obs;
  final chartError = RxnString();
  final descError = RxnString();
  final selected = Rxn<ChartPoint>(); // point under the finger
  final expanded = false.obs;

  String get rangeLabel => ranges.entries
      .firstWhere((e) => e.value == days.value)
      .key
      .replaceAll('24H', '24 hours');

  @override
  void onInit() {
    super.onInit();
    loadDetail();
    loadChart();
  }

  Future<void> loadDetail() async {
    try {
      coin.value = await _api.getCoin(coin.value.id);
      descError.value = null;
    } on ApiException catch (e) {
      descError.value = e.message;
    }
  }

  Future<void> loadChart() async {
    final req = ++_chartReq;
    chartLoading.value = true;
    chartError.value = null;
    selected.value = null;
    try {
      final data = await _api.getChart(coin.value.id, days.value);
      if (req != _chartReq) return;
      chart.value = data;
    } on ApiException catch (e) {
      if (req != _chartReq) return;
      chartError.value = e.message;
    }
    if (req == _chartReq) chartLoading.value = false;
  }

  void setRange(int d) {
    if (d == days.value) return;
    days.value = d;
    loadChart();
  }

  void select(ChartPoint? p) {
    if (p?.time != selected.value?.time) selected.value = p;
  }
}
