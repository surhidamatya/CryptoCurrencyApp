import '../../domain/models/crypto.dart';
import '../../domain/models/crypto_price_update.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../../core/websocket/websocket_manager.dart';
import '../api/crypto_api.dart';
import '../dto/binance_trade.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  final CryptoApi _api;
  final WebSocketManager _webSocket;

  CryptoRepositoryImpl(this._api, this._webSocket);

  @override
  Future<List<Crypto>> getMarket({int page = 1, int perPage = 50}) async {
    final dtos = await _api.getMarket(page: page, perPage: perPage);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Stream<CryptoPriceUpdate> streamPrices(List<String> symbols) {
    return _webSocket.connect(symbols).map((json) {
      final trade = BinanceTrade.fromJson(json);
      return CryptoPriceUpdate(symbol: trade.symbol, price: trade.price);
    });
  }

  @override
  Future<List<double>> getPriceHistory(String coinId) {
    return _api.getMarketChart(coinId);
  }
}
