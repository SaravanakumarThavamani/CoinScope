import 'package:get/get.dart';

import 'package:crypto_research_app/app/data/services/storage_service.dart';
import 'package:crypto_research_app/app/routes/app_routes.dart';

/// Shows the splash for a minimum time, then routes to the intro (first launch) or home.
/// While the splash is visible the app-wide controllers (see AppBinding) are already
/// fetching the first page of market data, so Home opens with data ready.
class SplashController extends GetxController {
  static const minDuration = Duration(milliseconds: 2600);

  final _storage = Get.find<StorageService>();

  @override
  void onReady() {
    super.onReady();
    _route();
  }

  Future<void> _route() async {
    final minimumWait = Future<void>.delayed(minDuration);
    final done = await _storage.isOnboardingDone();
    await minimumWait;
    Get.offAllNamed(done ? AppRoutes.home : AppRoutes.onboarding);
  }
}
