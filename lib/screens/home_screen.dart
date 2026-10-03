import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../widgets/feature_card.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  final List<Product> myProducts;
  final List<Order> myOrders;
  final VoidCallback onAddCraft;
  final Function(Product) onProductTap;

  const HomeScreen({
    super.key,
    required this.myProducts,
    required this.myOrders,
    required this.onAddCraft,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final artisan = MockData.currentArtisan;
    final publishedProducts =
        myProducts.where((p) => p.status == ProductStatus.published).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            backgroundColor: AppTheme.background,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🎨', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 10),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: Text(
                    'KalaSaathi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_outlined,
                        color: AppTheme.textPrimary),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB85C38), Color(0xFFC97040)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppTheme.cardRadius,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Namaste, ${artisan.name.split(' ').first} 👋',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Turn your craft into a digital business.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _StatChip(
                                    label: '${publishedProducts.length} Products',
                                    icon: '🎨',
                                  ),
                                  const SizedBox(width: 8),
                                  _StatChip(
                                    label: '${myOrders.length} Orders',
                                    icon: '📦',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              artisan.avatarEmoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Artisan-First AI Promise Banner
                  Container(
                    margin: const EdgeInsets.only(top: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.08),
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(color: AppTheme.secondary.withOpacity(0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🛡️', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Artisan-First AI Assistance',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.secondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'AI assists with studio enhancement, translation, and market pricing. You retain 100% control and final approval before publishing.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textPrimary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Feature section
                  Text(
                    '✨ AI-Powered Features',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap a feature to begin your digital journey',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Feature cards
                  FeatureCard(
                    emoji: '📸',
                    title: 'AI Image Enhancement',
                    subtitle: 'Make your product photo marketplace-ready.',
                    buttonLabel: 'Enhance Photo',
                    color: AppTheme.primary,
                    bgColor: const Color(0xFFFFF3E0),
                    onTap: () => Navigator.of(context)
                        .pushNamed('/image-enhancement'),
                  ),
                  const SizedBox(height: 12),
                  FeatureCard(
                    emoji: '🎤',
                    title: 'Multilingual Auto-Cataloguer',
                    subtitle:
                        'Speak naturally and create your product listing.',
                    buttonLabel: 'Create Catalogue',
                    color: AppTheme.secondary,
                    bgColor: const Color(0xFFE8F5E9),
                    onTap: () =>
                        Navigator.of(context).pushNamed('/voice-catalogue'),
                  ),
                  const SizedBox(height: 12),
                  FeatureCard(
                    emoji: '💰',
                    title: 'Dynamic Pricing Assistant',
                    subtitle:
                        'Understand your costs and get a suggested price range.',
                    buttonLabel: 'Get Price',
                    color: AppTheme.accent,
                    bgColor: const Color(0xFFFFF8E1),
                    onTap: () => Navigator.of(context).pushNamed('/pricing'),
                  ),

                  const SizedBox(height: 28),

                  // Quick action
                  GestureDetector(
                    onTap: onAddCraft,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.06),
                        borderRadius: AppTheme.cardRadius,
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.2),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add New Craft',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Photo → AI → Voice → Catalogue → Market',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // My Products section
                  if (publishedProducts.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Products',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 280,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: publishedProducts.take(3).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final product = publishedProducts[i];
                          return SizedBox(
                            width: 200,
                            child: ProductCard(
                              product: product,
                              onTap: () => onProductTap(product),
                              showWishlist: false,
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Recent Orders section
                  if (myOrders.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Orders',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...myOrders.take(2).map(
                          (order) => _OrderMiniCard(order: order),
                        ),
                  ],

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

class _StatChip extends StatelessWidget {
  final String label;
  final String icon;

  const _StatChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: AppTheme.chipRadius,
      ),
      child: Text(
        '$icon $label',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _OrderMiniCard extends StatelessWidget {
  final dynamic order;

  const _OrderMiniCard({required this.order});

  Color _statusColor() {
    switch (order.status.displayName) {
      case 'Delivered':
        return AppTheme.success;
      case 'Shipped':
        return AppTheme.info;
      case 'Confirmed':
        return AppTheme.secondary;
      default:
        return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Center(
              child: Text(
                order.productEmoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.productName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${order.orderId} • Qty: ${order.quantity}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${order.amount.toInt()}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(0.12),
                  borderRadius: AppTheme.chipRadius,
                ),
                child: Text(
                  '${order.status.emoji} ${order.status.displayName}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
