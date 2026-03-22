import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/networking/api_client.dart';
import '../../core/websocket/websocket_manager.dart';
import '../../data/api/crypto_api.dart';
import '../../data/repositories/crypto_repository_impl.dart';
import '../../domain/models/crypto.dart';
import '../../domain/usecases/fetch_market_usecase.dart';
import '../../domain/usecases/stream_prices_usecase.dart';

// --- DI providers ---
final apiClientProvider = Provider((_) => ApiClient());
final webSocketManagerProvider = Provider((_) => WebSocketManager());
final cryptoApiProvider =
    Provider((ref) => CryptoApi(ref.watch(apiClientProvider)));
final cryptoRepositoryProvider = Provider((ref) => CryptoRepositoryImpl(
      ref.watch(cryptoApiProvider),
      ref.watch(webSocketManagerProvider),
    ));
final fetchMarketUseCaseProvider = Provider(
    (ref) => FetchMarketUseCase(ref.watch(cryptoRepositoryProvider)));
final streamPricesUseCaseProvider = Provider(
    (ref) => StreamPricesUseCase(ref.watch(cryptoRepositoryProvider)));

// --- Market state ---
class MarketState {
  final List<Crypto> cryptos;
  final bool isLoading;
  final String? error;
  final String searchText;

  const MarketState({
    this.cryptos = const [],
    this.isLoading = false,
    this.error,
    this.searchText = '',
  });

  List<Crypto> get filteredCryptos {
    if (searchText.isEmpty) return cryptos;
    final query = searchText.toLowerCase();
    return cryptos
        .where((c) =>
            c.name.toLowerCase().contains(query) ||
            c.symbol.toLowerCase().contains(query))
        .toList();
  }

  MarketState copyWith({
    List<Crypto>? cryptos,
    bool? isLoading,
    String? error,
    String? searchText,
  }) {
    return MarketState(
      cryptos: cryptos ?? this.cryptos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchText: searchText ?? this.searchText,
    );
  }
}

class MarketNotifier extends Notifier<MarketState> {
  StreamSubscription? _priceSubscription;

  @override
  MarketState build() {
    ref.onDispose(() => _priceSubscription?.cancel());
    _loadMarket();
    return const MarketState(isLoading: true);
  }

  Future<void> _loadMarket() async {
    try {
      final fetchUseCase = ref.read(fetchMarketUseCaseProvider);
      final cryptos = await fetchUseCase.execute();
      state = state.copyWith(cryptos: cryptos, isLoading: false);
      _startStreaming();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load market data. Check your connection.',
      );
    }
  }

  void _startStreaming() {
    final symbols = state.cryptos
        .map((c) => '${c.symbol.toLowerCase()}usdt')
        .toList();

    final streamUseCase = ref.read(streamPricesUseCaseProvider);
    _priceSubscription?.cancel();
    _priceSubscription = streamUseCase.execute(symbols).listen((update) {
      final updatedCryptos = state.cryptos.map((c) {
        if ('${c.symbol}USDT' == update.symbol) {
          return c.copyWith(currentPrice: update.price);
        }
        return c;
      }).toList();
      state = state.copyWith(cryptos: updatedCryptos);
    });
  }

  void updateSearch(String text) {
    state = state.copyWith(searchText: text);
  }

  Future<void> refresh() async {
    _priceSubscription?.cancel();
    state = const MarketState(isLoading: true);
    await _loadMarket();
  }
}

final marketProvider =
    NotifierProvider<MarketNotifier, MarketState>(MarketNotifier.new);
