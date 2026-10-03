import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../services/mock_pricing_service.dart';
import '../models/product.dart';
import '../widgets/pricing_card.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final _materialController = TextEditingController(text: '250');
  final _hoursController = TextEditingController(text: '4');
  final _wageController = TextEditingController(text: '100');
  final _packagingController = TextEditingController(text: '30');

  Map<String, dynamic>? _pricing;
  Map<String, dynamic>? _catalogue;
  String? _productName;
  String _craftKey = 'basket';
  String _craftEmoji = '🧺';
  bool _initializedArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedArgs) {
      _initializedArgs = true;
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _catalogue = args['catalogue'] as Map<String, dynamic>?;
        _productName = args['productName'] as String?;
        _craftKey = (args['craftKey'] as String?) ?? 'basket';
        _craftEmoji = (args['craftEmoji'] as String?) ?? '🧺';

        final sample = MockData.sampleCrafts.firstWhere(
          (c) => c['key'] == _craftKey,
          orElse: () => MockData.sampleCrafts.first,
        );

        _materialController.text = (sample['materialCost'] as double).toInt().toString();
        _hoursController.text = (sample['workHours'] as double).toString();
        _wageController.text = (sample['hourlyWage'] as double).toInt().toString();
        _packagingController.text = (sample['packagingCost'] as double).toInt().toString();
      }
      _calculate();
    }
  }

  @override
  void dispose() {
    _materialController.dispose();
    _hoursController.dispose();
    _wageController.dispose();
    _packagingController.dispose();
    super.dispose();
  }

  void _calculate() {
    final material = double.tryParse(_materialController.text) ?? 0;
    final hours = double.tryParse(_hoursController.text) ?? 0;
    final wage = double.tryParse(_wageController.text) ?? 0;
    final packaging = double.tryParse(_packagingController.text) ?? 0;

    final costFloor = MockPricingService.calculateCostFloor(
      materialCost: material,
      workHours: hours,
      hourlyWage: wage,
      packagingCost: packaging,
    );

    final pricing = MockPricingService.getSuggestedPricing(
      costFloor: costFloor,
    );

    setState(() => _pricing = pricing);
  }

  void _approvePrice() {
    if (_pricing == null) return;

    final category = (_catalogue?['category'] as ProductCategory?) ??
        ProductCategory.handicrafts;
    final tags = (_catalogue?['tags'] as List?)?.cast<String>() ??
        ['Handmade', 'Traditional'];

    Navigator.of(context).pushNamed(
      '/approval',
      arguments: {
        'productName': _productName ?? 'Traditional Handwoven Bamboo Basket',
        'description': _catalogue?['description'] ?? '',
        'category': category,
        'material': (_catalogue?['material'] as String?) ?? 'Natural Materials',
        'tags': tags,
        'minPrice': _pricing!['minSuggested'] as double,
        'maxPrice': _pricing!['maxSuggested'] as double,
        'recommendedPrice': _pricing!['recommended'] as double,
        'craftKey': _craftKey,
        'craftEmoji': _craftEmoji,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final material = double.tryParse(_materialController.text) ?? 0;
    final hours = double.tryParse(_hoursController.text) ?? 0;
    final wage = double.tryParse(_wageController.text) ?? 0;
    final labour = hours * wage;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('KalaSaathi Smart Pricing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4A017), Color(0xFFE8B84B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppTheme.cardRadius,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '💰 Dynamic Pricing Assistant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Understand your costs before setting your price.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text('📊', style: TextStyle(fontSize: 36)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (_productName != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: AppTheme.cardRadius,
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Text(_craftEmoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _productName!,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Text('Enter Your Production Costs',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Enter the actual costs to calculate a fair price.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Input fields
            _buildInputField(
              context,
              label: 'Material Cost',
              controller: _materialController,
              prefix: '₹',
              hint: 'e.g. 250',
              icon: '🪵',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    context,
                    label: 'Work Hours',
                    controller: _hoursController,
                    prefix: '',
                    suffix: 'hrs',
                    hint: 'e.g. 4',
                    icon: '⏱️',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    context,
                    label: 'Hourly Wage',
                    controller: _wageController,
                    prefix: '₹',
                    suffix: '/hr',
                    hint: 'e.g. 100',
                    icon: '👷',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInputField(
              context,
              label: 'Packaging Cost',
              controller: _packagingController,
              prefix: '₹',
              hint: 'e.g. 30',
              icon: '📦',
            ),

            const SizedBox(height: 12),

            // Live cost preview
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: AppTheme.cardRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _costRow(context, 'Material',
                      '₹${material.toInt()}'),
                  _costRow(context, 'Labour (${hours.toInt()} × ₹${wage.toInt()})',
                      '₹${labour.toInt()}'),
                  _costRow(context, 'Packaging',
                      '₹${(double.tryParse(_packagingController.text) ?? 0).toInt()}'),
                  Divider(color: AppTheme.divider, thickness: 1),
                  _costRow(
                    context,
                    'Cost Floor',
                    '₹${(material + labour + (double.tryParse(_packagingController.text) ?? 0)).toInt()}',
                    isBold: true,
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate Suggested Price'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
              ),
            ),

            // Results
            if (_pricing != null) ...[
              const SizedBox(height: 28),
              Text('Market Comparison',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Sample comparable products in the market:',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Row(
                children: (_pricing!['comparablePrices'] as List<double>)
                    .map(
                      (price) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceVariant,
                            borderRadius: const BorderRadius.all(
                                Radius.circular(12)),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Column(
                            children: [
                              const Text('📦',
                                  style: TextStyle(fontSize: 18)),
                              const SizedBox(height: 4),
                              Text(
                                '₹${price.toInt()}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: AppTheme.cardRadius,
                  border: Border.all(
                      color: AppTheme.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Text('📊', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Text(
                      'Average Market Price: ₹${(_pricing!['avgMarketPrice'] as double).toInt()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text('Suggested Selling Range',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: PricingCard(
                      label: 'Min Price',
                      value:
                          '₹${(_pricing!['minSuggested'] as double).toInt()}',
                      color: AppTheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PricingCard(
                      label: 'Max Price',
                      value:
                          '₹${(_pricing!['maxSuggested'] as double).toInt()}',
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PricingCard(
                label: '⭐ Recommended Price',
                value: '₹${(_pricing!['recommended'] as double).toInt()}',
                color: AppTheme.accent,
                isHighlighted: true,
              ),

              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.08),
                  borderRadius: AppTheme.cardRadius,
                  border: Border.all(
                      color: AppTheme.info.withOpacity(0.2)),
                ),
                child: Text(
                  'ℹ️ The suggested range considers your declared production cost and sample comparable listings. The artisan retains full control over the final price.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.info,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _approvePrice,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Approve Price & Review Listing'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    String prefix = '',
    String suffix = '',
    required String hint,
    required String icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$icon  $label',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixText: prefix.isNotEmpty ? prefix : null,
            suffixText: suffix.isNotEmpty ? suffix : null,
            hintText: hint,
          ),
        ),
      ],
    );
  }

  Widget _costRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: color ?? AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
