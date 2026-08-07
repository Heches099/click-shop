import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SmartImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final Alignment alignment;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SmartImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (imagePath.startsWith('http')) {
      image = CachedNetworkImage(
        imageUrl: imagePath,
        fit: fit,
        alignment: alignment,
        width: width,
        height: height,
        placeholder: (context, url) =>
            placeholder ??
            Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        errorWidget: (context, url, error) =>
            errorWidget ??
            Container(
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
      );
    } else {
      image = Image.asset(
        imagePath,
        fit: fit,
        alignment: alignment,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            Container(
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}
