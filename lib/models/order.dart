enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.shipped: return 'Shipped';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }

  String get emoji {
    switch (this) {
      case OrderStatus.pending: return '⏳';
      case OrderStatus.confirmed: return '✅';
      case OrderStatus.shipped: return '🚚';
      case OrderStatus.delivered: return '📦';
      case OrderStatus.cancelled: return '❌';
    }
  }
}

class Order {
  final String orderId;
  final String productId;
  final String productName;
  final String productEmoji;
  final String buyerName;
  final String buyerLocation;
  final int quantity;
  final double amount;
  final DateTime orderDate;
  final OrderStatus status;

  const Order({
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.productEmoji,
    required this.buyerName,
    required this.buyerLocation,
    required this.quantity,
    required this.amount,
    required this.orderDate,
    required this.status,
  });
}
