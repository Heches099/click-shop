import 'package:flutter/widgets.dart';

/// Layout helpers that adapt UI sizes and grids to the available screen size.
class AppResponsive {
  AppResponsive._();

  /// Reference width the design was created against (390pt = standard phone).
  static const double _designWidth = 390;

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static bool isCompact(BuildContext context) => width(context) < 600;

  static bool isTablet(BuildContext context) =>
      width(context) >= 600 && width(context) < 1024;

  static bool isDesktop(BuildContext context) => width(context) >= 1024;

  static bool isLandscape(BuildContext context) =>
      width(context) > height(context);

  /// Scales a length relative to the design width, clamped to a sane range so
  /// small screens never overflow and large screens never blow out.
  static double scale(BuildContext context, double size) {
    final factor = (width(context) / _designWidth).clamp(0.8, 1.4);
    return size * factor;
  }

  /// Number of columns a grid should show given the current width.
  static int gridColumns(BuildContext context, {double minItemWidth = 160}) {
    final columns = (width(context) / minItemWidth).floor();
    return columns.clamp(1, 6).toInt();
  }

  /// Aspect ratio that keeps product cards a consistent height on any screen.
  static double productCardRatio(BuildContext context) {
    return gridColumns(context, minItemWidth: 150) <= 2 ? 0.6 : 0.75;
  }

  /// Adaptive height for the home banner carousel.
  static double bannerHeight(BuildContext context) =>
      (width(context) * 0.42).clamp(150, 260).toDouble();

  /// Adaptive height for the product detail image carousel.
  static double detailImageHeight(BuildContext context) =>
      (width(context) * 1.05).clamp(320, 480).toDouble();

  /// Adaptive thumbnail size for cart/product rows.
  static double thumbnailSize(BuildContext context) =>
      (width(context) * 0.24).clamp(64, 110).toDouble();
}
