import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// خطوة التأكيد: عند الضغط على "تأكيد الحجز" يُنشأ حجز حقيقي بالفترة
/// والباقة المختارتين، ويظهر فوراً في لوحة مقدم الخدمة.
class ConfirmationStep extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Map<String, dynamic> vendor;
  final double totalAmount;

  const ConfirmationStep({Key? key, required this.formData, required this.vendor, required this.totalAmount}) : super(key: key);

  @override
  State<ConfirmationStep> createState() => _ConfirmationStepState();
}

class _ConfirmationStepState extends State<ConfirmationStep> with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;
  bool showCelebration = false;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut));
  }

  double get depositAmount => widget.totalAmount * 0.25;
  double get remainingAmount => widget.totalAmount - depositAmount;

  Map<String, dynamic>? get _package => widget.formData['selectedPackage'] as Map<String, dynamic>?;
  String get _slot => (widget.formData['selectedSlot'] as String?) ?? 'morning';

  String get paymentMethodName {
    final id = widget.formData['selectedPaymentMethod'];
    final methods = AppData.instance.paymentMethods;
    final m = methods.firstWhere((m) => m['id'] == id, orElse: () => {'name': 'غير محدد'});
    return m['name'] as String? ?? 'غير محدد';
  }

  void _confirmBooking() {
    final date = widget.formData['selectedDate'] as DateTime?;
    final package = _package;
    if (date == null || package == null) return;

    AppData.instance.createBooking(
      vendorId: widget.vendor['id'] as String,
      clientName: (widget.formData['clientName'] as String?)?.trim().isNotEmpty == true ? widget.formData['clientName'] : 'عميل',
      clientPhone: (widget.formData['clientPhone'] as String?) ?? '',
      service: package['name'] as String? ?? '',
      eventDate: date,
      guestCount: (widget.formData['guestCount'] as int?) ?? 0,
      durationHours: _slot == 'morning' ? 4 : 6,
      totalAmount: widget.totalAmount,
      paymentMethodId: (widget.formData['selectedPaymentMethod'] as String?) ?? '',
      specialRequirements: (widget.formData['specialRequirements'] as String?) ?? '',
      slot: _slot,
    );

    setState(() => showCelebration = true);
    _celebrationController.forward();

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/booking-management');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showCelebration) return _buildCelebrationView();
    final package = _package;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ملخص الحجز', style: AppTheme.lightTheme.textTheme.headlineSmall),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppImage(
                        src: AppData.imagesOf(widget.vendor).isEmpty ? null : AppData.imagesOf(widget.vendor).first,
                        width: 15.w,
                        height: 15.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.vendor['name'] as String? ?? '', style: AppTheme.lightTheme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 0.5.h),
                          Text('${widget.vendor['city'] ?? ''}', style: AppTheme.lightTheme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Divider(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2)),
                SizedBox(height: 2.h),
                _row('الباقة', package?['name'] as String? ?? 'غير محدد'),
                SizedBox(height: 1.h),
                _row('الفترة', _slot == 'morning' ? 'صباحية' : 'مسائية'),
                SizedBox(height: 1.h),
                _row('الضيوف', '${widget.formData['guestCount']} شخص'),
                SizedBox(height: 1.h),
                _row('التاريخ', widget.formData['selectedDate'] != null
                    ? '${(widget.formData['selectedDate'] as DateTime).day}/${(widget.formData['selectedDate'] as DateTime).month}/${(widget.formData['selectedDate'] as DateTime).year}'
                    : 'غير محدد'),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تفاصيل الدفع', style: AppTheme.lightTheme.textTheme.titleMedium),
                SizedBox(height: 2.h),
                _row('طريقة الدفع', paymentMethodName),
                SizedBox(height: 1.h),
                _row('مبلغ العربون', '${AppData.formatNumber(depositAmount)} ل.س', highlighted: true),
                SizedBox(height: 1.h),
                _row('المبلغ المتبقي', '${AppData.formatNumber(remainingAmount)} ل.س'),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(onPressed: _confirmBooking, child: const Text('تأكيد الحجز')),
          ),
          SizedBox(height: 2.h),
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
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(fontWeight: highlighted ? FontWeight.w600 : FontWeight.w400, color: highlighted ? AppTheme.primary : null),
              textAlign: TextAlign.end, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildCelebrationView() {
    return SizedBox(
      width: double.infinity,
      height: 80.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _celebrationController,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 30.w,
                height: 30.w,
                decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle),
                child: const CustomIconWidget(iconName: 'check', color: Colors.white, size: 60),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text('تم تأكيد الحجز!', style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(color: AppTheme.success, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          SizedBox(height: 2.h),
          Text('تم إرسال طلبك بنجاح إلى مقدم الخدمة\nوسيتم التواصل معك قريباً.', style: AppTheme.lightTheme.textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }
}
