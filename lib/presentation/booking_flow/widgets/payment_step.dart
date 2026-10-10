import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// خطوة الدفع: تعرض طرق الدفع المُفعَّلة فقط من لوحة مقدم الخدمة
/// (MTN كاش، سيرياتيل كاش، شام كاش، دفع بنكي، الدفع عند التسليم).
class PaymentStep extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic> formData;
  final double totalAmount;

  const PaymentStep({Key? key, required this.onDataChanged, required this.formData, required this.totalAmount}) : super(key: key);

  @override
  State<PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<PaymentStep> {
  String? selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    selectedPaymentMethod = widget.formData['selectedPaymentMethod'];
  }

  void _update() {
    widget.onDataChanged({...widget.formData, 'selectedPaymentMethod': selectedPaymentMethod});
  }

  double get depositAmount => widget.totalAmount * 0.25;
  double get remainingAmount => widget.totalAmount - depositAmount;

  double get processingFee {
    if (selectedPaymentMethod == null) return 0.0;
    final methods = AppData.instance.enabledPaymentMethods;
    final method = methods.firstWhere((m) => m['id'] == selectedPaymentMethod, orElse: () => {'fee': 0.0});
    return ((method['fee'] as num?) ?? 0.0) / 100 * depositAmount;
  }

  @override
  Widget build(BuildContext context) {
    final methods = AppData.instance.enabledPaymentMethods;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                Text('ملخص الدفع', style: AppTheme.lightTheme.textTheme.titleMedium),
                SizedBox(height: 2.h),
                _row('المبلغ الإجمالي', '${AppData.formatNumber(widget.totalAmount)} ل.س'),
                SizedBox(height: 1.h),
                _row('العربون (25%)', '${AppData.formatNumber(depositAmount)} ل.س', highlighted: true),
                if (processingFee > 0) ...[
                  SizedBox(height: 1.h),
                  _row('رسوم المعالجة', '${AppData.formatNumber(processingFee)} ل.س'),
                ],
                SizedBox(height: 1.h),
                _row('المبلغ المتبقي', '${AppData.formatNumber(remainingAmount)} ل.س'),
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const CustomIconWidget(iconName: 'info', color: AppTheme.primary, size: 16),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text('يُدفع المبلغ المتبقي مباشرة لمقدم الخدمة عند الحدث',
                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: AppTheme.primary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          Text('طريقة الدفع', style: AppTheme.lightTheme.textTheme.titleMedium),
          SizedBox(height: 1.h),
          if (methods.isEmpty)
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text('لا توجد طرق دفع مفعّلة حالياً، الرجاء التواصل لاحقاً',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.warning)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: methods.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final method = methods[index];
                final isSelected = selectedPaymentMethod == method['id'];
                final fee = (method['fee'] as num?) ?? 0;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedPaymentMethod = method['id'] as String);
                    _update();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.1) : AppTheme.lightTheme.colorScheme.surface,
                      border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3), width: isSelected ? 2 : 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary : AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(iconName: method['icon'] as String? ?? 'payment', color: isSelected ? Colors.white : AppTheme.textSecondary, size: 24),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(method['name'] as String? ?? '',
                                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(color: isSelected ? AppTheme.primary : null)),
                                  if (fee > 0) Text('$fee% رسوم', style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: AppTheme.warning)),
                                ],
                              ),
                              SizedBox(height: 0.5.h),
                              Text(method['description'] as String? ?? '', style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                        if (isSelected) const CustomIconWidget(iconName: 'check_circle', color: AppTheme.primary, size: 20),
                      ],
                    ),
                  ),
                );
              },
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
        Text(label,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: highlighted ? FontWeight.w600 : FontWeight.w400,
              color: highlighted ? AppTheme.primary : null,
            )),
        Text(value,
            style: AppTheme.getDataTextStyle(isLight: true, fontSize: 14, fontWeight: highlighted ? FontWeight.w600 : FontWeight.w400)
                .copyWith(color: highlighted ? AppTheme.primary : null)),
      ],
    );
  }
}
