import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../config/design_tokens.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/affiliate.dart';
import '../../../domain/entities/product.dart';
import '../../core/widgets/premium_button.dart';
import '../../home/providers/home_provider.dart';
import '../providers/affiliate_provider.dart';

class AffiliatePortalScreen extends ConsumerStatefulWidget {
  const AffiliatePortalScreen({super.key});

  @override
  ConsumerState<AffiliatePortalScreen> createState() =>
      _AffiliatePortalScreenState();
}

class _AffiliatePortalScreenState extends ConsumerState<AffiliatePortalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _paymentCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _paymentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountAsync = ref.watch(affiliateAccountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Affiliate Program', style: AppTypography.h2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: accountAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (account) {
          if (account == null) {
            return _buildSignupView();
          }
          return _buildDashboard(account);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sign-up flow (new affiliate)
  // ---------------------------------------------------------------------------

  Widget _buildSignupView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        FadeInDown(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppShadows.medium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.rocket_launch_rounded,
                      color: Colors.black, size: 26),
                ),
                const SizedBox(height: 16),
                Text('Earn ${(commissionRate * 100).round()}% '
                    'on every sale',
                    style: AppTypography.h2.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  'Share your link. Get paid when people shop. '
                  'Simple, transparent, real.',
                  style: AppTypography.bodyMedium
                      .copyWith(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const FadeInUp(
          child: Text('How it works', style: AppTypography.h2),
        ),
        const SizedBox(height: 16),
        FadeInUp(
          delay: const Duration(milliseconds: 100),
          child: _buildHowItWorks(),
        ),
        const SizedBox(height: 28),
        const FadeInUp(
          child: Text('Become an affiliate', style: AppTypography.h2),
        ),
        const SizedBox(height: 16),
        FadeInUp(
          delay: const Duration(milliseconds: 150),
          child: _buildSignupForm(),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHowItWorks() {
    final steps = [
      (Icons.share_outlined, 'Share your link',
          'Get a unique tracking link and share it anywhere.'),
      (Icons.shopping_bag_outlined, 'They shop',
          'People click, browse and buy — you get credited.'),
      (Icons.attach_money_rounded, 'You earn',
          '${(commissionRate * 100).round()}% commission '
              'on every referred order.'),
    ];
    return Column(
      children: steps.asMap().entries.map((entry) {
        final icon = entry.value.$1;
        final title = entry.value.$2;
        final desc = entry.value.$3;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.soft,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: AppTypography.titleLarge.copyWith(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(desc,
                          style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                Text('${entry.key + 1}',
                    style: AppTypography.titleLarge
                        .copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSignupForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(_nameCtrl, 'Full name', Icons.person_outline_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null),
            const SizedBox(height: 12),
            _buildField(_emailCtrl, 'Email',
                Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Enter a valid email'
                    : null),
            const SizedBox(height: 12),
            _buildField(
                _paymentCtrl, 'Payout email (optional)', Icons.payments_outlined,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            PremiumPressableButton(
              onPressed: _submitting ? null : _submitSignup,
              text: _submitting ? 'Creating...' : 'Start Earning',
              icon: Icons.rocket_launch_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _submitSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    await ref.read(affiliateUseCaseProvider).createAccount(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          paymentEmail: _paymentCtrl.text.isEmpty
              ? _emailCtrl.text
              : _paymentCtrl.text,
        );

    ref.invalidate(affiliateAccountProvider);
    ref.invalidate(affiliateStatsProvider);
    ref.invalidate(affiliateCommissionsProvider);
    if (mounted) setState(() => _submitting = false);
  }

  // ---------------------------------------------------------------------------
  // Dashboard (active affiliate)
  // ---------------------------------------------------------------------------

  Widget _buildDashboard(AffiliateAccount account) {
    final statsAsync = ref.watch(affiliateStatsProvider);
    final commissionsAsync = ref.watch(affiliateCommissionsProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        FadeInDown(child: _buildHeader(account)),
        const SizedBox(height: 20),
        statsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (stats) => Column(
            children: [
              _buildStatsRow(stats),
              const SizedBox(height: 20),
              _buildPromoCodeCard(account),
              const SizedBox(height: 16),
              _buildReferralLinkCard(account),
              const SizedBox(height: 20),
              _buildPayoutCard(account, stats),
              const SizedBox(height: 24),
            ],
          ),
        ),
        const FadeInUp(
          child: Text('Commission history', style: AppTypography.h2),
        ),
        const SizedBox(height: 12),
        commissionsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (commissions) => commissions.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    ...commissions.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildCommissionTile(c),
                        )),
                  ],
                ),
        ),
        const SizedBox(height: 24),
        const FadeInUp(
          child: Text('Products to promote', style: AppTypography.h2),
        ),
        const SizedBox(height: 4),
        const FadeInUp(
          child: Text(
            'Share these products and earn commission on every sale',
            style: AppTypography.bodyMedium,
          ),
        ),
        const SizedBox(height: 12),
        _buildProductsToPromote(account),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHeader(AffiliateAccount account) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.medium,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Text(
              account.name.isNotEmpty
                  ? account.name.characters.first.toUpperCase()
                  : 'A',
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, ${account.name}',
                    style: AppTypography.titleLarge.copyWith(
                        color: Colors.white, fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  account.isActive
                      ? '● Active affiliate — earn ${(commissionRate * 100).round()}% per sale'
                      : 'Account pending review',
                  style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AffiliateStats stats) {
    return Row(
      children: [
        _buildStatCard(Icons.mouse_outlined, 'Clicks', '${stats.clicks}'),
        const SizedBox(width: 12),
        _buildStatCard(Icons.shopping_bag_outlined, 'Sales', '${stats.sales}'),
        const SizedBox(width: 12),
        _buildStatCard(
          Icons.attach_money_rounded,
          'Earned',
          '\$${stats.commission.toStringAsFixed(2)}',
          highlight: true,
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value,
      {bool highlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: highlight ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: highlight ? null : Border.all(color: AppColors.border),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          children: [
            Icon(icon,
                color: highlight ? AppColors.secondary : AppColors.primary,
                size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: AppTypography.titleLarge.copyWith(
                  color: highlight ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: AppTypography.labelMedium.copyWith(
                    color: highlight ? Colors.white70 : AppColors.textSecondary,
                    fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeCard(AffiliateAccount account) {
    return _buildValueCard(
      icon: Icons.tag_rounded,
      title: 'Your promo code',
      subtitle: 'Shoppers use it at checkout for your attribution.',
      trailing: _copyChip(account.promoCode,
          onTap: () => _copy(account.promoCode, 'Promo code copied')),
    );
  }

  Widget _buildReferralLinkCard(AffiliateAccount account) {
    return _buildValueCard(
      icon: Icons.link_rounded,
      title: 'Your referral link',
      subtitle: 'Share this link — any purchase tracks to you.',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Copy link',
            icon: const Icon(Icons.copy_rounded, size: 20),
            color: AppColors.primary,
            onPressed: () async {
              final link =
                  await ref.read(affiliateUseCaseProvider).buildReferralLink(
                        account.promoCode,
                      );
              await _copy(link, 'Referral link copied');
            },
          ),
          IconButton(
            tooltip: 'Share link',
            icon: const Icon(Icons.share_rounded, size: 20),
            color: AppColors.secondary,
            onPressed: () => _shareLink(account.promoCode),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTypography.labelMedium
                        .copyWith(fontSize: 12, height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }

  Widget _copyChip(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(width: 6),
            const Icon(Icons.copy_rounded, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutCard(AffiliateAccount account, AffiliateStats stats) {
    final eligible = stats.commission >= 25;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Available balance',
                    style: AppTypography.labelMedium),
                const SizedBox(height: 4),
                Text('\$${stats.commission.toStringAsFixed(2)}',
                    style: AppTypography.h1.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  eligible
                      ? 'Ready to withdraw to ${account.paymentEmail}'
                      : 'Withdraw at \$25.00 (currently '
                          '\$${stats.commission.toStringAsFixed(2)})',
                  style: AppTypography.labelMedium
                      .copyWith(fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: PremiumPressableButton(
              onPressed: eligible && !_submitting
                  ? _requestPayout
                  : null,
              text: 'Withdraw',
              height: 48,
              color: AppColors.secondary,
              textColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionTile(AffiliateCommission c) {
    final statusColor = c.status == CommissionStatus.paid
        ? const Color(0xFF0E9E60)
        : c.status == CommissionStatus.approved
            ? AppColors.secondary
            : AppColors.textHint;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ${c.orderId}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  '${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year} '
                  '· ${(c.rate * 100).round()}% of \$${c.orderAmount.toStringAsFixed(2)}',
                  style: AppTypography.labelMedium.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${c.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 2),
              Text(c.status.name.toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, color: AppColors.textHint, size: 32),
          const SizedBox(height: 8),
          Text('No commissions yet',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          const Text('Share your link to start earning',
              style: AppTypography.labelMedium),
        ],
      ),
    );
  }

  Widget _buildProductsToPromote(AffiliateAccount account) {
    final productsAsync = ref.watch(featuredProductsProvider);
    return productsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Center(child: Text('Error loading products: $e')),
      data: (products) {
        if (products.isEmpty) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildAffiliateProductCard(product, account.promoCode);
            },
          ),
        );
      },
    );
  }

  Widget _buildAffiliateProductCard(Product product, String promoCode) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.firstImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.background,
                      child: const Icon(Icons.image_outlined,
                          color: AppColors.textHint),
                    ),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${product.discountPercentage.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium
                      .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _shareProductLink(product, promoCode),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.share_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Share',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareProductLink(Product product, String promoCode) async {
    final baseLink =
        await ref.read(affiliateUseCaseProvider).buildReferralLink(promoCode);
    final productLink =
        '$baseLink/product/${product.id}?ref=$promoCode';
    await SharePlus.instance.share(
        ShareParams(text: 'Check out ${product.name} — $productLink'));
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _copy(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _shareLink(String code) async {
    final link = await ref.read(affiliateUseCaseProvider).buildReferralLink(code);
    await SharePlus.instance.share(ShareParams(text: 'Shop with ClickShop — $link'));
  }

  Future<void> _requestPayout() async {
    setState(() => _submitting = true);
    await ref.read(affiliateUseCaseProvider).requestPayout();
    ref.invalidate(affiliateStatsProvider);
    ref.invalidate(affiliateCommissionsProvider);
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Payout requested — it will be sent to your payout email.'),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

/// Configured affiliate commission rate (from AppConstants).
double get commissionRate => AppConstants.affiliateCommissionRate;
