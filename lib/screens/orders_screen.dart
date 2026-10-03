import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/order.dart';

class OrdersScreen extends StatelessWidget {
  final List<Order> orders;

  const OrdersScreen({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Orders'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: AppTheme.chipRadius,
              ),
              child: Text(
                '${orders.length} Orders',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📦', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text('No orders yet',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Your orders will appear here',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _OrderCard(order: orders[i]),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.delivered:
        return AppTheme.success;
      case OrderStatus.shipped:
        return AppTheme.info;
      case OrderStatus.confirmed:
        return AppTheme.secondary;
      case OrderStatus.cancelled:
        return AppTheme.error;
      case OrderStatus.pending:
        return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Order header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderId,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: AppTheme.chipRadius,
                  border: Border.all(
                      color: _statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  '${order.status.emoji} ${order.status.displayName}',
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: AppTheme.divider, thickness: 1),
          const SizedBox(height: 12),

          // Product info
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Center(
                  child: Text(
                    order.productEmoji,
                    style: const TextStyle(fontSize: 26),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 12, color: AppTheme.textTertiary),
                        const SizedBox(width: 3),
                        Text(
                          order.buyerName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Text(' • ', style: TextStyle(color: AppTheme.textTertiary)),
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppTheme.textTertiary),
                        const SizedBox(width: 3),
                        Text(
                          order.buyerLocation,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: AppTheme.divider, thickness: 1),
          const SizedBox(height: 10),

          // Order details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoItem(
                context: context,
                label: 'Quantity',
                value: '${order.quantity} item${order.quantity > 1 ? 's' : ''}',
              ),
              _InfoItem(
                context: context,
                label: 'Date',
                value: _formatDate(order.orderDate),
              ),
              _InfoItem(
                context: context,
                label: 'Amount',
                value: '₹${order.amount.toInt()}',
                valueColor: AppTheme.primary,
                bold: true,
              ),
            ],
          ),

          // Progress bar for non-delivered orders
          if (order.status != OrderStatus.delivered &&
              order.status != OrderStatus.cancelled) ...[
            const SizedBox(height: 14),
            _OrderProgress(status: order.status),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _InfoItem extends StatelessWidget {
  final BuildContext context;
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _InfoItem({
    required this.context,
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: valueColor ?? AppTheme.textPrimary,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _OrderProgress extends StatelessWidget {
  final OrderStatus status;

  const _OrderProgress({required this.status});

  double get _progress {
    switch (status) {
      case OrderStatus.pending:
        return 0.25;
      case OrderStatus.confirmed:
        return 0.5;
      case OrderStatus.shipped:
        return 0.75;
      default:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Progress',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: AppTheme.surfaceVariant,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['Pending', 'Confirmed', 'Shipped', 'Delivered']
              .map((s) => Text(
                    s,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: status.displayName == s
                          ? AppTheme.secondary
                          : AppTheme.textTertiary,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
