import 'dart:io';

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";

import "../theme/app_theme.dart";

/// يعرض صورة من رابط (http) أو من ملف محلي (اختارها مقدم الخدمة من المعرض).
class AppImage extends StatelessWidget {
  final String? src;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppImage({
    super.key,
    required this.src,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  Widget _placeholder() => Container(
        width: width,
        height: height,
        color: AppTheme.accent,
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined,
            color: AppTheme.primaryLight, size: 32),
      );

  @override
  Widget build(BuildContext context) {
    final s = src;
    if (s == null || s.isEmpty) return _placeholder();

    if (s.startsWith("http")) {
      return CachedNetworkImage(
        imageUrl: s,
        width: width,
        height: height,
        fit: fit,
        placeholder: (c, u) => Container(
          width: width,
          height: height,
          color: AppTheme.secondary,
          child: const Center(
              child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2))),
        ),
        errorWidget: (c, u, e) => _placeholder(),
      );
    }

    return Image.file(
      File(s),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (c, e, st) => _placeholder(),
    );
  }
}
