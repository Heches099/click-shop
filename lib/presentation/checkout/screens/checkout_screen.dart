import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/usecases/affiliate_usecase.dart';
import '../../../core/services/payments/payment_service.dart';
import '../../../core/services/analytics/analytics_service.dart';
import '../../affiliate/providers/affiliate_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/providers/orders_provider.dart';
import '../../core/widgets/premium_button.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  static const List<String> _payments = ['Apple Pay', 'Credit Card', 'PayPal'];

  int _currentStep = 0;
  int _selectedAddressIndex = 0;
  int _selectedPaymentIndex = 0;
  final List<Address> _addresses = [
    const Address(
      id: 'addr_home',
      name: 'Alex Johnson',
      phone: '+1 555 0100',
      street: '123 Apple Street',
      city: 'Cupertino',
      state: 'CA',
      zipCode: '95014',
      country: 'USA',
      isDefault: true,
    ),
    const Address(
      id: 'addr_office',
      name: 'Alex Johnson',
      phone: '+1 555 0101',
      street: 'One Infinite Loop',
      city: 'Cupertino',
      state: 'CA',
      zipCode: '95014',
      country: 'USA',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Checkout', style: AppTypography.h2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildPremiumStepper(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _buildStepContent(key: ValueKey(_currentStep)),
            ),
          ),
          if (cartItems.isNotEmpty || _currentStep > 0) _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildPremiumStepper() {
    final steps = ['Address', 'Payment', 'Review'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final isCompleted = _currentStep > index;
              final isActive = _currentStep == index;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isCompleted || isActive
                          ? AppColors.primary
                          : AppColors.border,
                      shape: BoxShape.circle,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    steps[index],
                    style: AppTypography.labelMedium.copyWith(
                      color:
                          isActive ? AppColors.textPrimary : AppColors.textHint,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 2,
                width: double.infinity,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 2,
                width: MediaQuery.of(context).size.width *
                    (_currentStep / (steps.length - 1)),
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent({required Key key}) {
    switch (_currentStep) {
      case 0:
        return _buildAddressStep(key: key);
      case 1:
        return _buildPaymentStep(key: key);
      case 2:
        return _buildReviewStep(key: key);
      default:
        return const SizedBox();
    }
  }

  Widget _buildAddressStep({required Key key}) {
    return ListView(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const FadeInDown(
          duration: Duration(milliseconds: 400),
          child: Text('Where should we send it?', style: AppTypography.h2),
        ),
        const SizedBox(height: 24),
        ..._addresses.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FadeInUp(
                delay: Duration(milliseconds: 100 * entry.key),
                child: _buildAddressCard(entry.value, entry.key),
              ),
            )),
        const SizedBox(height: 32),
        FadeInUp(
          delay: const Duration(milliseconds: 300),
          child: OutlinedButton.icon(
            onPressed: _addNewAddress,
            icon: const Icon(Icons.add),
            label: const Text('Add New Address'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard(Address address, int index) {
    final isSelected = _selectedAddressIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedAddressIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              : AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      address.id.contains('home')
                          ? Icons.home_filled
                          : Icons.business_center_rounded,
                      color:
                          isSelected ? AppColors.primary : AppColors.textHint,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(address.id.contains('home') ? 'Home' : 'Office',
                        style: AppTypography.titleLarge.copyWith(fontSize: 16)),
                  ],
                ),
                if (address.isDefault)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('DEFAULT',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(address.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(address.fullAddress,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(address.phone,
                style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _addNewAddress() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final street = TextEditingController();
    final city = TextEditingController();
    final stateCtrl = TextEditingController();
    final zip = TextEditingController();
    final country = TextEditingController();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Add New Address', style: AppTypography.h2),
                const SizedBox(height: 20),
                _buildField(name, 'Full Name'),
                _buildField(phone, 'Phone', keyboardType: TextInputType.phone),
                _buildField(street, 'Street Address'),
                _buildField(city, 'City'),
                _buildField(stateCtrl, 'State'),
                _buildField(zip, 'ZIP Code',
                    keyboardType: TextInputType.number),
                _buildField(country, 'Country'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (name.text.isEmpty ||
                        street.text.isEmpty ||
                        city.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please fill name, street and city'),
                          behavior: SnackBarBehavior.floating));
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Address'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved == true) {
      setState(() {
        _addresses.add(Address(
          id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
          name: name.text,
          phone: phone.text.isEmpty ? 'N/A' : phone.text,
          street: street.text,
          city: city.text,
          state: stateCtrl.text,
          zipCode: zip.text,
          country: country.text.isEmpty ? 'USA' : country.text,
        ));
        _selectedAddressIndex = _addresses.length - 1;
      });
    }
  }

  Widget _buildField(TextEditingController ctrl, String label,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildPaymentStep({required Key key}) {
    return ListView(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const Text('How would you like to pay?', style: AppTypography.h2),
        const SizedBox(height: 24),
        ..._payments.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPaymentOption(entry.value, entry.key),
            )),
      ],
    );
  }

  Widget _buildPaymentOption(String label, int index) {
    final isSelected = _selectedPaymentIndex == index;
    final icon = index == 0
        ? Icons.apple
        : index == 1
            ? Icons.credit_card_rounded
            : Icons.account_balance_wallet_rounded;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28),
            ),
            const SizedBox(width: 20),
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary)
            else
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep({required Key key}) {
    final items = ref.watch(cartProvider);
    final subtotal = ref.watch(cartProvider.notifier).subtotal;
    final shipping = subtotal > 500 ? 0.0 : 15.0;
    final total = subtotal + shipping;

    return ListView(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const Text('Order Summary', style: AppTypography.titleLarge),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            children: [
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                                '${item.product.name} x${item.quantity}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis)),
                        Text('\$${item.totalPrice.toStringAsFixed(2)}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider()),
              _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
              _buildSummaryRow('Shipping',
                  shipping == 0 ? 'Free' : '\$${shipping.toStringAsFixed(2)}'),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider()),
              _buildSummaryRow('Total', '\$${total.toStringAsFixed(2)}',
                  isTotal: true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
            'Deliver to', _addresses[_selectedAddressIndex].fullAddress),
        const SizedBox(height: 16),
        _buildInfoCard('Pay with', _payments[_selectedPaymentIndex]),
        _buildReferralInfo(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildReferralInfo() {
    final refCode = ref.watch(currentRefCodeProvider).value;
    if (refCode == null || refCode.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.celebration_outlined,
                color: AppColors.secondary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'You were referred by affiliate $refCode — they earn a '
                'commission on this order.',
                style: AppTypography.bodyMedium.copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge.copyWith(fontSize: 16)),
          const SizedBox(height: 8),
          Text(content,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: isTotal
                  ? AppTypography.titleLarge
                  : AppTypography.bodyMedium),
          Text(value,
              style: isTotal
                  ? AppTypography.titleLarge.copyWith(color: AppColors.primary)
                  : const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppResponsive.scale(context, 24),
        20,
        AppResponsive.scale(context, 24),
        MediaQuery.viewInsetsOf(context).bottom +
            AppResponsive.scale(context, 24),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: AppShadows.medium,
      ),
      child: PremiumPressableButton(
        onPressed: _currentStep < 2 ? _nextStep : _placeOrder,
        text: _currentStep < 2 ? 'Continue' : 'Place Order',
      ),
    );
  }

  void _nextStep() {
    setState(() => _currentStep++);
  }

  Future<void> _placeOrder() async {
    final items = ref.read(cartProvider);
    if (items.isEmpty) return;

    final subtotal = ref.read(cartProvider.notifier).subtotal;
    final shipping = subtotal > 500 ? 0.0 : 15.0;
    final total = subtotal + shipping;

    // Trigger Payment
    final paymentSuccess = await sl<PaymentService>().processPayment(
      amount: total,
      currency: 'usd',
    );

    if (!paymentSuccess) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment failed or cancelled. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final affiliateCode = await sl<AffiliateUseCase>().getCurrentRefCode();
    final order = ref.read(ordersProvider.notifier).placeOrder(
          items: items,
          subtotal: subtotal,
          shippingAddress: _addresses[_selectedAddressIndex],
          affiliateCode: affiliateCode,
        );
    ref.read(cartProvider.notifier).clearCart();

    // Log Analytics
    await sl<AnalyticsService>().logPurchase(
      orderId: order.id,
      amount: order.total,
    );

    // Attribute commission to the referring affiliate, if the visitor came
    // through an affiliate tracking link (?ref=CODE).
    if (affiliateCode != null && affiliateCode.isNotEmpty) {
      await sl<AffiliateUseCase>().recordSale(
        orderId: order.id,
        orderAmount: order.total,
      );
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle_rounded,
            color: AppColors.primary, size: 56),
        content: const Text('Your order has been placed successfully!',
            textAlign: TextAlign.center),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('View Orders'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    context.pushReplacement('/orders');
  }
}
