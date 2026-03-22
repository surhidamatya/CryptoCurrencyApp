import '../models/crypto.dart';
import '../models/crypto_price_update.dart';

abstract class CryptoRepository {
  Future<List<Crypto>> getMarket({int page = 1, int perPage = 50});
  Stream<CryptoPriceUpdate> streamPrices(List<String> symbols);
  Future<List<double>> getPriceHistory(String coinId);
}
