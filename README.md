# Crypto Tracker — Flutter

A real-time cryptocurrency market tracker built with Flutter and Riverpod. Prices update live via a Binance WebSocket stream, while market data and price charts are fetched from the CoinGecko REST API.

---

## Features

- Live price feed with green/red flash animations on price change
- Market list of top 50 coins by market cap
- 7-day price history chart per coin
- Star/watchlist to track favourite coins
- Search/filter across the market list
- Buy/sell trade panel (simulated)

---

## Architecture

The project follows Clean Architecture with three explicit layers.

```
lib/
├── core/
│   ├── networking/        # Dio HTTP client
│   └── websocket/         # Binance WebSocket manager
├── data/
│   ├── api/               # CoinGecko API calls
│   ├── dto/               # JSON deserialization
│   └── repositories/      # Repository implementations
├── domain/
│   ├── models/            # Pure Dart entities
│   ├── repositories/      # Abstract repository interfaces
│   └── usecases/          # Single-responsibility use cases
└── features/
    ├── market/            # Market list screen + state
    ├── detail/            # Coin detail screen + chart
    └── favorites/         # Watchlist screen + state
```

State management is handled entirely by **Riverpod v2** (`NotifierProvider`, `FutureProvider.family`).

---

## Application Flow & Navigation

The app uses Flutter's built-in `Navigator` (imperative, `Navigator.push` / `Navigator.pop`) — there is no named-route or go_router setup. All navigation is triggered directly from widget callbacks.

### Startup

```
main()
  └─► ProviderScope          // initialises all Riverpod providers
        └─► CryptoTrackerApp // MaterialApp, dark theme
              └─► MarketScreen (home)
                    └─► MarketNotifier.build()
                          ├─► FetchMarketUseCase  → CoinGecko REST  (loads coin list)
                          └─► StreamPricesUseCase → Binance WS      (starts live feed)
```

There is no dedicated splash screen in the codebase. The app lands directly on `MarketScreen`, which shows a `CircularProgressIndicator` while the initial market data loads and transitions to the coin list once data arrives.

### Screen map

```
MarketScreen  (home — always on the stack)
│
├─► [tap any coin row]
│     Navigator.push → CryptoDetailScreen
│       └─► [tap back / system back]
│             Navigator.pop → MarketScreen
│
└─► [tap star icon in app bar]
      Navigator.push → FavoritesScreen
        └─► [tap any coin row]
        │     Navigator.push → CryptoDetailScreen
        │       └─► [tap back] → FavoritesScreen
        └─► [tap back] → MarketScreen
```

### Screen descriptions

| Screen | File | How you get there | How you leave |
|---|---|---|---|
| `MarketScreen` | `features/market/market_screen.dart` | App entry point | — |
| `CryptoDetailScreen` | `features/detail/crypto_detail_screen.dart` | Tap a coin row on Market or Watchlist | Back button / gesture |
| `FavoritesScreen` | `features/favorites/favorites_screen.dart` | Tap the star icon in the Market app bar | Back button / gesture |

### MarketScreen — states

The market screen body has three distinct states driven by `MarketState`:

```
isLoading == true   →  CircularProgressIndicator
error != null       →  error message + Retry button
                         └─► Retry calls MarketNotifier.refresh()
cryptos loaded      →  scrollable ListView of MarketRow widgets
                         └─► pull-to-refresh also calls refresh()
```

Search is handled inline: the text field at the bottom of the app bar calls `MarketNotifier.updateSearch(text)`, which filters `MarketState.filteredCryptos` and rebuilds the list without any navigation.

### CryptoDetailScreen — data loading

On push, the screen immediately reads the matching `Crypto` from the already-loaded `marketProvider` state (no extra REST call for the coin itself). It then fires a separate `_priceHistoryProvider(coinId)` `FutureProvider` to fetch the 7-day chart data from CoinGecko, which shows a spinner inside the chart container until resolved.

Live prices continue to update on this screen because it watches `marketProvider` — the same WebSocket-driven state as the market list.

---

## REST API — CoinGecko

All HTTP traffic goes through a shared `ApiClient` (`lib/core/networking/api_client.dart`) built on **Dio**.

