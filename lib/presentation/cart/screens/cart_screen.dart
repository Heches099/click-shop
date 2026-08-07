import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/premium_button.dart';
import '../../core/widgets/smart_image.dart';
import '../../../config/design_tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/cart_item.dart';
import '../../home/providers/home_provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final subtotal = ref.watch(cartProvider.notifier).subtotal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('My Bag', style: AppTypography.h2),
        actions: [
          if (cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.delete_sweep_outlined,
                    color: AppColors.error),
                onPressed: () => _showClearCartDialog(context, ref),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(context, ref)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) => FadeInRight(
                      delay: Duration(milliseconds: 100 * index),
                      child: _buildCartItem(context, ref, cartItems[index]),
                    ),
                  ),
                ),
                _buildSummary(context, subtotal),
              ],
            ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Bag?'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear All',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: AppShadows.soft,
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  size: 80, color: AppColors.textHint),
            ),
          ),
          const SizedBox(height: 32),
          const FadeInUp(
            child: Text('Your bag is empty', style: AppTypography.h2),
          ),
          const SizedBox(height: 8),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
                'Looks like you haven\'t added\nanything to your bag yet.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () =>
                    ref.read(mainTabIndexProvider.notifier).state = 0,
                child: const Text('Start Shopping'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, WidgetRef ref, CartItem item) {
    final thumb = AppResponsive.thumbnailSize(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Hero(
              tag: 'cart_image_${item.product.id}',
              child: SmartImage(
                imagePath: item.product.firstImage,
                width: thumb,
                height: thumb,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(item.product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyLarge
                                .copyWith(fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            size: 18, color: AppColors.textHint),
                        onPressed: () =>
                            ref.read(cartProvider.notifier).removeItem(
                                  item.product.id,
                                  color: item.selectedColor,
                                  size: item.selectedSize,
                                ),
                      ),
                    ],
                  ),
                  Text(
                      'Size: ${item.selectedSize ?? "M"}  •  Color: ${item.selectedColor ?? "Default"}',
                      style: AppTypography.labelMedium),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${item.product.price.toStringAsFixed(2)}',
                          style: AppTypography.titleLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700)),
                      _buildQuantityStepper(ref, item),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityStepper(WidgetRef ref, CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepperButton(
              Icons.remove,
              () => ref
                  .read(cartProvider.notifier)
                  .updateQuantity(item.product.id, item.quantity - 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: 30,
              child: Center(
                child: Text('${item.quantity}',
                    style: AppTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          _buildStepperButton(
              Icons.add,
              () => ref
                  .read(cartProvider.notifier)
                  .updateQuantity(item.product.id, item.quantity + 1)),
        ],
      ),
    );
  }

  Widget _buildStepperButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 16, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, double subtotal) {
    final shipping = subtotal > 500 ? 0.0 : 15.0;
    final total = subtotal + shipping;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppResponsive.scale(context, 24),
        AppResponsive.scale(context, 24),
        AppResponsive.scale(context, 24),
        MediaQuery.viewInsetsOf(context).bottom +
            AppResponsive.scale(context, 24),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Shipping',
              shipping == 0 ? 'Free' : '\$${shipping.toStringAsFixed(2)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: AppColors.divider),
          ),
          _buildSummaryRow('Total', '\$${total.toStringAsFixed(2)}',
              isTotal: true),
          const SizedBox(height: 28),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: PremiumPressableButton(
              onPressed: () => context.push('/checkout'),
              text: 'Checkout',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: isTotal
                ? AppTypography.titleLarge
                : AppTypography.bodyLarge
                    .copyWith(color: AppColors.textSecondary)),
        Text(value,
            style: isTotal
                ? AppTypography.h2.copyWith(color: AppColors.primary)
                : AppTypography.bodyLarge
                    .copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
