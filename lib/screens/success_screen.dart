import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late Animation<double> _bounce;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bounce = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    Future.delayed(const Duration(milliseconds: 200), () {
      _bounceController.forward();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final product = args?['product'] as Product?;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Success icon
                ScaleTransition(
                  scale: _bounce,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: AppTheme.greenGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondary.withOpacity(0.35),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🎉', style: TextStyle(fontSize: 64)),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'Your Craft Is Ready!',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your product has been added to KalaSaathi Marketplace.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Journey summary card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: AppTheme.cardRadius,
                    border: Border.all(color: AppTheme.divider),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '✨ Your AI-Powered Journey',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _journeyStep(context, '📸', 'Product Image', 'AI Enhanced',
                          AppTheme.primary),
                      _journeyArrow(),
                      _journeyStep(context, '🎤', 'Artisan Voice',
                          'Transcribed & Translated', AppTheme.secondary),
                      _journeyArrow(),
                      _journeyStep(context, '🤖', 'AI Catalogue',
                          'Auto-Generated & Edited', AppTheme.info),
                      _journeyArrow(),
                      _journeyStep(context, '💰', 'Smart Pricing',
                          'Cost Floor & Margin', AppTheme.accent),
                      _journeyArrow(),
                      _journeyStep(context, '🛡️', 'Artisan Sign-Off',
                          'Human-in-the-Loop Approved', AppTheme.primaryDark),
                      _journeyArrow(),
                      _journeyStep(context, '🛍️', 'Marketplace Listing',
                          'Published & Live!', AppTheme.success,
                          isLast: true),
                    ],
                  ),
                ),

                if (product != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.06),
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(
                          color: AppTheme.secondary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF8E1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Center(
                            child: Text(product.imageEmoji, style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹${product.price.toInt()} • Live in Marketplace',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppTheme.secondary),
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
                            '✅ Published',
                            style: TextStyle(
                              color: AppTheme.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    '/main',
                    (route) => false,
                    arguments: {'tab': 2},
                  ),
                  icon: const Icon(Icons.storefront),
                  label: const Text('View Marketplace'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: AppTheme.secondary,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    '/image-enhancement',
                    (route) => route.isFirst,
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Another Craft'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    foregroundColor: AppTheme.secondary,
                    side: const BorderSide(color: AppTheme.secondary),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _journeyStep(
    BuildContext context,
    String emoji,
    String title,
    String subtitle,
    Color color, {
    bool isLast = false,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.check_circle, color: color, size: 20),
      ],
    );
  }

  Widget _journeyArrow() {
    return const Padding(
      padding: EdgeInsets.only(left: 22, top: 4, bottom: 4),
      child: Icon(Icons.keyboard_arrow_down,
          color: AppTheme.textTertiary, size: 20),
    );
  }
}
