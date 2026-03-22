import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/crypto.dart';
import '../../features/market/market_provider.dart';
import '../favorites/favorites_provider.dart';
import 'price_chart_view.dart';

final _priceHistoryProvider =
    FutureProvider.family<List<double>, String>((ref, coinId) async {
  final repo = ref.watch(cryptoRepositoryProvider);
  return repo.getPriceHistory(coinId);
});

class CryptoDetailScreen extends ConsumerWidget {
  final Crypto crypto;

  const CryptoDetailScreen({super.key, required this.crypto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch live price from market state
    final marketState = ref.watch(marketProvider);
    final liveCrypto = marketState.cryptos.firstWhere(
      (c) => c.id == crypto.id,
      orElse: () => crypto,
    );

    final isFavorite = ref.watch(favoritesProvider).contains(crypto.id);
    final isPositive = liveCrypto.priceChangePercentage24h >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final priceHistory = ref.watch(_priceHistoryProvider(crypto.id));

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        title: Text(
          liveCrypto.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isFavorite ? Colors.amber : Colors.grey,
            ),
            onPressed: () =>
                ref.read(favoritesProvider.notifier).toggle(crypto.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: liveCrypto.imageUrl,
                    width: 64,
                    height: 64,
                    errorWidget: (context2, url, error) => const CircleAvatar(
                      radius: 32,
                      child: Icon(Icons.currency_bitcoin, size: 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        liveCrypto.symbol,
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      _LivePriceText(price: liveCrypto.currentPrice),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isPositive
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: changeColor,
                            size: 14,
                          ),
                          Text(
                            '${isPositive ? '+' : ''}${liveCrypto.priceChangePercentage24h.toStringAsFixed(2)}%  24h',
                            style: TextStyle(color: changeColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Chart
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: priceHistory.when(
                  loading: () => const Center(
                    child:
                        CircularProgressIndicator(color: Colors.blue),
                  ),
                  error: (e, _) => Center(
                    child: Text('Chart unavailable',
                        style: TextStyle(color: Colors.grey[600])),
                  ),
                  data: (prices) => PriceChartView(
                    prices: prices,
                    isPositive: isPositive,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Stats
              const Text(
                'Statistics',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _StatsCard(crypto: liveCrypto),

              const SizedBox(height: 24),

              // Trade Panel
              _TradePanel(crypto: liveCrypto),
            ],
          ),
        ),
      ),
    );
  }
}

class _LivePriceText extends StatefulWidget {
  final double price;
  const _LivePriceText({required this.price});

  @override
  State<_LivePriceText> createState() => _LivePriceTextState();
}

class _LivePriceTextState extends State<_LivePriceText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnim;
  double _prev = 0;

  @override
  void initState() {
    super.initState();
    _prev = widget.price;
    _controller =
        AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _colorAnim =
        ColorTween(begin: Colors.white, end: Colors.white).animate(_controller);
  }

  @override
  void didUpdateWidget(_LivePriceText old) {
    super.didUpdateWidget(old);
    if (widget.price != _prev) {
      final up = widget.price > _prev;
      _colorAnim = ColorTween(
        begin: up ? Colors.green : Colors.red,
        end: Colors.white,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
      _prev = widget.price;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _fmt(double p) {
    if (p >= 1000) {
      return '\$${p.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
    } else if (p >= 1) {
      return '\$${p.toStringAsFixed(4)}';
    }
    return '\$${p.toStringAsFixed(6)}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnim,
      builder: (context2, child) => Text(
        _fmt(widget.price),
        style: TextStyle(
          color: _colorAnim.value,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final Crypto crypto;
  const _StatsCard({required this.crypto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _StatRow(
              label: 'Market Cap',
              value: _formatLargeNumber(crypto.marketCap)),
          const Divider(color: Color(0xFF2C2C2E), height: 24),
          _StatRow(
              label: '24h Volume',
              value: _formatLargeNumber(crypto.volume24h)),
          const Divider(color: Color(0xFF2C2C2E), height: 24),
          _StatRow(
              label: '24h Change',
              value:
                  '${crypto.priceChangePercentage24h >= 0 ? '+' : ''}${crypto.priceChangePercentage24h.toStringAsFixed(2)}%',
              valueColor: crypto.priceChangePercentage24h >= 0
                  ? Colors.green
                  : Colors.red),
        ],
      ),
    );
  }

  String _formatLargeNumber(double n) {
    if (n >= 1e12) return '\$${(n / 1e12).toStringAsFixed(2)}T';
    if (n >= 1e9) return '\$${(n / 1e9).toStringAsFixed(2)}B';
    if (n >= 1e6) return '\$${(n / 1e6).toStringAsFixed(2)}M';
    return '\$${n.toStringAsFixed(0)}';
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        Text(value,
            style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _TradePanel extends StatefulWidget {
  final Crypto crypto;
  const _TradePanel({required this.crypto});

  @override
  State<_TradePanel> createState() => _TradePanelState();
}

class _TradePanelState extends State<_TradePanel> {
  bool _isBuy = true;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trade',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TradeButton(
                  label: 'Buy',
                  isActive: _isBuy,
                  color: Colors.green,
                  onTap: () => setState(() => _isBuy = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TradeButton(
                  label: 'Sell',
                  isActive: !_isBuy,
                  color: Colors.red,
                  onTap: () => setState(() => _isBuy = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Amount (${widget.crypto.symbol})',
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: const Color(0xFF2C2C2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${_isBuy ? "Buy" : "Sell"} order placed for ${_controller.text} ${widget.crypto.symbol}',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isBuy ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                _isBuy ? 'Place Buy Order' : 'Place Sell Order',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TradeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _TradeButton({
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.2) : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? color : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
