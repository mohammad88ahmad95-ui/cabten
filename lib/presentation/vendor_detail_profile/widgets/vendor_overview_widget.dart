import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VendorOverviewWidget extends StatelessWidget {
  final Map<String, dynamic> vendorData;
  const VendorOverviewWidget({Key? key, required this.vendorData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vendorData["description"] != null) ...[
            Text("نبذة عن الخدمة", style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            Text(vendorData["description"] as String, style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(height: 1.6)),
            SizedBox(height: 3.h),
          ],
          if (vendorData["amenities"] != null && (vendorData["amenities"] as List).isNotEmpty) ...[
            Text("الخدمات المقدّمة", style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 2.h),
            _buildAmenitiesGrid(),
            SizedBox(height: 3.h),
          ],
          Text("الموقع", style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 1.h),
          _buildLocationCard(),
          SizedBox(height: 3.h),
          Text("ساعات العمل", style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 1.h),
          _buildWorkingHours(),
        ],
      ),
    );
  }

  Widget _buildAmenitiesGrid() {
    final amenities = vendorData["amenities"] as List;
    if (amenities.isEmpty) {
      return Text("لم تتم إضافة خدمات بعد", style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.2, crossAxisSpacing: 3.w, mainAxisSpacing: 2.h),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        final amenity = amenities[index] as Map<String, dynamic>;
        return Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.lightTheme.dividerColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(iconName: amenity["icon"] as String? ?? 'check_circle', color: AppTheme.primary, size: 24),
              SizedBox(height: 1.h),
              Text(amenity["name"] as String? ?? "", style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightTheme.dividerColor),
      ),
      child: Row(
        children: [
          const CustomIconWidget(iconName: 'location_on', color: AppTheme.primary, size: 20),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(vendorData["address"] as String? ?? "سوريا",
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHours() {
    final wh = vendorData["workingHours"] as Map<String, dynamic>? ?? {};
    const days = [
      ['sunday', 'الأحد'], ['monday', 'الاثنين'], ['tuesday', 'الثلاثاء'],
      ['wednesday', 'الأربعاء'], ['thursday', 'الخميس'], ['friday', 'الجمعة'], ['saturday', 'السبت'],
    ];
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightTheme.dividerColor),
      ),
      child: Column(
        children: [
          for (var i = 0; i < days.length; i++)
            Column(children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(days[i][1], style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                    Text(wh[days[i][0]] as String? ?? "9:00 ص - 11:00 م",
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              if (i != days.length - 1) Divider(color: AppTheme.lightTheme.dividerColor, height: 1),
            ]),
        ],
      ),
    );
  }
}
