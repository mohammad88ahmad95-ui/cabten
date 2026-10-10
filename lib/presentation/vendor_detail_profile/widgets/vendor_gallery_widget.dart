import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VendorGalleryWidget extends StatefulWidget {
  final List<String> images;
  const VendorGalleryWidget({Key? key, required this.images}) : super(key: key);

  @override
  State<VendorGalleryWidget> createState() => _VendorGalleryWidgetState();
}

class _VendorGalleryWidgetState extends State<VendorGalleryWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("معرض الصور",
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 2.h),
          SizedBox(
            height: 25.h,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _showFullScreenImage(context, index),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 1.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AppImage(src: widget.images[index], width: double.infinity, height: double.infinity),
                        ),
                      ),
                    );
                  },
                ),
                if (widget.images.length > 1) ...[
                  Positioned(
                    bottom: 2.h,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.images.length,
                        (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 1.w),
                          width: _currentIndex == index ? 8.w : 2.w,
                          height: 1.h,
                          decoration: BoxDecoration(
                            color: _currentIndex == index ? AppTheme.primary : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2.h,
                    right: 4.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                      child: Text("${_currentIndex + 1} / ${widget.images.length}",
                          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.images.length > 3) ...[
            SizedBox(height: 2.h),
            SizedBox(
              height: 12.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                    child: Container(
                      width: 20.w,
                      margin: EdgeInsets.only(left: 2.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _currentIndex == index ? AppTheme.primary : Colors.transparent, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AppImage(src: widget.images[index], width: double.infinity, height: double.infinity),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, int initialIndex) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => _FullScreenGallery(images: widget.images, initialIndex: initialIndex),
    ));
  }
}

class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const _FullScreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: widget.images.length,
            itemBuilder: (context, index) => InteractiveViewer(
              child: Center(child: AppImage(src: widget.images[index], fit: BoxFit.contain)),
            ),
          ),
          Positioned(
            top: 6.h,
            right: 4.w,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
                child: const Center(child: CustomIconWidget(iconName: 'close', color: Colors.white, size: 20)),
              ),
            ),
          ),
          Positioned(
            top: 6.h,
            left: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
              child: Text("${_currentIndex + 1} / ${widget.images.length}",
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}
