import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// بطاقة حجز لجهة العميل. لا يوجد فيها زر تواصل مع مقدم الخدمة.
class BookingCardWidget extends StatelessWidget {
  final Map<String, dynamic> booking;
  final Map<String, dynamic>? vendor;
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onCancelBooking;

  const BookingCardWidget({
    super.key,
    required this.booking,
    required this.vendor,
    this.isExpanded = false,
    this.onTap,
    this.onCancelBooking,
  });

  String _statusText(String status) {
    switch (status) {
      case 'confirmed': return 'مؤكد';
      case 'completed': return 'مكتمل';
      case 'cancelled': return 'ملغي';
      default: return 'قيد المراجعة';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed': return AppTheme.success;
      case 'completed': return AppTheme.primary;
      case 'cancelled': return AppTheme.error;
      default: return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = booking['status'] as String? ?? 'pending';
    final vendorName = vendor?['name'] as String? ?? 'مقدم خدمة';
    final service = booking['service'] as String? ?? '';
    final date = booking['eventDate'] as String? ?? '';
    final total = ((booking['totalAmount'] as num?) ?? 0).toDouble();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(vendorName, style: AppTheme.lightTheme.textTheme.titleMedium, overflow: TextOverflow.ellipsis)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    decoration: BoxDecoration(color: _statusColor(status), borderRadius: BorderRadius.circular(20)),
                    child: Text(_statusText(status), style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(color: Colors.white)),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(children: [
                const CustomIconWidget(iconName: 'category', color: AppTheme.textSecondary, size: 16),
                SizedBox(width: 2.w),
                Expanded(child: Text(service, style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary))),
              ]),
              SizedBox(height: 0.5.h),
              Row(children: [
                const CustomIconWidget(iconName: 'event', color: AppTheme.textSecondary, size: 16),
                SizedBox(width: 2.w),
                Text(date, style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
              ]),
              SizedBox(height: 1.h),
              Row(children: [
                const CustomIconWidget(iconName: 'attach_money', color: AppTheme.primary, size: 16),
                SizedBox(width: 2.w),
                Text('${AppData.formatNumber(total)} ل.س', style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(color: AppTheme.primary)),
              ]),
              if (isExpanded) ...[
                SizedBox(height: 2.h),
                Divider(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2)),
                SizedBox(height: 1.h),
                _detail('عدد الضيوف', '${booking['guestCount'] ?? 0}'),
                _detail('المدة', '${booking['durationHours'] ?? 0} ساعات'),
                if ((booking['specialRequirements'] as String? ?? '').isNotEmpty)
                  _detail('متطلبات خاصة', booking['specialRequirements'] as String),
                if (onCancelBooking != null) ...[
                  SizedBox(height: 1.h),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: OutlinedButton.icon(
                      onPressed: onCancelBooking,
                      icon: const Icon(Icons.cancel_outlined, size: 18, color: AppTheme.error),
                      label: const Text('إلغاء الحجز', style: TextStyle(color: AppTheme.error)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.error)),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
        padding: EdgeInsets.only(bottom: 0.8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 26.w, child: Text(label, style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary))),
            Expanded(child: Text(value, style: AppTheme.lightTheme.textTheme.bodySmall)),
          ],
        ),
      );
}
