import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../core/widgets/smart_image.dart';
import '../../../domain/entities/user.dart';
import '../../affiliate/providers/affiliate_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: authState.when(
                loading: () => const SizedBox(
                  height: 320,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => _buildErrorState(context, error),
                data: (user) {
                  if (user == null) return _buildSignedOutState(context);
                  return _buildSignedInContent(context, ref, user);
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Row(
        children: [
          Image.asset(
            'assets/icons/logo.png',
            height: 30,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Text('Profile', style: AppTypography.titleLarge),
        ],
      ),
    );
  }

  Widget _buildSignedInContent(
      BuildContext context, WidgetRef ref, AppUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserHeader(user),
        const SizedBox(height: 24),
        _buildAffiliateStatsRow(ref),
        const SizedBox(height: 32),
        _buildMenuSection('Quick Access', [
          _MenuItem(
            icon: Icons.bookmark_outline_rounded,
            title: 'Saved for later',
            onTap: () => ref.read(mainTabIndexProvider.notifier).state = 2,
          ),
          _MenuItem(
            icon: Icons.rocket_launch_rounded,
            title: 'Affiliate Program',
            onTap: () => context.push('/affiliate'),
          ),
        ]),
        const SizedBox(height: 32),
        Center(
          child: _buildLogoutButton(
            context,
            ref,
          ),
        ),
      ],
    );
  }

  Widget _buildUserHeader(AppUser user) {
    final displayName = _displayName(user);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          _buildAvatar(user),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'ID: ${_shortId(user.id)}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
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

  Widget _buildAvatar(AppUser user) {
    final photoUrl = user.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return SmartImage(
        imagePath: photoUrl,
        width: 72,
        height: 72,
        borderRadius: BorderRadius.circular(36),
        errorWidget: _avatarFallback(user),
        placeholder: _avatarFallback(user),
      );
    }
    return _avatarFallback(user);
  }

  Widget _avatarFallback(AppUser user) {
    return Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(user),
        style: const TextStyle(
          color: AppColors.onPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildAffiliateStatsRow(WidgetRef ref) {
    final statsAsync = ref.watch(affiliateStatsProvider);

    return statsAsync.when(
      data: (stats) => Row(
        children: [
          _buildStatItem('CLICKS', '${stats.clicks}'),
          const SizedBox(width: 12),
          _buildStatItem('SALES', '${stats.sales}'),
          const SizedBox(width: 12),
          _buildStatItem(
            'EARNED',
            '\$${stats.commission.toStringAsFixed(0)}',
            isPremium: true,
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(String label, String value, {bool isPremium = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPremium
              ? AppColors.secondary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isPremium ? AppColors.secondary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.labelMedium.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            return Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon,
                            color: AppColors.onPrimary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textHint),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSignedOutState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Image.asset('assets/icons/logo.png', height: 72, fit: BoxFit.contain),
          const SizedBox(height: 24),
          Text('Sign in required', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Access your orders, wishlist and affiliate dashboard by signing in to your account.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.push('/login'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push('/signup'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Create Account',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded,
              color: AppColors.error, size: 44),
          const SizedBox(height: 14),
          Text('Unable to load profile', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          Text(
            '$error',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: BorderSide(color: AppColors.accent.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => _confirmSignOut(context, ref),
      icon: const Icon(Icons.logout_rounded, size: 18),
      label: const Text('Sign Out'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign out?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'You will be signed out of your Click Shop account.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCEL',
                style: TextStyle(color: AppColors.textPrimary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('SIGN OUT',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(authProvider.notifier).signOut();
    if (context.mounted) context.go('/login');
  }

  String _displayName(AppUser user) {
    final name = user.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    final emailPrefix = user.email.split('@').first.trim();
    return emailPrefix.isEmpty ? 'User' : emailPrefix;
  }

  String _initials(AppUser user) {
    final name = user.name?.trim();
    if (name != null && name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }
    final email = user.email.trim();
    return email.isEmpty ? 'U' : email[0].toUpperCase();
  }

  String _shortId(String id) {
    final clean = id.length <= 8 ? id : id.substring(0, 8);
    return clean.toUpperCase();
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}