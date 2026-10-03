import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _wishlisted = false;
  bool _enquirySent = false;

  static const List<Color> _productColors = [
    Color(0xFFFFF3E0),
    Color(0xFFE8F5E9),
    Color(0xFFFCE4EC),
    Color(0xFFE3F2FD),
    Color(0xFFF3E5F5),
    Color(0xFFE0F2F1),
    Color(0xFFFFF8E1),
    Color(0xFFEDE7F6),
  ];

  Color _getProductColor(Product p) {
    final idx = p.id.hashCode.abs() % _productColors.length;
    return _productColors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final product =
        ModalRoute.of(context)?.settings.arguments as Product?;
    if (product == null) {
      return const Scaffold(body: Center(child: Text('Product not found')));
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Image header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: _getProductColor(product),
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.softShadow,
                ),
                child: const Icon(Icons.arrow_back_ios,
                    color: AppTheme.textPrimary, size: 18),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () =>
                    setState(() => _wishlisted = !_wishlisted),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Icon(
                    _wishlisted ? Icons.favorite : Icons.favorite_border,
                    color: _wishlisted ? AppTheme.error : AppTheme.textTertiary,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: _getProductColor(product),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        product.imageEmoji,
                        style: const TextStyle(fontSize: 120),
                      ),
                    ),
                    if (product.isAIEnhanced)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: AppTheme.chipRadius,
                          ),
                          child: const Text(
                            '✨ AI Enhanced Photo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (product.isNew)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary,
                            borderRadius: AppTheme.chipRadius,
                          ),
                          child: const Text(
                            '🆕 Just Added',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip + rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: AppTheme.chipRadius,
                        ),
                        child: Text(
                          '${product.category.emoji} ${product.category.displayName}',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: AppTheme.accent, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            product.rating > 0
                                ? '${product.rating.toStringAsFixed(1)} (${product.reviewCount})'
                                : 'New Listing',
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 6),

                  Text(
                    '₹${product.price.toInt()}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '₹${product.minPrice.toInt()} – ₹${product.maxPrice.toInt()} range',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: 16),
                  Divider(color: AppTheme.divider),
                  const SizedBox(height: 16),

                  // Artisan info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: AppTheme.cardRadius,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('👩‍🎨',
                                style: TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.artisanName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 12,
                                      color: AppTheme.textTertiary),
                                  const SizedBox(width: 2),
                                  Text(
                                    product.artisanLocation,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.1),
                            borderRadius: AppTheme.chipRadius,
                          ),
                          child: Text(
                            '✓ Verified',
                            style: TextStyle(
                              color: AppTheme.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  Text('Description',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Details grid
                  Row(
                    children: [
                      _DetailChip(
                          label: 'Material', value: product.material),
                      const SizedBox(width: 12),
                      _DetailChip(
                        label: 'Availability',
                        value: '${product.stock} in Stock',
                        color: AppTheme.success,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Tags
                  Text('Tags', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: product.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: AppTheme.chipRadius,
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(
                          '# $tag',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '🛍️ Order placed for ${product.name}!'),
                          backgroundColor: AppTheme.secondary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Buy Now'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (!_enquirySent) {
                              setState(() => _enquirySent = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      '✅ Enquiry sent to artisan!'),
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            _enquirySent
                                ? Icons.check
                                : Icons.message_outlined,
                            size: 18,
                          ),
                          label: Text(
                            _enquirySent ? 'Enquiry Sent!' : 'Send Enquiry',
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 52),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              setState(() => _wishlisted = !_wishlisted),
                          icon: Icon(
                            _wishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _wishlisted
                                ? AppTheme.error
                                : AppTheme.primary,
                            size: 18,
                          ),
                          label: Text(
                            _wishlisted ? 'Wishlisted ♥' : 'Wishlist',
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            foregroundColor: _wishlisted
                                ? AppTheme.error
                                : AppTheme.primary,
                            side: BorderSide(
                              color: _wishlisted
                                  ? AppTheme.error
                                  : AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _DetailChip({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (color ?? AppTheme.primary).withOpacity(0.06),
          borderRadius: AppTheme.cardRadius,
          border: Border.all(
            color: (color ?? AppTheme.primary).withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                )),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color ?? AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
