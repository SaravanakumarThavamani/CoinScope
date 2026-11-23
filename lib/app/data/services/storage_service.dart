import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  static const _kOnboardingDone = 'onboarding_done';

  Future<bool> isOnboardingDone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kOnboardingDone) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> setOnboardingDone([bool value = true]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kOnboardingDone, value);
    } catch (_) {}
  }
}
