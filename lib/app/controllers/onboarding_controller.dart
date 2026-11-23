import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:crypto_research_app/app/core/theme/app_theme.dart';
import 'package:crypto_research_app/app/data/services/storage_service.dart';
import 'package:crypto_research_app/app/routes/app_routes.dart';

class OnboardingChip {
  final String label;
  final Color color;
  final Alignment alignment;
  const OnboardingChip(this.label, this.color, this.alignment);
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String body;
  final List<OnboardingChip> chips;
  const OnboardingItem({
    required this.icon,
    required this.title,
    required this.body,
    this.chips = const [],
  });
}

class OnboardingController extends GetxController {
  static const items = <OnboardingItem>[
    OnboardingItem(
      icon: Icons.show_chart_rounded,
      title: 'Live market data',
      body: 'Follow price, 24h volume, market cap and supply for hundreds of coins, '
          'refreshed automatically.',
      chips: [
        OnboardingChip('BTC  +2.4%', AppColors.up, Alignment(-0.95, -0.55)),
        OnboardingChip('ETH  -0.8%', AppColors.down, Alignment(0.95, 0.15)),
        OnboardingChip('Vol \$28.4B', AppColors.muted, Alignment(-0.6, 0.85)),
      ],
    ),
    OnboardingItem(
      icon: Icons.manage_search_rounded,
      title: 'Search, filter & sort',
      body: 'Find any coin instantly. Filter by trending, gainers and losers, and sort by '
          'market cap, price, change or volume.',
      chips: [
        OnboardingChip('Gainers', AppColors.up, Alignment(0.9, -0.6)),
        OnboardingChip('Trending', AppColors.accent, Alignment(-0.95, 0.0)),
        OnboardingChip('Market Cap', AppColors.muted, Alignment(0.6, 0.85)),
      ],
    ),
    OnboardingItem(
      icon: Icons.candlestick_chart_rounded,
      title: 'Interactive charts',
      body: 'Drag across the chart to see the exact price and date. Switch between '
          '24H, 7D, 1M, 3M and 1Y ranges.',
      chips: [
        OnboardingChip('24H', AppColors.accent, Alignment(-0.9, -0.6)),
        OnboardingChip('7D', AppColors.muted, Alignment(0.95, -0.2)),
        OnboardingChip('1Y', AppColors.muted, Alignment(-0.7, 0.8)),
      ],
    ),
    OnboardingItem(
      icon: Icons.star_rounded,
      title: 'Build your watchlist',
      body: 'Star the coins you care about. Your watchlist is saved on the backend and '
          'waiting for you every time you open the app.',
      chips: [
        OnboardingChip('SOL  \u2605', AppColors.accent, Alignment(0.95, -0.5)),
        OnboardingChip('BTC  \u2605', AppColors.accent, Alignment(-0.95, 0.1)),
        OnboardingChip('Swipe to remove', AppColors.muted, Alignment(0.5, 0.88)),
      ],
    ),
  ];

  final _storage = Get.find<StorageService>();
  final pageController = PageController();
  final page = 0.obs;

  bool get isLast => page.value == items.length - 1;

  void onPageChanged(int index) => page.value = index;

  void next() {
    if (isLast) {
      finish();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> finish() async {
    await _storage.setOnboardingDone();
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
