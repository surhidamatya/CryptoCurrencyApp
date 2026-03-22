import '../models/crypto.dart';
import '../repositories/crypto_repository.dart';

class FetchMarketUseCase {
  final CryptoRepository _repository;

  FetchMarketUseCase(this._repository);

  Future<List<Crypto>> execute({int page = 1}) {
    return _repository.getMarket(page: page);
  }
}
