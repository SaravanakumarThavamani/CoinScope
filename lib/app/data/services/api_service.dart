import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:crypto_research_app/app/core/config/app_config.dart';
import 'package:crypto_research_app/app/data/models/chart_data.dart';
import 'package:crypto_research_app/app/data/models/coin.dart';
import 'package:crypto_research_app/app/data/models/market_stats.dart';

/// Every failure is converted to this so the UI only has to show `message`.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}

class CoinPage {
  final List<Coin> coins;
  final bool hasMore;
  final int total;
  final String source;
  const CoinPage(this.coins, this.hasMore, this.total, this.source);
}

class ApiService {
  final http.Client _client;
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _request(String method, String path,
      [Map<String, String>? query]) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path').replace(queryParameters: query);
    try {
      late http.Response res;
      switch (method) {
        case 'PUT':
          res = await _client.put(uri).timeout(AppConfig.timeout);
          break;
        case 'DELETE':
          res = await _client.delete(uri).timeout(AppConfig.timeout);
          break;
        default:
          res = await _client.get(uri).timeout(AppConfig.timeout);
      }
      final body = res.body.isEmpty ? <String, dynamic>{} : jsonDecode(res.body);
      if (res.statusCode >= 400) {
        final msg = body is Map && body['error'] != null
            ? body['error'].toString()
            : 'Server error (${res.statusCode})';
        throw ApiException(msg);
      }
      return body as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('Request timed out. Is the backend running?');
    } on SocketException {
      throw const ApiException('Cannot reach the server. Check your connection and API URL.');
    } on http.ClientException {
      throw const ApiException('Cannot reach the server. Check your connection and API URL.');
    } on FormatException {
      throw const ApiException('Received an invalid response from the server.');
    }
  }

  Future<CoinPage> getCoins({
    String query = '',
    String filter = 'all',
    String sort = 'market_cap',
    bool ascending = false,
    int page = 1,
    int perPage = 20,
  }) async {
    final j = await _request('GET', '/api/coins', {
      'q': query,
      'filter': filter,
      'sort': sort,
      'order': ascending ? 'asc' : 'desc',
      'page': '$page',
      'per_page': '$perPage',
    });
    final coins =
        (j['coins'] as List).map((e) => Coin.fromJson(e as Map<String, dynamic>)).toList();
    return CoinPage(coins, j['has_more'] == true, (j['total'] as num).toInt(), j['source'] as String);
  }

  Future<Coin> getCoin(String id) async {
    final j = await _request('GET', '/api/coins/$id');
    return Coin.fromJson(j['coin'] as Map<String, dynamic>);
  }

  Future<ChartData> getChart(String id, int days) async {
    final j = await _request('GET', '/api/coins/$id/chart', {'days': '$days'});
    return ChartData.fromJson(j);
  }

  Future<MarketStats> getStats() async =>
      MarketStats.fromJson(await _request('GET', '/api/stats'));

  Future<List<String>> getWatchlistIds() async {
    final j = await _request('GET', '/api/watchlist');
    return (j['ids'] as List).cast<String>();
  }

  Future<List<Coin>> getWatchlistCoins() async {
    final j = await _request('GET', '/api/watchlist/coins');
    return (j['coins'] as List).map((e) => Coin.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addToWatchlist(String id) => _request('PUT', '/api/watchlist/$id');
  Future<void> removeFromWatchlist(String id) => _request('DELETE', '/api/watchlist/$id');
}
