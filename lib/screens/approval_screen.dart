import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';

class ApprovalScreen extends StatefulWidget {
  final Function(Product) onPublish;

  const ApprovalScreen({super.key, required this.onPublish});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  Map<String, dynamic>? _args;
  bool _editMode = false;
  bool _storyVerified = false;
  bool _priceVerified = false;
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_args == null) {
      _args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (_args != null) {
        _nameController.text = (_args!['productName'] as String?) ?? '';
        _descController.text = (_args!['description'] as String?) ?? '';
        _priceController.text =
            (_args!['recommendedPrice'] as double?)?.toInt().toString() ?? '800';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _publish() {
    if (!_storyVerified || !_priceVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please check both artisan verification boxes below to approve your listing.'),
          backgroundColor: AppTheme.primary,
        ),
      );
      return;
    }

    final minPrice = (_args!['minPrice'] as double?) ?? 750;
    final maxPrice = (_args!['maxPrice'] as double?) ?? 850;
    final recommended =
        double.tryParse(_priceController.text) ?? (_args!['recommendedPrice'] as double? ?? 800);
    final category = (_args!['category'] as ProductCategory?) ??
        ProductCategory.handicrafts;
    final tags = (_args!['tags'] as List?)?.cast<String>() ??
        ['Handmade', 'Traditional'];
    final material =
        (_args!['material'] as String?) ?? 'Natural Materials';
    final craftKey = (_args?['craftKey'] as String?) ?? 'basket';
    final craftEmoji = (_args?['craftEmoji'] as String?) ?? '🧺';

    final product = Product(
      id: Product.generateId(),
      name: _nameController.text.isNotEmpty ? _nameController.text : 'Handmade Artisan Craft',
      artisanId: 'artisan_001',
      artisanName: 'Lakshmi Devi',
      artisanLocation: 'Warangal, Telangana',
      description: _descController.text,
      material: material,
      category: category,
      price: recommended,
      minPrice: minPrice,
      maxPrice: maxPrice,
      tags: tags,
      rating: 5.0,
      reviewCount: 1,
      stock: 10,
      status: ProductStatus.published,
      imagePath: craftKey,
      imageEmoji: craftEmoji,
      isNew: true,
      isAIEnhanced: true,
      createdAt: DateTime.now(),
    );

    widget.onPublish(product);
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/success',
      (route) => route.isFirst,
      arguments: {'product': product},
    );
  }

  @override
  Widget build(BuildContext context) {
    final productName = _nameController.text.isNotEmpty
        ? _nameController.text
        : 'Traditional Handwoven Bamboo Basket';
    final description = _descController.text.isNotEmpty
        ? _descController.text
        : 'AI-generated product description';
    final minPrice = (_args?['minPrice'] as double?) ?? 750;
    final maxPrice = (_args?['maxPrice'] as double?) ?? 850;
    final tags = (_args?['tags'] as List?)?.cast<String>() ??
        ['Handmade', 'Traditional'];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Review Your Listing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _editMode = !_editMode),
            child: Text(_editMode ? 'Done' : '✏️ Edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMPORTANT: artisan control notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.08),
                borderRadius: AppTheme.cardRadius,
                border: Border.all(color: AppTheme.info.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppTheme.info, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You are in control. Review all details before publishing. You can edit anything.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.info,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Product image
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(
                          color: AppTheme.primary.withOpacity(0.3),
                          width: 2),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Center(
                      child: Text(
                        (_args?['craftEmoji'] as String?) ?? '🧺',
                        style: const TextStyle(fontSize: 90),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 8, right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: AppTheme.chipRadius,
                    ),
                    child: const Text(
                      '✓ Enhanced',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Listing details
            _buildSection(
              context,
              title: 'Product Name',
              child: _editMode
                  ? TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(),
                    )
                  : _valueText(context, productName, large: true),
            ),

            _buildSection(
              context,
              title: 'Description',
              child: _editMode
                  ? TextField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: const InputDecoration(),
                    )
                  : _valueText(context, description),
            ),

            _buildSection(
              context,
              title: 'Languages Available',
              child: Row(
                children: ['🇬🇧 English', '🇮🇳 Hindi', '🇮🇳 Telugu'].map((lang) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.1),
                      borderRadius: AppTheme.chipRadius,
                      border: Border.all(
                          color: AppTheme.secondary.withOpacity(0.3)),
                    ),
                    child: Text(
                      lang,
                      style: const TextStyle(
                        color: AppTheme.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            _buildSection(
              context,
              title: 'Suggested Price Range',
              child: Row(
                children: [
                  Text(
                    '₹${minPrice.toInt()} – ₹${maxPrice.toInt()}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: AppTheme.chipRadius,
                    ),
                    child: Text(
                      '⭐ Recommended: ₹${((_args?['recommendedPrice'] as double?) ?? 800).toInt()}',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildSection(
              context,
              title: 'Your Final Price',
              child: _editMode
                  ? TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(prefixText: '₹'),
                    )
                  : _valueText(
                      context,
                      '₹${_priceController.text}',
                      large: true,
                      color: AppTheme.primary,
                    ),
            ),

            _buildSection(
              context,
              title: 'Tags',
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: AppTheme.chipRadius,
                      border: Border.all(
                          color: AppTheme.primary.withOpacity(0.2)),
                    ),
                    child: Text(
                      '# $tag',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Mandatory Artisan Verification Checkbox Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (_storyVerified && _priceVerified)
                    ? AppTheme.secondary.withOpacity(0.08)
                    : AppTheme.primary.withOpacity(0.06),
                borderRadius: AppTheme.cardRadius,
                border: Border.all(
                  color: (_storyVerified && _priceVerified)
                      ? AppTheme.secondary
                      : AppTheme.primary,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🛡️', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        'Mandatory Artisan Consent (Human-in-the-Loop)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: (_storyVerified && _priceVerified)
                              ? AppTheme.secondary
                              : AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'AI generated these suggestions. As the artisan, you must explicitly approve before going live:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => setState(() => _storyVerified = !_storyVerified),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _storyVerified,
                            activeColor: AppTheme.secondary,
                            onChanged: (v) => setState(() => _storyVerified = v ?? false),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'I verify the photos, cultural story, and materials authentically represent my handmade craft.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: _storyVerified ? FontWeight.w600 : FontWeight.w400,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _priceVerified = !_priceVerified),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _priceVerified,
                            activeColor: AppTheme.secondary,
                            onChanged: (v) => setState(() => _priceVerified = v ?? false),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'I approve the final listing price of ₹${_priceController.text} with 100% direct artisan earnings.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: _priceVerified ? FontWeight.w600 : FontWeight.w400,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Publish button
            ElevatedButton.icon(
              onPressed: _publish,
              icon: Icon(
                (_storyVerified && _priceVerified) ? Icons.check_circle : Icons.verified_user_outlined,
                size: 22,
              ),
              label: Text(
                (_storyVerified && _priceVerified)
                    ? '✓ Publish to Marketplace (Artisan Approved)'
                    : 'Check Boxes Above to Approve',
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: (_storyVerified && _priceVerified)
                    ? AppTheme.primary
                    : AppTheme.textTertiary,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Go Back & Edit'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _valueText(
    BuildContext context,
    String text, {
    bool large = false,
    Color? color,
  }) {
    return Text(
      text,
      style: large
          ? Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color ?? AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            )
          : Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color ?? AppTheme.textPrimary,
              height: 1.5,
            ),
    );
  }
}
