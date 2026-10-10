import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BookingCardWidget extends StatelessWidget {
  final Map<String, dynamic> booking;
  final Map<String, dynamic>? vendor;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onViewDetails;
  final VoidCallback? onTap;

  const BookingCardWidget({
    Key? key,
    required this.booking,
    required this.vendor,
    this.onAccept,
    this.onDecline,
    this.onViewDetails,
    this.onTap,
  }) : super(key: key);

  String _statusText(String s) {
    switch (s) {
      case 'confirmed': return 'مؤكد';
      case 'completed': return 'مكتمل';
      case 'cancelled': return 'ملغي';
      default: return 'قيد المراجعة';
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed': return AppTheme.success;
      case 'completed': return AppTheme.primary;
      case 'cancelled': return AppTheme.error;
      default: return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = booking['status'] as String? ?? 'pending';
    final isPending = status == 'pending';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(booking['id']),
        startActionPane: isPending
            ? ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(onPressed: (_) => onAccept?.call(), backgroundColor: AppTheme.success, foregroundColor: Colors.white, icon: Icons.check, label: 'قبول'),
                  SlidableAction(onPressed: (_) => onDecline?.call(), backgroundColor: AppTheme.error, foregroundColor: Colors.white, icon: Icons.close, label: 'رفض'),
                ],
              )
            : null,
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(onPressed: (_) => onViewDetails?.call(), backgroundColor: AppTheme.primary, foregroundColor: Colors.white, icon: Icons.visibility, label: 'التفاصيل'),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(booking['clientName'] as String? ?? 'عميل', style: AppTheme.lightTheme.textTheme.titleMedium, overflow: TextOverflow.ellipsis)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                        decoration: BoxDecoration(color: _statusColor(status), borderRadius: BorderRadius.circular(20)),
                        child: Text(_statusText(status), style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(children: [
                    const CustomIconWidget(iconName: 'storefront', color: AppTheme.textSecondary, size: 16),
                    SizedBox(width: 2.w),
                    Expanded(child: Text(vendor?['name'] as String? ?? 'مقدم خدمة', style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary), overflow: TextOverflow.ellipsis)),
                  ]),
                  SizedBox(height: 0.5.h),
                  Row(children: [
                    const CustomIconWidget(iconName: 'calendar_today', color: AppTheme.textSecondary, size: 16),
                    SizedBox(width: 2.w),
                    Text(booking['eventDate'] as String? ?? '', style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                  ]),
                  SizedBox(height: 0.5.h),
                  Row(children: [
                    const CustomIconWidget(iconName: 'people', color: AppTheme.textSecondary, size: 16),
                    SizedBox(width: 2.w),
                    Text('${booking['guestCount'] ?? 0} ضيف', style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                    const Spacer(),
                    Text('${AppData.formatNumber(((booking['totalAmount'] as num?) ?? 0).toDouble())} ل.س',
                        style: AppTheme.getDataTextStyle(isLight: true, fontSize: 14, fontWeight: FontWeight.w600).copyWith(color: AppTheme.primary)),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
