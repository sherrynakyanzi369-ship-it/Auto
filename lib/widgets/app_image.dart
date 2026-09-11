import 'package:flutter/material.dart';

import 'shimmer.dart';

class AppImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? radius;
  final IconData fallbackIcon;

  const AppImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius,
    this.fallbackIcon = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(16),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.network(
          url,
          fit: fit,
          gaplessPlayback: true,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return ShimmerBox(width: width, height: height, radius: radius);
          },
          errorBuilder: (context, error, stack) => Container(
            width: width,
            height: height,
            color: const Color(0xFFE9EDF5),
            child: Center(
              child: Icon(
                fallbackIcon,
                size: 32,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}