class BinanceTrade {
  final String symbol;
  final double price;

  BinanceTrade({required this.symbol, required this.price});

  factory BinanceTrade.fromJson(Map<String, dynamic> json) {
    // Binance combined stream: { "stream": "btcusdt@trade", "data": { "s": "BTCUSDT", "p": "43000.00" } }
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return BinanceTrade(
      symbol: (data['s'] as String).toUpperCase(),
      price: double.tryParse(data['p'] as String? ?? '0') ?? 0,
    );
  }
}
