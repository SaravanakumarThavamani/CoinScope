import 'package:flutter_test/flutter_test.dart';

import 'package:crypto_research_app/app/controllers/onboarding_controller.dart';
import 'package:crypto_research_app/app/routes/app_pages.dart';
import 'package:crypto_research_app/app/routes/app_routes.dart';

void main() {
  test('Onboarding has content for every page', () {
    expect(OnboardingController.items.length, greaterThanOrEqualTo(3));
    for (final item in OnboardingController.items) {
      expect(item.title, isNotEmpty);
      expect(item.body, isNotEmpty);
    }
  });

  test('App starts on the splash route and registers all routes', () {
    expect(AppPages.initial, AppRoutes.splash);
    final names = AppPages.routes.map((r) => r.name).toList();
    expect(names, containsAll([AppRoutes.splash, AppRoutes.onboarding, AppRoutes.home]));
  });
}
