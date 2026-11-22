import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tiny wrapper around SharedPreferences. Never throws: if storage is unavailable
/// the app simply behaves like a first launch (the intro is shown again).
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
    } catch (_) {
      // ignore - worst case the intro shows again next launch
    }
  }
}
