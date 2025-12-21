class DashboardStats {
  final int totalOrders;
  final double totalRevenue;
  final int pendingOrders;
  final int preparingOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final int avgDeliveryTime; // in minutes
  final int acceptanceRate; // percentage
  final double avgRating;
  final double commission;
  final double netRevenue;
  final int activeRiders;
  final int totalMenuItems;
  final int availableMenuItems;

  DashboardStats({
    required this.totalOrders,
    required this.totalRevenue,
    required this.pendingOrders,
    required this.preparingOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.avgDeliveryTime,
    required this.acceptanceRate,
    required this.avgRating,
    required this.commission,
    required this.netRevenue,
    required this.activeRiders,
    required this.totalMenuItems,
    required this.availableMenuItems,
  });

  factory DashboardStats.empty() {
    return DashboardStats(
      totalOrders: 0,
      totalRevenue: 0,
      pendingOrders: 0,
      preparingOrders: 0,
      deliveredOrders: 0,
      cancelledOrders: 0,
      avgDeliveryTime: 0,
      acceptanceRate: 0,
      avgRating: 0,
      commission: 0,
      netRevenue: 0,
      activeRiders: 0,
      totalMenuItems: 0,
      availableMenuItems: 0,
    );
  }
}

class OrderTrend {
  final String date;
  final int orders;
  final double revenue;

  OrderTrend({
    required this.date,
    required this.orders,
    required this.revenue,
  });
}

class TopMenuItem {
  final String name;
  final int quantity;
  final double revenue;

  TopMenuItem({
    required this.name,
    required this.quantity,
    required this.revenue,
  });
}
