import '../models/crypto_price_update.dart';
import '../repositories/crypto_repository.dart';

class StreamPricesUseCase {
  final CryptoRepository _repository;

  StreamPricesUseCase(this._repository);

  Stream<CryptoPriceUpdate> execute(List<String> symbols) {
    return _repository.streamPrices(symbols);
  }
}
