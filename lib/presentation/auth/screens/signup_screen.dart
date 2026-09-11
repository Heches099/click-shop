import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/animated_press.dart';
import '../../core/widgets/smart_image.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final PageController _pageController = PageController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final List<String> _backgroundImages = [
    'assets/images/Ganor - Zip Neck Tracksuit Set Modern Fit.jpg',
    'assets/images/Luxury Corporate Boss Lady, Navy Blue Blazer & White Trouser Office outfits_.jpg',
    'assets/images/Timeless Old Money Style for Men.jpg',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authProvider.notifier).signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
          );
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.35),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon:
          Icon(icon, color: Colors.white.withValues(alpha: 0.45), size: 20),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null && context.mounted) {
            context.go('/');
          }
        },
        error: (error, stack) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(describeFailure(error)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      );
    });

    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 850 || size.width > size.height * 1.3;
    final backgroundFit = isWide ? BoxFit.fitHeight : BoxFit.cover;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _backgroundImages.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  SmartImage(
                    imagePath: _backgroundImages[index],
                    fit: backgroundFit,
                    alignment: Alignment.center,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.3, 0.6, 1.0],
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.5),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.18, 0.6, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.48),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.48),
                  Colors.black.withValues(alpha: 0.88),
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.go('/login'),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: BackdropFilter(
                                    filter:
                                        ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.14),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Image.asset(
                                'assets/icons/logo.png',
                                height: 44,
                                fit: BoxFit.contain,
                              ),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.l),
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join Click Shop and unlock premium access.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 520),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(AppSpacing.l),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.14),
                                      ),
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'SIGN UP',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 28,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Enter your details below to get started.',
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.55),
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.l),
                                          TextFormField(
                                            controller: _nameController,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                            decoration: _inputDecoration(
                                              hint: 'Full Name',
                                              icon: Icons.person_outline,
                                            ),
                                            validator: Validators.name,
                                          ),
                                          const SizedBox(height: AppSpacing.m),
                                          TextFormField(
                                            controller: _emailController,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                            decoration: _inputDecoration(
                                              hint: 'Email',
                                              icon: Icons.email_outlined,
                                            ),
                                            validator: Validators.email,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                          ),
                                          const SizedBox(height: AppSpacing.m),
                                          TextFormField(
                                            controller: _passwordController,
                                            obscureText: _obscurePassword,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                            decoration: _inputDecoration(
                                              hint: 'Password',
                                              icon: Icons.lock_outline,
                                            ).copyWith(
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons
                                                          .visibility_off_outlined
                                                      : Icons
                                                          .visibility_outlined,
                                                  color: Colors.white54,
                                                  size: 20,
                                                ),
                                                onPressed: () => setState(() {
                                                  _obscurePassword =
                                                      !_obscurePassword;
                                                }),
                                              ),
                                            ),
                                            validator: Validators.password,
                                          ),
                                          const SizedBox(height: AppSpacing.m),
                                          TextFormField(
                                            controller:
                                                _confirmPasswordController,
                                            obscureText: _obscureConfirm,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                            decoration: _inputDecoration(
                                              hint: 'Confirm Password',
                                              icon: Icons.lock_outline,
                                            ).copyWith(
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureConfirm
                                                      ? Icons
                                                          .visibility_off_outlined
                                                      : Icons
                                                          .visibility_outlined,
                                                  color: Colors.white54,
                                                  size: 20,
                                                ),
                                                onPressed: () => setState(() {
                                                  _obscureConfirm =
                                                      !_obscureConfirm;
                                                }),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Confirm your password';
                                              }
                                              if (value !=
                                                  _passwordController.text) {
                                                return 'Passwords do not match';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: AppSpacing.l),
                                          AnimatedPress(
                                            onPressed: authState.isLoading
                                                ? null
                                                : _signUp,
                                            child: Container(
                                              width: double.infinity,
                                              height: 54,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Color(0xFFFFC94D),
                                                    AppColors.secondary,
                                                    Color(0xFFE08E0B),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.secondary
                                                        .withValues(alpha: 0.4),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: authState.isLoading
                                                    ? const SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: Colors.black,
                                                          strokeWidth: 2.5,
                                                        ),
                                                      )
                                                    : const Text(
                                                        'CREATE ACCOUNT',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: 15,
                                                          letterSpacing: 1.6,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.l),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Already have an account?',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.5),
                                                  fontSize: 13,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    context.go('/login'),
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      AppColors.secondary,
                                                ),
                                                child: const Text(
                                                  'Sign In',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 13,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(flex: 2),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
