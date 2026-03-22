import '../../domain/models/crypto.dart';

class CryptoDTO {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double priceChangePercentage24h;
  final double marketCap;
  final double totalVolume;

  CryptoDTO({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.marketCap,
    required this.totalVolume,
  });

  factory CryptoDTO.fromJson(Map<String, dynamic> json) {
    return CryptoDTO(
      id: json['id'] as String,
      symbol: (json['symbol'] as String).toUpperCase(),
      name: json['name'] as String,
      image: json['image'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] as num? ?? 0).toDouble(),
      marketCap: (json['market_cap'] as num? ?? 0).toDouble(),
      totalVolume: (json['total_volume'] as num? ?? 0).toDouble(),
    );
  }

  Crypto toDomain() {
    return Crypto(
      id: id,
      symbol: symbol,
      name: name,
      imageUrl: image,
      currentPrice: currentPrice,
      priceChangePercentage24h: priceChangePercentage24h,
      marketCap: marketCap,
      volume24h: totalVolume,
    );
  }
}
