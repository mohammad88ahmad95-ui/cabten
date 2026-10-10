import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VendorStickyBottomBarWidget extends StatelessWidget {
  final VoidCallback onBookServicePressed;
  final VoidCallback onRequestQuotePressed;
  final String? startingPrice;
  final bool isLoading;

  const VendorStickyBottomBarWidget({
    Key? key,
    required this.onBookServicePressed,
    required this.onRequestQuotePressed,
    this.startingPrice,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              if (startingPrice != null) ...[
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("يبدأ من", style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary)),
                      SizedBox(height: 0.5.h),
                      Text("$startingPrice ل.س",
                          style: AppTheme.getDataTextStyle(isLight: true, fontSize: 16, fontWeight: FontWeight.bold).copyWith(color: AppTheme.primary)),
                    ],
                  ),
                ),
                SizedBox(width: 3.w),
              ],
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: isLoading ? null : onRequestQuotePressed,
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 1.5.h), side: const BorderSide(color: AppTheme.primary, width: 1.5)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomIconWidget(iconName: 'request_quote', color: AppTheme.primary, size: 18),
                      SizedBox(width: 1.w),
                      Text("عرض سعر", style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onBookServicePressed,
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 1.5.h), elevation: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomIconWidget(iconName: 'event_available', color: Colors.white, size: 18),
                      SizedBox(width: 1.w),
                      Text("احجز الخدمة", style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
