import '../../core/widgets/smart_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../../config/design_tokens.dart';
import '../../../core/utils/responsive.dart';

class PremiumBannerSlider extends StatelessWidget {
  const PremiumBannerSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: AppResponsive.bannerHeight(context),
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 1000),
        viewportFraction: 0.85,
      ),
      items: const [
        _BannerItem(
          title: 'Summer Collection',
          subtitle: 'Up to 50% OFF',
          color: Color(0xFF1D1D1F),
          imageUrl: 'assets/images/shoes2.jpg',
        ),
        _BannerItem(
          title: 'New Arrivals',
          subtitle: 'Explore the latest trends',
          color: Color(0xFF1D1D1F),
          isDark: false,
          imageUrl: 'assets/images/shoes3.jpg',
        ),
        _BannerItem(
          title: 'New pc',
          subtitle: 'Brand new laptop',
          color: Colors.black,
          imageUrl: 'assets/images/game_pc1.jpg',
        ),
        _BannerItem(
          title: 'RAM',
          subtitle: 'High speed & performance RAM',
          color: Colors.black,
          imageUrl: 'assets/images/ram0.jpg',
        ),
        _BannerItem(
          title: 'Shoes',
          subtitle: 'Snikers',
          color: Color(0xFF1D1D1F),
          imageUrl: 'assets/images/shoes0.jpg',
        ),
        _BannerItem(
          title: 'Men collections',
          subtitle: 'Brand new outfit',
          color: Colors.black,
          imageUrl: 'assets/images/men_1.jpg',
        ),
        _BannerItem(
          title: 'Mouse',
          subtitle: 'Best gemming mouse',
          color: Color(0xFF1D1D1F),
          imageUrl: 'assets/images/mouse_1.jpg',
        ),
        _BannerItem(
          title: 'Office seat ',
          subtitle: 'Royal and comfort seat',
          color: Colors.black,
          imageUrl: 'assets/images/game_pc1.jpg',
        ),
        _BannerItem(
          title: 'Jacket',
          subtitle: 'Winter jacket',
          color: Colors.black,
          imageUrl: 'assets/images/jacket1.jpg',
        ),
        _BannerItem(
          title: 'Watch',
          subtitle: 'Royal Time',
          color: Colors.black,
          imageUrl: 'assets/images/watch.jpg',
        ),
        _BannerItem(
          title: 'Jordan',
          subtitle: 'Brand new features',
          color: Colors.black,
          imageUrl: 'assets/images/pink.jpg',
        ),
      ],
    );
  }
}

class _BannerItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final String imageUrl;
  final bool isDark;

  const _BannerItem({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.imageUrl,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Opacity(
              opacity: 0.6,
              child: SmartImage(
                imagePath: imageUrl,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppResponsive.scale(context, 24)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark ? Colors.white70 : Colors.white24,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: AppTypography.h2.copyWith(
                      color: isDark
                          ? const Color.fromARGB(255, 15, 158, 115)
                          : Colors.purpleAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      minimumSize: const Size(100, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Shop Now'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
