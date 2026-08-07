import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/cyber_background_painter.dart';
import '../widgets/neon_border_avatar.dart';
import '../../affiliate/providers/affiliate_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _scanController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _scanController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Classic color palette
    const primaryColor = Color(0xFF1A237E); // deep navy
    const accentColor = Color(0xFFD4AF37); // gold
    const secondaryColor = Color(0xFF00897B); // teal

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E),
      body: Stack(
        children: [
          // Futuristic Cyber Grid Background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return CustomPaint(
                painter: CyberBackgroundPainter(
                  animationValue: _backgroundController.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(accentColor),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildClassicCyberHeader(
                          textTheme, primaryColor, accentColor, secondaryColor),
                      const SizedBox(height: 32),
                      _buildAffiliateStatsRow(accentColor),
                      const SizedBox(height: 32),
                      _buildMenuSection(context, 'SYSTEM ACCESS', [
                        _MenuItem(
                          icon: Icons.receipt_long_outlined,
                          title: 'My Orders',
                          onTap: () => context.push('/orders'),
                          accentColor: secondaryColor,
                        ),
                        _MenuItem(
                          icon: Icons.rocket_launch_rounded,
                          title: 'Affiliate Program',
                          onTap: () => context.push('/affiliate'),
                          accentColor: accentColor,
                        ),
                        _MenuItem(
                          icon: Icons.favorite_border,
                          title: 'Wishlist',
                          onTap: () => context.push('/wishlist'),
                          accentColor: secondaryColor,
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildMenuSection(context, 'SECURITY & SETTINGS', [
                        _MenuItem(
                          icon: Icons.location_on_outlined,
                          title: 'Addresses',
                          onTap: () => context.push('/addresses'),
                          accentColor: primaryColor,
                        ),
                        _MenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          onTap: () => context.push('/settings'),
                          accentColor: secondaryColor,
                        ),
                      ]),
                      const SizedBox(height: 40),
                      _buildLogoutButton(textTheme, accentColor),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Scanning Line Effect
          _buildScanningLine(accentColor),
        ],
      ),
    );
  }

  Widget _buildAppBar(Color accentColor) {
    return SliverAppBar(
      expandedHeight: 80,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'USER_PROFILE',
          style: TextStyle(
            color: accentColor,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildClassicCyberHeader(TextTheme textTheme, Color primaryColor,
      Color accentColor, Color secondaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.5),
            secondaryColor.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -5,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              const NeonBorderAvatar(
                imageUrl: 'https://picsum.photos/id/64/200/200',
                size: 80,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alex Johnson',
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'alex.johnson@email.com',
                      style:
                          textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: accentColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        'ID: CS-2070-9942',
                        style: textTheme.bodySmall?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAffiliateStatsRow(Color accentColor) {
    final statsAsync = ref.watch(affiliateStatsProvider);

    return statsAsync.when(
      data: (stats) => Row(
        children: [
          _buildStatItem('CLICKS', '${stats.clicks}', accentColor),
          const SizedBox(width: 12),
          _buildStatItem('SALES', '${stats.sales}', accentColor),
          const SizedBox(width: 12),
          _buildStatItem(
              'EARNED', '\$${stats.commission.toStringAsFixed(0)}', accentColor,
              isPremium: true),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(String label, String value, Color accentColor,
      {bool isPremium = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPremium
              ? accentColor.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPremium ? accentColor : accentColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPremium ? accentColor : Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
      BuildContext context, String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
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
              color: Colors.transparent,
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            Icon(item.icon, color: item.accentColor, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item.title.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: Colors.white24),
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

  Widget _buildLogoutButton(TextTheme textTheme, Color accentColor) {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
          ),
          child: Text(
            'TERMINATE_SESSION',
            style: textTheme.labelLarge?.copyWith(
              color: Colors.redAccent,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanningLine(Color accentColor) {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (context, child) {
        return Positioned(
          top: _scanController.value * MediaQuery.of(context).size.height,
          left: 0,
          right: 0,
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 1,
                )
              ],
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0),
                  accentColor.withValues(alpha: 0.4),
                  accentColor.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color accentColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.accentColor,
  });
}
