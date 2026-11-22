class ChartPoint {
  final DateTime time;
  final double price;
  const ChartPoint(this.time, this.price);
}

class ChartData {
  final List<ChartPoint> points;
  final String source;
  const ChartData(this.points, this.source);

  bool get isEmpty => points.isEmpty;

  double get minPrice => points.map((p) => p.price).reduce((a, b) => a < b ? a : b);
  double get maxPrice => points.map((p) => p.price).reduce((a, b) => a > b ? a : b);

  /// % change from first to last point of the selected range.
  double get changePercent {
    if (points.length < 2 || points.first.price == 0) return 0;
    return (points.last.price - points.first.price) / points.first.price * 100;
  }

  factory ChartData.fromJson(Map<String, dynamic> j) {
    final raw = (j['prices'] as List?) ?? const [];
    final pts = raw
        .map((e) => ChartPoint(
              DateTime.fromMillisecondsSinceEpoch((e[0] as num).toInt()),
              (e[1] as num).toDouble(),
            ))
        .toList();
    return ChartData(pts, (j['source'] ?? 'mock') as String);
  }
}
