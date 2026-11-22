import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:crypto_research_app/app/bindings/app_binding.dart';
import 'package:crypto_research_app/app/core/theme/app_theme.dart';
import 'package:crypto_research_app/app/routes/app_pages.dart';

class MiniGeckoApp extends StatelessWidget {
  const MiniGeckoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MiniGecko',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialBinding: AppBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
