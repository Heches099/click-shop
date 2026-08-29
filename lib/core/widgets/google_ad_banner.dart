import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../config/design_tokens.dart';
import '../services/ads/ad_config.dart';
import '../services/ads/adsense_loader.dart';

/// Renders Google Ads.
/// - Web: Renders AdSense via [HtmlElementView].
/// - Mobile: Renders AdMob via [AdWidget].
class GoogleAdBanner extends StatefulWidget {
  final String slotId;
  final double height;

  const GoogleAdBanner({
    super.key,
    required this.slotId,
    this.height = 100,
  });

  @override
  State<GoogleAdBanner> createState() => _GoogleAdBannerState();
}

class _GoogleAdBannerState extends State<GoogleAdBanner> {
  // Web specific
  String? _viewType;
  bool _webStarted = false;

  // Mobile specific
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  bool get _shouldShow => AdConfig.enabled;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Handled in didChangeDependencies
    } else if (Platform.isAndroid || Platform.isIOS) {
      _loadMobileAd();
    }
  }

  void _loadMobileAd() {
    final adUnitId = Platform.isAndroid ? AdConfig.androidBannerId : AdConfig.iosBannerId;
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isAdLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Ad failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!kIsWeb || !_shouldShow || _webStarted) return;
    _webStarted = true;

    _viewType = registerAdSlot();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // loadAdSense() awaits `flutter-first-frame` internally, so third-party
      // ad code can never block or delay the primary render (LCP/INP safe).
      loadAdSense().then((_) {
        renderAdSlot(_viewType!, widget.slotId);
      });
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow) return const SizedBox.shrink();

    // Fixed explicit dimensions (CLS-safe): the box reserves its space before
    // the ad script loads, so a slow ad network can never shift the layout.
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: widget.height,
        maxHeight: widget.height,
      ),
      height: widget.height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: kIsWeb ? _buildWebView() : _buildMobileView(),
    );
  }

  Widget _buildWebView() {
    if (_viewType == null) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: HtmlElementView(viewType: _viewType!),
    );
  }

  Widget _buildMobileView() {
    if (!_isAdLoaded || _bannerAd == null) {
      return const Text('Loading Advertisement...', style: TextStyle(fontSize: 10, color: Colors.grey));
    }
    return AdWidget(ad: _bannerAd!);
  }
}
