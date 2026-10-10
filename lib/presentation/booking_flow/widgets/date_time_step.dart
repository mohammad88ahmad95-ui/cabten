import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/app_export.dart';

/// خطوة اختيار التاريخ: الفترة (صباحية/مسائية) محدَّدة مسبقاً من الباقة
/// المختارة، فنعرض فقط الأيام التي تتوفر فيها تلك الفترة تحديداً.
class DateTimeStep extends StatefulWidget {
  final Map<String, dynamic> vendor;
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic> formData;

  const DateTimeStep({Key? key, required this.vendor, required this.onDataChanged, required this.formData}) : super(key: key);

  @override
  State<DateTimeStep> createState() => _DateTimeStepState();
}

class _DateTimeStepState extends State<DateTimeStep> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.formData['selectedDate'];
  }

  void _update() {
    widget.onDataChanged({...widget.formData, 'selectedDate': selectedDate});
  }

  String get _slot => (widget.formData['selectedSlot'] as String?) ?? 'morning';

  @override
  Widget build(BuildContext context) {
    final slotLabel = _slot == 'morning' ? 'الصباحية' : 'المسائية';
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(_slot == 'morning' ? Icons.wb_sunny_outlined : Icons.nightlight_round, color: AppTheme.primary, size: 18),
                SizedBox(width: 2.w),
                Text('اختر تاريخاً متوفراً للفترة $slotLabel', style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: AppTheme.primary)),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2)),
            ),
            child: TableCalendar<DateTime>(
              locale: 'ar',
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: selectedDate ?? DateTime.now(),
              startingDayOfWeek: StartingDayOfWeek.saturday,
              selectedDayPredicate: (day) => selectedDate != null && isSameDay(selectedDate!, day),
              enabledDayPredicate: (day) =>
                  day.isAfter(DateTime.now().subtract(const Duration(days: 1))) && AppData.isSlotAvailable(widget.vendor, day, _slot),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppTheme.lightTheme.textTheme.titleMedium!,
                leftChevronIcon: const CustomIconWidget(iconName: 'chevron_left', color: AppTheme.primary, size: 24),
                rightChevronIcon: const CustomIconWidget(iconName: 'chevron_right', color: AppTheme.primary, size: 24),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                selectedDecoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.3), shape: BoxShape.circle),
                disabledDecoration: BoxDecoration(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.1), shape: BoxShape.circle),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (AppData.isSlotAvailable(widget.vendor, selectedDay, _slot)) {
                  setState(() => selectedDate = selectedDay);
                  _update();
                }
              },
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
