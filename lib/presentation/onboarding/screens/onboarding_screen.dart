import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/smart_image.dart';

class WinningOnboardingScreen extends StatefulWidget {
  const WinningOnboardingScreen({super.key});

  @override
  State<WinningOnboardingScreen> createState() =>
      _WinningOnboardingScreenState();
}

class _WinningOnboardingScreenState extends State<WinningOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      image: 'assets/images/Ganor - Zip Neck Tracksuit Set Modern Fit.jpg',
      title: 'CURATED\nCOLLECTIONS',
      subtitle: 'MODELS',
      description: 'Explore high-end styles tailored for your lifestyle.',
      tags: ['Tracksuit', 'Modern Fit'],
    ),
    OnboardingSlide(
      image:
          'assets/images/Luxury Corporate Boss Lady, Navy Blue Blazer & White Trouser Office outfits_.jpg',
      title: 'ELITE\nCORPORATE',
      subtitle: 'LADY BOSS',
      description: 'Command the room with luxury professional attire.',
      tags: ['Blazer', 'Corporate'],
    ),
    OnboardingSlide(
      image: 'assets/images/Timeless Old Money Style for Men.jpg',
      title: 'TIMELESS\nOLD MONEY',
      subtitle: 'MEN STYLE',
      description: 'Classic sophistication that never goes out of fashion.',
      tags: ['Old Money', 'Men'],
    ),
    OnboardingSlide(
      image: 'assets/images/watch.jpg',
      title: 'LIGEND\nCOLLECTIONS',
      subtitle: 'Royal Feeling',
      description: 'Classic sophistication that never goes out of fashion.',
      tags: ['New Money', 'All'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= 900 || size.width > size.height * 1.25;
    final backgroundFit = isWideScreen ? BoxFit.fitHeight : BoxFit.cover;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Full Screen Background Image with Fade Transition
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  SmartImage(
                    imagePath: _slides[index].image,
                    fit: backgroundFit,
                    alignment: Alignment.center,
                  ),
                  // Dark Gradient Overlay for readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.4, 0.8, 1.0],
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // 2. Top Navigation Bar (Glassmorphic)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(Icons.arrow_back_ios_new_rounded, () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  }),
                  Text(
                    _slides[_currentPage].subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  _buildCircleButton(Icons.more_horiz_rounded, () {}),
                ],
              ),
            ),
          ),

          // 3. Middle Content (Title, Description, and Tags)
          Positioned(
            bottom: 120,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInLeft(
                  key: ValueKey('title_$_currentPage'),
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    _slides[_currentPage].title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  key: ValueKey('desc_$_currentPage'),
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    _slides[_currentPage].description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  key: ValueKey('tags_$_currentPage'),
                  delay: const Duration(milliseconds: 400),
                  child: Wrap(
                    spacing: 8,
                    children: _slides[_currentPage]
                        .tags
                        .map((tag) => _buildTag(tag))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          // 4. Bottom Action Area
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page Indicator
                Row(
                  children: List.generate(_slides.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      height: 4,
                      width: i == _currentPage ? 24 : 8,
                      decoration: BoxDecoration(
                        color:
                            i == _currentPage ? Colors.white : Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),

                // Main CTA Button
                GestureDetector(
                  onTap: () {
                    if (_currentPage < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn,
                      );
                    } else {
                      context.go('/login');
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _currentPage == _slides.length - 1
                              ? 'EXPLORE'
                              : 'CONTINUE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
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

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final String image;
  final String title;
  final String subtitle;
  final String description;
  final List<String> tags;

  OnboardingSlide({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.tags,
  });
}
