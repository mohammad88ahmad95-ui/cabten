import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// يعرض الباقات الصباحية والمسائية كل بقسم منفصل، مع زر حجز مباشر
/// لكل باقة ينقل السعر والفترة إلى تدفق الحجز مباشرة.
class VendorPricingWidget extends StatelessWidget {
  final List<Map<String, dynamic>> morningPackages;
  final List<Map<String, dynamic>> eveningPackages;
  final void Function(Map<String, dynamic> package, String slot) onPackageSelected;

  const VendorPricingWidget({
    Key? key,
    required this.morningPackages,
    required this.eveningPackages,
    required this.onPackageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('الباقات الصباحية', Icons.wb_sunny_outlined, const Color(0xFFF2A541)),
          SizedBox(height: 1.5.h),
          if (morningPackages.isEmpty) _empty() else ...morningPackages.map((p) => _packageCard(p, 'morning', const Color(0xFFF2A541))),
          SizedBox(height: 3.h),
          _sectionHeader('الباقات المسائية', Icons.nightlight_round, const Color(0xFF5E60CE)),
          SizedBox(height: 1.5.h),
          if (eveningPackages.isEmpty) _empty() else ...eveningPackages.map((p) => _packageCard(p, 'evening', const Color(0xFF5E60CE))),
          SizedBox(height: 3.h),
          _buildPricingNote(),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 2.w),
        Text(title, style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _empty() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('لا توجد باقات مضافة بعد', style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
      );

  Widget _packageCard(Map<String, dynamic> p, String slot, Color accent) {
    final price = ((p['price'] as num?) ?? 0).round();
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.3)),
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(p['name'] as String? ?? '', style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
              Text('${AppData.formatNumber(price)} ل.س',
                  style: AppTheme.getDataTextStyle(isLight: true, fontSize: 16, fontWeight: FontWeight.bold).copyWith(color: accent)),
            ],
          ),
          if ((p['details'] as String? ?? '').isNotEmpty) ...[
            SizedBox(height: 1.h),
            Text(p['details'] as String, style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary, height: 1.4)),
          ],
          SizedBox(height: 1.5.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => onPackageSelected(p, slot),
              style: OutlinedButton.styleFrom(side: BorderSide(color: accent)),
              child: Text('احجز هذه الباقة', style: TextStyle(color: accent)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingNote() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const CustomIconWidget(iconName: 'info', color: AppTheme.warning, size: 20),
          SizedBox(width: 3.w),
          Expanded(
            child: Text('يتطلب الحجز دفع عربون 25% لتأكيده؛ المبلغ المتبقي يُدفع مباشرة لمقدم الخدمة.',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: AppTheme.warning, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
