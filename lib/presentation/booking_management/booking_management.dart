import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/booking_card_widget.dart';
import './widgets/empty_bookings_widget.dart';

/// حجوزاتي (جهة العميل). تُقرأ كل الحجوزات من AppData مباشرة.
/// تم حذف زر "التواصل مع مقدم الخدمة" بناءً على طلب المالك.
class BookingManagement extends StatefulWidget {
  const BookingManagement({super.key});

  @override
  State<BookingManagement> createState() => _BookingManagementState();
}

class _BookingManagementState extends State<BookingManagement> with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final Set<String> _expanded = {};

  final List<String> _tabs = ['القادمة', 'السابقة', 'الملغية'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _category {
    switch (_tabController.index) {
      case 0: return 'upcoming';
      case 1: return 'past';
      case 2: return 'cancelled';
      default: return 'upcoming';
    }
  }

  String _bookingCategory(Map<String, dynamic> b) {
    final status = b['status'] as String? ?? 'pending';
    if (status == 'cancelled') return 'cancelled';
    if (status == 'completed') return 'past';
    final date = DateTime.tryParse(b['eventDate'] as String? ?? '');
    if (date != null && date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) return 'past';
    return 'upcoming';
  }

  List<Map<String, dynamic>> get _filtered {
    final all = AppData.instance.bookings;
    var list = all.where((b) => _bookingCategory(b) == _category).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((b) {
        final vendor = AppData.instance.vendorById(b['vendorId'] as String? ?? '');
        final name = (vendor?['name'] as String? ?? '').toLowerCase();
        final service = (b['service'] as String? ?? '').toLowerCase();
        return name.contains(q) || service.contains(q);
      }).toList();
    }
    return list;
  }

  List<int> get _counts {
    final all = AppData.instance.bookings;
    return [
      all.where((b) => _bookingCategory(b) == 'upcoming').length,
      all.where((b) => _bookingCategory(b) == 'past').length,
      all.where((b) => _bookingCategory(b) == 'cancelled').length,
    ];
  }

  void _cancelBooking(Map<String, dynamic> booking) {
    final vendor = AppData.instance.vendorById(booking['vendorId'] as String? ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء الحجز'),
        content: Text('هل أنت متأكد من إلغاء حجز ${vendor?['name'] ?? ''}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('تراجع')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppData.instance.updateBookingStatus(booking['id'] as String, 'cancelled');
              Fluttertoast.showToast(msg: 'تم إلغاء الحجز');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('حجوزاتي'), centerTitle: true),
      body: ListenableBuilder(
        listenable: AppData.instance,
        builder: (context, _) {
          final filtered = _filtered;
          final counts = _counts;
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: TextField(
                    onChanged: (q) => setState(() => _searchQuery = q),
                    decoration: const InputDecoration(hintText: 'ابحث في حجوزاتك...', prefixIcon: Icon(Icons.search)),
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  tabs: [for (var i = 0; i < _tabs.length; i++) Tab(text: counts[i] > 0 ? '${_tabs[i]} (${counts[i]})' : _tabs[i])],
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? EmptyBookingsWidget(
                          tabType: _category,
                          onCreateBooking: _category == 'upcoming' ? () => Navigator.pushNamed(context, '/home') : null,
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(bottom: 2.h),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final b = filtered[index];
                            final id = b['id'] as String;
                            final vendor = AppData.instance.vendorById(b['vendorId'] as String? ?? '');
                            return BookingCardWidget(
                              booking: b,
                              vendor: vendor,
                              isExpanded: _expanded.contains(id),
                              onTap: () => setState(() => _expanded.contains(id) ? _expanded.remove(id) : _expanded.add(id)),
                              onCancelBooking: b['status'] == 'pending' || b['status'] == 'confirmed' ? () => _cancelBooking(b) : null,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
