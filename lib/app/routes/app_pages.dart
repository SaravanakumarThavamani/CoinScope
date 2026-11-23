import 'package:get/get.dart';

import 'package:crypto_research_app/app/modules/onboarding/onboarding_controller.dart';
import 'package:crypto_research_app/app/modules/splash/splash_controller.dart';
import 'package:crypto_research_app/app/routes/app_routes.dart';
import 'package:crypto_research_app/app/modules/home/home_shell.dart';
import 'package:crypto_research_app/app/modules/onboarding/onboarding_screen.dart';
import 'package:crypto_research_app/app/modules/splash/splash_screen.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => OnboardingController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeShell(),
      transition: Transition.fadeIn,
    ),
  ];
}
