import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../detail/crypto_detail_screen.dart';
import '../favorites/favorites_provider.dart';
import 'market_provider.dart';
import 'market_row.dart';

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: NestedScrollView(
        headerSliverBuilder: (context2, _) => [
          SliverAppBar(
            backgroundColor: const Color(0xFF0D0D0D),
            floating: true,
            pinned: true,
            title: const Text(
              'Market',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Consumer(builder: (context2, ref, child) {
                final favCount = ref.watch(favoritesProvider).length;
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.star_rounded, color: Colors.amber),
                      onPressed: () {},
                    ),
                    if (favCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$favCount',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 9),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (text) =>
                      ref.read(marketProvider.notifier).updateSearch(text),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search coins...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon:
                        Icon(Icons.search, color: Colors.grey[600]),
                    filled: true,
                    fillColor: const Color(0xFF1C1C1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: _buildBody(context, ref, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, MarketState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(state.error!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(marketProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final cryptos = state.filteredCryptos;

    if (cryptos.isEmpty) {
      return const Center(
        child: Text('No coins found', style: TextStyle(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      color: Colors.blue,
      backgroundColor: const Color(0xFF1C1C1E),
      onRefresh: () => ref.read(marketProvider.notifier).refresh(),
      child: ListView.separated(
        itemCount: cryptos.length,
        separatorBuilder: (_, index) => Divider(
          color: Colors.grey[900],
          height: 1,
          indent: 72,
        ),
        itemBuilder: (_, index) {
          final crypto = cryptos[index];
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
