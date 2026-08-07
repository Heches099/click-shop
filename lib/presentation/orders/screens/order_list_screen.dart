import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../domain/entities/order.dart';
import '../../home/providers/home_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/orders_provider.dart';

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    final active = orders
        .where((o) =>
            o.status == OrderStatus.pending ||
            o.status == OrderStatus.processing ||
            o.status == OrderStatus.shipped)
        .toList();
    final completed =
        orders.where((o) => o.status == OrderStatus.delivered).toList();
    final cancelled = orders
        .where((o) =>
            o.status == OrderStatus.cancelled ||
            o.status == OrderStatus.returned)
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('My Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(context, ref, active),
            _buildOrderList(context, ref, completed),
            _buildOrderList(context, ref, cancelled),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(
      BuildContext context, WidgetRef ref, List<OrderEntity> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 64, color: AppColors.textHint),
            const SizedBox(height: 12),
            const Text('No orders here yet',
                style: AppTypography.titleLarge),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ref.read(mainTabIndexProvider.notifier).state = 0;
                context.pop();
              },
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) => FadeInUp(
        delay: Duration(milliseconds: 100 * index),
        child: _buildOrderCard(context, ref, orders[index]),
      ),
    );
  }

  Widget _buildOrderCard(
      BuildContext context, WidgetRef ref, OrderEntity order) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final isActive = order.status == OrderStatus.pending ||
        order.status == OrderStatus.processing ||
        order.status == OrderStatus.shipped;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMedium),
                    const SizedBox(height: 4),
                    Text(
                        'Placed on ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusChip(order.status),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.divider),
          ),
          if (firstItem != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${firstItem.product.name}'
                    '${order.items.length > 1 ? " +${order.items.length - 1} more" : ""}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showOrderDetails(context, ref, order),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Details'),
                ),
              ),
              const SizedBox(width: 12),
              if (isActive)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _trackOrder(context, order),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Track Order'),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _reorder(context, ref, order),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reorder'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(
      BuildContext context, WidgetRef ref, OrderEntity order) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(order.id, style: AppTypography.titleLarge),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_statusLabel(order.status),
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.secondary)),
              const SizedBox(height: 12),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.product.name} x${item.quantity}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${item.totalPrice.toStringAsFixed(2)}',
                          style: AppTypography.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal', style: AppTypography.bodyMedium),
                  Text('\$${order.subtotal.toStringAsFixed(2)}',
                      style: AppTypography.bodyMedium),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Shipping', style: AppTypography.bodyMedium),
                  Text(order.shippingFee == 0
                      ? 'Free'
                      : '\$${order.shippingFee.toStringAsFixed(2)}'),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: AppTypography.titleLarge),
                  Text('\$${order.total.toStringAsFixed(2)}',
                      style: AppTypography.titleLarge
                          .copyWith(color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Ship to: ${order.shippingAddress.fullAddress}',
                  style: AppTypography.labelMedium),
            ],
          ),
        ),
        actions: [
          if (isActiveOrder(order))
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ref.read(ordersProvider.notifier).cancelOrder(order.id);
              },
              child: const Text('Cancel Order',
                  style: TextStyle(color: AppColors.error)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _trackOrder(BuildContext context, OrderEntity order) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Track Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_shipping_rounded,
                size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Status: ${_statusLabel(order.status)}',
                style: AppTypography.titleLarge),
            const SizedBox(height: 8),
            Text('Tracking: ${order.trackingNumber ?? 'N/A'}',
                style: AppTypography.bodyMedium),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _reorder(BuildContext context, WidgetRef ref, OrderEntity order) {
    for (final item in order.items) {
      ref.read(cartProvider.notifier).addItem(
            item.product,
            color: item.selectedColor,
            size: item.selectedSize,
          );
    }
    ref.read(mainTabIndexProvider.notifier).state = 2;
    context.pop();
  }

  Widget _buildStatusChip(OrderStatus status) {
    final delivered = status == OrderStatus.delivered;
    final cancelled = status == OrderStatus.cancelled ||
        status == OrderStatus.returned;
    final color = delivered
        ? AppColors.accent
        : cancelled
            ? AppColors.error
            : AppColors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  bool isActiveOrder(OrderEntity order) {
    return order.status == OrderStatus.pending ||
        order.status == OrderStatus.processing ||
        order.status == OrderStatus.shipped;
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'In Transit';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }
}
