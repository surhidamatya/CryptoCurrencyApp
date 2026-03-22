import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../detail/crypto_detail_screen.dart';
import '../market/market_provider.dart';
import '../market/market_row.dart';
import 'favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);
    final allCryptos = ref.watch(marketProvider).cryptos;
    final favorites =
        allCryptos.where((c) => favoriteIds.contains(c.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        title: const Text(
          'Watchlist',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_outline_rounded,
                      size: 56, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No favourites yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Open a coin and tap the star to add it here.',
                    style: TextStyle(color: Color(0xFF555555), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: favorites.length,
              separatorBuilder: (_, __) => Divider(
                color: Colors.grey[900],
                height: 1,
                indent: 72,
              ),
              itemBuilder: (_, index) {
                final crypto = favorites[index];
                return MarketRow(
                  crypto: crypto,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CryptoDetailScreen(crypto: crypto),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
