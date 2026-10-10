import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyBookingsWidget extends StatelessWidget {
  final String tabType;
  final VoidCallback? onCreateBooking;

  const EmptyBookingsWidget({super.key, required this.tabType, this.onCreateBooking});

  String get _title {
    switch (tabType) {
      case 'upcoming': return 'لا توجد حجوزات قادمة';
      case 'past': return 'لا توجد حجوزات سابقة';
      case 'cancelled': return 'لا توجد حجوزات ملغية';
      default: return 'لا توجد حجوزات';
    }
  }

  String get _desc {
    switch (tabType) {
      case 'upcoming': return 'ابدأ بتصفح مقدمي الخدمة واحجز ما تحتاجه لمناسبتك';
      case 'past': return 'ستظهر هنا الحجوزات المكتملة';
      case 'cancelled': return 'ستظهر هنا الحجوزات التي تم إلغاؤها';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomIconWidget(iconName: 'event_note', color: AppTheme.primaryLight, size: 60),
            SizedBox(height: 3.h),
            Text(_title, style: AppTheme.lightTheme.textTheme.titleMedium, textAlign: TextAlign.center),
            SizedBox(height: 1.h),
            Text(_desc, style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary), textAlign: TextAlign.center),
            if (tabType == 'upcoming' && onCreateBooking != null) ...[
              SizedBox(height: 3.h),
              ElevatedButton.icon(onPressed: onCreateBooking, icon: const Icon(Icons.add), label: const Text('تصفح مقدمي الخدمة')),
            ],
          ],
        ),
      ),
    );
  }
}
