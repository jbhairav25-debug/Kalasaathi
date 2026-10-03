import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PricingCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isHighlighted;

  const PricingCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withOpacity(0.1) : AppTheme.cardBg,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(
          color: isHighlighted ? color.withOpacity(0.4) : AppTheme.divider,
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: isHighlighted ? AppTheme.cardShadow : AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
