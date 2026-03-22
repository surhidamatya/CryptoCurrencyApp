import '../../core/networking/api_client.dart';
import '../dto/crypto_dto.dart';

class CryptoApi {
  final ApiClient _client;

  CryptoApi(this._client);

  Future<List<CryptoDTO>> getMarket({int page = 1, int perPage = 50}) {
    return _client.get(
      '/coins/markets',
      queryParams: {
        'vs_currency': 'usd',
        'order': 'market_cap_desc',
        'per_page': perPage,
        'page': page,
        'sparkline': false,
        'price_change_percentage': '24h',
      },
      mapper: (data) => (data as List)
          .map((item) => CryptoDTO.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<List<double>> getMarketChart(String coinId, {int days = 7}) async {
    return _client.get(
      '/coins/$coinId/market_chart',
      queryParams: {'vs_currency': 'usd', 'days': days},
      mapper: (data) {
        final prices = (data['prices'] as List);
        return prices
            .map((p) => ((p as List)[1] as num).toDouble())
            .toList();
      },
    );
  }
}
