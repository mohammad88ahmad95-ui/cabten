import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BookingFilterTabsWidget extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final List<Map<String, dynamic>> bookingCounts;

  const BookingFilterTabsWidget({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.bookingCounts,
  }) : super(key: key);

  int _count(String key) {
    final item = bookingCounts.firstWhere((e) => e['filter'] == key, orElse: () => {'count': 0});
    return item['count'] as int? ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'new', 'label': 'جديدة'},
      {'key': 'confirmed', 'label': 'مؤكدة'},
      {'key': 'today', 'label': 'اليوم'},
      {'key': 'history', 'label': 'السجل'},
    ];

    return SizedBox(
      height: 6.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final f = filters[index];
          final key = f['key'] as String;
          final selected = selectedFilter == key;
          final count = _count(key);
          return GestureDetector(
            onTap: () => onFilterChanged(key),
            child: Container(
              margin: EdgeInsets.only(left: 3.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: selected ? AppTheme.primary : AppTheme.lightTheme.colorScheme.outline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(f['label'] as String,
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(color: selected ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                  if (count > 0) ...[
                    SizedBox(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
                      decoration: BoxDecoration(color: selected ? Colors.white.withOpacity(0.25) : AppTheme.primary, borderRadius: BorderRadius.circular(10)),
                      child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
