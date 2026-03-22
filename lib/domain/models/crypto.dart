class Crypto {
  final String id;
  final String symbol;
  final String name;
  final String imageUrl;
  double currentPrice;
  final double priceChangePercentage24h;
  final double marketCap;
  final double volume24h;

  Crypto({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.marketCap,
    required this.volume24h,
  });

  Crypto copyWith({double? currentPrice}) {
    return Crypto(
      id: id,
      symbol: symbol,
      name: name,
      imageUrl: imageUrl,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChangePercentage24h: priceChangePercentage24h,
      marketCap: marketCap,
      volume24h: volume24h,
    );
  }
}
