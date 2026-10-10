import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// رأس صفحة تفاصيل مقدم الخدمة: سلايد صور كامل العرض بدل صورة ثابتة.
class VendorHeaderWidget extends StatefulWidget {
  final Map<String, dynamic> vendorData;
  final VoidCallback onBackPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onFavoritePressed;
  final bool isFavorite;

  const VendorHeaderWidget({
    Key? key,
    required this.vendorData,
    required this.onBackPressed,
    required this.onSharePressed,
    required this.onFavoritePressed,
    required this.isFavorite,
  }) : super(key: key);

  @override
  State<VendorHeaderWidget> createState() => _VendorHeaderWidgetState();
}

class _VendorHeaderWidgetState extends State<VendorHeaderWidget> {
  final PageController _pc = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = ((widget.vendorData["images"] as List?) ?? const []).cast<String>();
    final slides = images.isEmpty ? [null] : images;

    return SizedBox(
      height: 35.h,
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pc,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: slides.length,
              itemBuilder: (context, i) => AppImage(src: slides[i], width: double.infinity, height: double.infinity),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.25), Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            ),
          ),
          if (slides.length > 1)
            Positioned(
              bottom: 13.h,
              right: 0,
              left: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _index == i ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _index == i ? Colors.white : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 6.h,
            right: 4.w,
            left: 4.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _roundBtn('arrow_forward', widget.onBackPressed),
                Row(
                  children: [
                    _roundBtn('share', widget.onSharePressed),
                    SizedBox(width: 3.w),
                    _roundBtn(widget.isFavorite ? 'favorite' : 'favorite_border', widget.onFavoritePressed,
                        color: widget.isFavorite ? AppTheme.error : Colors.white),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 2.h,
            right: 4.w,
            left: 4.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.vendorData["name"] as String? ?? "اسم مقدم الخدمة",
                        style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.vendorData["isVerified"] == true) ...[
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(color: AppTheme.success, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CustomIconWidget(iconName: 'verified', color: Colors.white, size: 12),
                            SizedBox(width: 1.w),
                            Text("موثق", style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    const CustomIconWidget(iconName: 'star', color: AppTheme.warning, size: 16),
                    SizedBox(width: 1.w),
                    Text("${widget.vendorData["rating"] ?? 4.5}",
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                    SizedBox(width: 1.w),
                    Text("(${widget.vendorData["reviewCount"] ?? 0} تقييم)",
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.8))),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
                      child: Text(widget.vendorData["category"] as String? ?? "",
                          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundBtn(String icon, VoidCallback onTap, {Color color = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(20)),
        child: Center(child: CustomIconWidget(iconName: icon, color: color, size: 20)),
      ),
    );
  }
}
