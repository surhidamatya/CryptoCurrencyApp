import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../domain/models/crypto.dart';

class MarketRow extends StatelessWidget {
  final Crypto crypto;
  final VoidCallback onTap;

  const MarketRow({super.key, required this.crypto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPositive = crypto.priceChangePercentage24h >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changePrefix = isPositive ? '+' : '';

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CachedNetworkImage(
        imageUrl: crypto.imageUrl,
        width: 42,
        height: 42,
        placeholder: (context2, url) => Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[600]!,
          child: const CircleAvatar(radius: 21),
        ),
        errorWidget: (context2, url, error) => const CircleAvatar(
          radius: 21,
          child: Icon(Icons.currency_bitcoin, size: 20),
        ),
      ),
      title: Text(
        crypto.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        crypto.symbol,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 13,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _AnimatedPrice(price: crypto.currentPrice),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: changeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$changePrefix${crypto.priceChangePercentage24h.toStringAsFixed(2)}%',
              style: TextStyle(
                color: changeColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedPrice extends StatefulWidget {
  final double price;

  const _AnimatedPrice({required this.price});

  @override
  State<_AnimatedPrice> createState() => _AnimatedPriceState();
}

class _AnimatedPriceState extends State<_AnimatedPrice>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  double _previousPrice = 0;

  @override
  void initState() {
    super.initState();
    _previousPrice = widget.price;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.white,
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(_AnimatedPrice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.price != _previousPrice) {
      final isUp = widget.price > _previousPrice;
      _colorAnimation = ColorTween(
        begin: isUp ? Colors.green : Colors.red,
        end: Colors.white,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
      _previousPrice = widget.price;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '\$${price.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          )}';
    } else if (price >= 1) {
      return '\$${price.toStringAsFixed(4)}';
    } else {
      return '\$${price.toStringAsFixed(6)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context2, child) => Text(
        _formatPrice(widget.price),
        style: TextStyle(
          color: _colorAnimation.value,
          fontWeight: FontWeight.bold,
          fontSize: 15,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
