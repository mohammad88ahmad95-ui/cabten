import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BookingSummarySheet extends StatelessWidget {
  final Map<String, dynamic> formData;
  final Map<String, dynamic> vendor;
  final double totalAmount;

  const BookingSummarySheet({Key? key, required this.formData, required this.vendor, required this.totalAmount}) : super(key: key);

  double get depositAmount => totalAmount * 0.25;
  double get remainingAmount => totalAmount - depositAmount;

  @override
  Widget build(BuildContext context) {
    final images = AppData.imagesOf(vendor);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [BoxShadow(color: AppTheme.shadowLight, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 1.h),
            decoration: BoxDecoration(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ملخص الحجز', style: AppTheme.lightTheme.textTheme.titleLarge),
                    GestureDetector(onTap: () => Navigator.pop(context), child: const CustomIconWidget(iconName: 'close', color: AppTheme.textSecondary, size: 24)),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: AppImage(src: images.isEmpty ? null : images.first, width: 12.w, height: 12.w)),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vendor['name'] as String? ?? '', style: AppTheme.lightTheme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 0.5.h),
                          Text('${vendor['city'] ?? ''}', style: AppTheme.lightTheme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Divider(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2)),
                SizedBox(height: 2.h),
                if (formData['selectedPackage'] != null)
                  _row('الباقة', (formData['selectedPackage'] as Map)['name'] as String? ?? ''),
                if (formData['selectedSlot'] != null) ...[
                  SizedBox(height: 1.h),
                  _row('الفترة', formData['selectedSlot'] == 'morning' ? 'صباحية' : 'مسائية'),
                ],
                if (formData['guestCount'] != null) ...[SizedBox(height: 1.h), _row('الضيوف', '${formData['guestCount']} شخص')],
                if (formData['selectedDate'] != null) ...[
                  SizedBox(height: 1.h),
                  _row('التاريخ', '${(formData['selectedDate'] as DateTime).day}/${(formData['selectedDate'] as DateTime).month}/${(formData['selectedDate'] as DateTime).year}'),
                ],
                SizedBox(height: 2.h),
                Divider(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2)),
                SizedBox(height: 2.h),
                Text('تفاصيل التكلفة', style: AppTheme.lightTheme.textTheme.titleSmall),
                SizedBox(height: 1.h),
                _row('المبلغ الإجمالي', '${AppData.formatNumber(totalAmount)} ل.س'),
                SizedBox(height: 1.h),
                _row('العربون (25%)', '${AppData.formatNumber(depositAmount)} ل.س', highlighted: true),
                SizedBox(height: 1.h),
                _row('المتبقي', '${AppData.formatNumber(remainingAmount)} ل.س'),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool highlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
        Flexible(
          child: Text(value,
              style: AppTheme.getDataTextStyle(isLight: true, fontSize: 14, fontWeight: highlighted ? FontWeight.w600 : FontWeight.w400)
                  .copyWith(color: highlighted ? AppTheme.primary : null),
              textAlign: TextAlign.end, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