```
Base URL : https://api.coingecko.com/api/v3
Timeouts : 10 s connect / 10 s receive
```

### Endpoints

| Purpose | Method | Path |
|---|---|---|
| Top 50 coins by market cap | GET | `/coins/markets` |
| 7-day price history for a coin | GET | `/coins/{id}/market_chart` |

### `/coins/markets` parameters

```
vs_currency             = usd
order                   = market_cap_desc
per_page                = 50
page                    = 1
price_change_percentage = 24h
```

### `/coins/{id}/market_chart` parameters

```
vs_currency = usd
days        = 7
```

### Call flow

```
UI (refresh / initial load)
  └─► MarketNotifier.refresh()
        └─► FetchMarketUseCase.execute()
              └─► CryptoRepositoryImpl.getMarket()
                    └─► CryptoApi.getMarket()          ← Dio GET
                          └─► CryptoDTO.fromJson()     ← JSON → DTO
                    └─► maps DTO → Crypto domain model
              └─► MarketState.cryptos updated
  └─► UI rebuilds via ref.watch(marketProvider)
```

Price history for the chart follows the same pattern through `_priceHistoryProvider` (a `FutureProvider.family` keyed on coin ID).

---

## WebSocket — Binance Live Prices

Real-time price updates come from the **Binance combined stream** API, managed in `lib/core/websocket/websocket_manager.dart` using the **`web_socket_channel`** package.

### Connection

After the initial market data loads, `MarketNotifier._startStreaming()` builds a symbol list from the loaded coins (e.g. `btcusdt`, `ethusdt`, `solusdt`) and opens a single WebSocket connection:

```
wss://stream.binance.com:9443/stream?streams=btcusdt@trade/ethusdt@trade/...
```

Each symbol subscribes to its `@trade` stream, which fires on every executed trade.

### Message format

Binance wraps each event in a combined-stream envelope:

```json
{
  "stream": "btcusdt@trade",
  "data": {
    "s": "BTCUSDT",
    "p": "43215.87"
  }
}
```

`BinanceTrade.fromJson()` (`lib/data/dto/binance_trade.dart`) parses this into a `CryptoPriceUpdate` domain model containing the normalised symbol and latest price.

### Live update flow

```
WebSocketManager (connected to Binance)
  └─► StreamController broadcasts raw JSON strings
        └─► StreamPricesUseCase maps each message
              └─► BinanceTrade.fromJson()
                    └─► CryptoPriceUpdate(symbol, price)
        └─► MarketNotifier listens on subscription
              └─► finds matching Crypto by symbol
                    └─► updates Crypto.currentPrice in state
  └─► UI rebuilds — MarketRow & CryptoDetailScreen re-render
        └─► _AnimatedPrice / _LivePriceText flashes green (up) or red (down)
              └─► ColorTween animation, 600–700 ms, easeOut curve
```

The WebSocket subscription is cancelled when `MarketNotifier` is disposed (screen removed from the widget tree).

---

## Dependency Injection

Riverpod providers wire up the full dependency graph at startup:

```dart
apiClientProvider           // Dio instance
webSocketManagerProvider    // WebSocketManager
cryptoApiProvider           // CryptoApi(apiClient)
cryptoRepositoryProvider    // CryptoRepositoryImpl(api)
fetchMarketUseCaseProvider  // FetchMarketUseCase(repo)
streamPricesUseCaseProvider // StreamPricesUseCase(wsManager)

marketProvider              // NotifierProvider — drives market screen
favoritesProvider           // NotifierProvider — drives watchlist
_priceHistoryProvider       // FutureProvider.family — drives charts
```

`ProviderScope` at the root of `main.dart` scopes all providers to the app lifetime.

---

## Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.5.1 | State management |
| `dio` | ^5.4.3+1 | HTTP client |
| `web_socket_channel` | ^3.0.1 | WebSocket client |
| `fl_chart` | ^0.68.0 | Price history line chart |
| `cached_network_image` | ^3.3.1 | Coin logo caching |
| `shimmer` | ^3.0.0 | Loading skeleton |
| `google_fonts` | ^6.2.1 | Typography |

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on a connected device or simulator
flutter run
```

No API keys are required — CoinGecko's public tier and Binance's public WebSocket streams are used without authentication.
