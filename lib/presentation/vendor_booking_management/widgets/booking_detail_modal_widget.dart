import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// نافذة تفاصيل الحجز لمقدم الخدمة: بيانات العميل، تفاصيل الحدث، والدفع،
/// مع أزرار القبول / الرفض / إنهاء الحجز حسب حالته الحالية.
class BookingDetailModalWidget extends StatelessWidget {
  final Map<String, dynamic> booking;
  final Map<String, dynamic>? vendor;
  final VoidCallback? onConfirm;
  final VoidCallback? onDecline;
  final VoidCallback? onMarkComplete;

  const BookingDetailModalWidget({
    Key? key,
    required this.booking,
    required this.vendor,
    this.onConfirm,
    this.onDecline,
    this.onMarkComplete,
  }) : super(key: key);

  String _paymentName(String? id) {
    final m = AppData.instance.paymentMethods.firstWhere((m) => m['id'] == id, orElse: () => {'name': 'غير محدد'});
    return m['name'] as String? ?? 'غير محدد';
  }

  @override
  Widget build(BuildContext context) {
    final status = booking['status'] as String? ?? 'pending';
    final total = ((booking['totalAmount'] as num?) ?? 0).toDouble();
    final deposit = total * 0.25;

    return Container(
      height: 82.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(color: AppTheme.textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('تفاصيل الحجز', style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                GestureDetector(onTap: () => Navigator.pop(context), child: const CustomIconWidget(iconName: 'close', color: AppTheme.textSecondary, size: 24)),
              ],
            ),
          ),
          Divider(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2)),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section('بيانات العميل', [
                    _row('الاسم', booking['clientName'] as String? ?? ''),
                    _row('الهاتف', booking['clientPhone'] as String? ?? 'غير مسجل', ltr: true),
                  ]),
                  SizedBox(height: 3.h),
                  _section('تفاصيل الحدث', [
                    _row('مقدم الخدمة', vendor?['name'] as String? ?? ''),
                    _row('الخدمة', booking['service'] as String? ?? ''),
                    _row('التاريخ', booking['eventDate'] as String? ?? ''),
                    _row('عدد الضيوف', '${booking['guestCount'] ?? 0}'),
                    _row('المدة', '${booking['durationHours'] ?? 0} ساعات'),
                  ]),
                  if ((booking['specialRequirements'] as String? ?? '').isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    _section('متطلبات خاصة', [Text(booking['specialRequirements'] as String, style: AppTheme.lightTheme.textTheme.bodyMedium)]),
                  ],
                  SizedBox(height: 3.h),
                  _section('الدفع', [
                    _row('طريقة الدفع', _paymentName(booking['paymentMethodId'] as String?)),
                    _row('العربون', '${AppData.formatNumber(deposit)} ل.س'),
                    _row('الإجمالي', '${AppData.formatNumber(total)} ل.س'),
                  ]),
                  SizedBox(height: 3.h),
                  if (status == 'pending' && onConfirm != null)
                    _actionButton('قبول الحجز', Icons.check_circle, AppTheme.success, onConfirm!),
                  if (status == 'confirmed' && onMarkComplete != null)
                    _actionButton('إنهاء الحجز', Icons.done_all, AppTheme.primary, onMarkComplete!),
                  if ((status == 'pending' || status == 'confirmed') && onDecline != null) ...[
                    SizedBox(height: 1.5.h),
                    _actionButton(status == 'pending' ? 'رفض الحجز' : 'إلغاء الحجز', Icons.close, AppTheme.error, onDecline!),
                  ],
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(color: AppTheme.lightTheme.colorScheme.surface, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 1.5.h),
            ...children,
          ],
        ),
      );

  Widget _row(String label, String value, {bool ltr = false}) => Padding(
        padding: EdgeInsets.only(bottom: 1.h),
        child: Row(
          children: [
            SizedBox(width: 28.w, child: Text(label, style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary))),
            Expanded(
              child: Text(value,
                  textDirection: ltr ? TextDirection.ltr : null,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );

  Widget _actionButton(String text, IconData icon, Color color, VoidCallback onTap) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 20),
          label: Text(text),
          style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 1.8.h)),
        ),
      );
}
