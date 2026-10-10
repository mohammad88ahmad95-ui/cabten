import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/app_export.dart';

/// تقويم توفر مقدم الخدمة بأربع حالات: متاح، محجوز صباحاً، محجوز مساءً،
/// ومحجوز بالكامل. لون جديد مخصص لكل حالة.
class VendorAvailabilityWidget extends StatefulWidget {
  final Map<String, dynamic> vendor;
  final void Function(DateTime day, String slot) onSlotSelected;

  const VendorAvailabilityWidget({Key? key, required this.vendor, required this.onSlotSelected}) : super(key: key);

  @override
  State<VendorAvailabilityWidget> createState() => _VendorAvailabilityWidgetState();
}

class _VendorAvailabilityWidgetState extends State<VendorAvailabilityWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // ألوان حالات التوفر الأربع
  static const Color _available = AppTheme.success;
  static const Color _morningBooked = Color(0xFFF2A541); // كهرماني: محجوز صباحاً
  static const Color _eveningBooked = Color(0xFF5E60CE); // بنفسجي مزرق: محجوز مساءً
  static const Color _full = AppTheme.error;

  Color _colorFor(String status) {
    switch (status) {
      case 'morning_booked':
        return _morningBooked;
      case 'evening_booked':
        return _eveningBooked;
      case 'full':
        return _full;
      default:
        return _available;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("التوفر والحجز", style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 2.h),
          _buildLegend(),
          SizedBox(height: 2.h),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.lightTheme.dividerColor),
            ),
            child: TableCalendar<DateTime>(
              locale: 'ar',
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              startingDayOfWeek: StartingDayOfWeek.saturday,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppTheme.lightTheme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                leftChevronIcon: const CustomIconWidget(iconName: 'chevron_left', color: AppTheme.primary, size: 20),
                rightChevronIcon: const CustomIconWidget(iconName: 'chevron_right', color: AppTheme.primary, size: 20),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                final status = AppData.dayAvailability(widget.vendor, selectedDay);
                if (status == 'full') return;
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (f) => _focusedDay = f,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final status = AppData.dayAvailability(widget.vendor, day);
                  final color = _colorFor(status);
                  return Container(
                    margin: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Center(child: Text('${day.day}', style: TextStyle(color: color, fontWeight: FontWeight.w600))),
                  );
                },
                selectedBuilder: (context, day, focusedDay) => Container(
                  margin: EdgeInsets.all(1.w),
                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                  child: Center(child: Text('${day.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          if (_selectedDay != null) _buildSlotPicker(),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightTheme.dividerColor),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 8,
        runSpacing: 8,
        children: [
          _legendItem(_available, "متاح"),
          _legendItem(_morningBooked, "صباحي محجوز"),
          _legendItem(_eveningBooked, "مسائي محجوز"),
          _legendItem(_full, "محجوز بالكامل"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          SizedBox(width: 1.5.w),
          Text(label, style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary)),
        ],
      );

  Widget _buildSlotPicker() {
    final day = _selectedDay!;
    final morningOk = AppData.isSlotAvailable(widget.vendor, day, 'morning');
    final eveningOk = AppData.isSlotAvailable(widget.vendor, day, 'evening');

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('اختر الفترة ليوم ${day.day}/${day.month}/${day.year}', style: AppTheme.lightTheme.textTheme.titleSmall),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: morningOk ? () => widget.onSlotSelected(day, 'morning') : null,
                  icon: const Icon(Icons.wb_sunny_outlined, size: 18),
                  label: const Text('صباحية'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: eveningOk ? () => widget.onSlotSelected(day, 'evening') : null,
                  icon: const Icon(Icons.nightlight_round, size: 18),
                  label: const Text('مسائية'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
