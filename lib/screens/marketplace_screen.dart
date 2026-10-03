import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class MarketplaceScreen extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onProductTap;

  const MarketplaceScreen({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, String>> _categories = [
    {'emoji': '🌟', 'label': 'All'},
    {'emoji': '🧺', 'label': 'Handicrafts'},
    {'emoji': '🧵', 'label': 'Textiles'},
    {'emoji': '🏺', 'label': 'Pottery'},
    {'emoji': '👜', 'label': 'Leather'},
    {'emoji': '🪵', 'label': 'Woodcraft'},
    {'emoji': '🌿', 'label': 'Organic Products'},
    {'emoji': '🏮', 'label': 'Home Decor'},
  ];

  List<Product> get _filteredProducts {
    return widget.products.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.artisanName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.tags.any((t) =>
              t.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesCategory = _selectedCategory == null ||
          _selectedCategory == 'All' ||
          p.category.displayName == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // App bar with search
          SliverAppBar(
            backgroundColor: AppTheme.background,
            floating: true,
            pinned: false,
            elevation: 0,
            expandedHeight: 0,
            title: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🎨', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Marketplace',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            automaticallyImplyLeading: false,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search crafts, products or artisans...',
                      prefixIcon: const Icon(Icons.search,
                          color: AppTheme.textTertiary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: AppTheme.textTertiary),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme.cardBg,
                      border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: AppTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: AppTheme.border),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(14)),
                        borderSide:
                            BorderSide(color: AppTheme.primary, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Category chips
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final cat = _categories[i];
                        final isSelected =
                            (_selectedCategory == null && cat['label'] == 'All') ||
                                _selectedCategory == cat['label'];
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedCategory =
                                cat['label'] == 'All' ? null : cat['label'];
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.cardBg,
                              borderRadius: AppTheme.chipRadius,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.border,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primary
                                            .withOpacity(0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              '${cat['emoji']} ${cat['label']}',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Count bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filtered.length} Products Found',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Live Market',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.success),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: filtered.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          children: [
                            const Text('🔍',
                                style: TextStyle(fontSize: 56)),
                            const SizedBox(height: 16),
                            Text('No products found',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search or category',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final product = filtered[i];
                        return ProductCard(
                          product: product,
                          onTap: () => widget.onProductTap(product),
                        );
                      },
                      childCount: filtered.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
