import 'package:get/get.dart';

import 'package:crypto_research_app/app/data/services/storage_service.dart';
import 'package:crypto_research_app/app/routes/app_routes.dart';

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
