import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyBookingsWidget extends StatelessWidget {
  final String filterType;
  const EmptyBookingsWidget({Key? key, required this.filterType}) : super(key: key);

  String get _title {
    switch (filterType) {
      case 'new': return 'لا توجد طلبات جديدة';
      case 'confirmed': return 'لا توجد حجوزات مؤكدة';
      case 'today': return 'لا توجد فعاليات اليوم';
      case 'history': return 'لا يوجد سجل بعد';
      default: return 'لا توجد حجوزات';
    }
  }

  String get _desc {
    switch (filterType) {
      case 'new': return 'ستظهر هنا طلبات الحجز الجديدة من العملاء فور وصولها.';
      case 'confirmed': return 'الحجوزات التي تقبلها ستظهر هنا.';
      case 'today': return 'تحقق لاحقاً عندما تكون لديك فعاليات مجدولة اليوم.';
      case 'history': return 'الحجوزات المكتملة أو الملغية ستُحفظ هنا.';
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
            const CustomIconWidget(iconName: 'inbox', color: AppTheme.textSecondary, size: 48),
            SizedBox(height: 3.h),
            Text(_title, style: AppTheme.lightTheme.textTheme.titleMedium, textAlign: TextAlign.center),
            SizedBox(height: 1.h),
            Text(_desc, style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
