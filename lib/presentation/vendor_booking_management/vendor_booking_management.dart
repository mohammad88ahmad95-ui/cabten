import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import './widgets/booking_card_widget.dart';
import './widgets/booking_detail_modal_widget.dart';
import './widgets/booking_filter_tabs_widget.dart';
import './widgets/booking_search_widget.dart';
import './widgets/empty_bookings_widget.dart';

/// الحجوزات الواردة (جهة مقدم الخدمة). تعرض كل الحجوزات القادمة من AppData
/// عبر جميع مقدمي الخدمة الذين تديرهم اللوحة، مع إمكانية القبول أو الرفض.
class VendorBookingManagement extends StatefulWidget {
  const VendorBookingManagement({Key? key}) : super(key: key);

  @override
  State<VendorBookingManagement> createState() => _VendorBookingManagementState();
}

class _VendorBookingManagementState extends State<VendorBookingManagement> {
  String _selectedFilter = 'new';
  String _searchQuery = '';

  List<Map<String, dynamic>> get _all => AppData.instance.bookings;

  List<Map<String, dynamic>> get _filtered {
    Iterable<Map<String, dynamic>> list;
    switch (_selectedFilter) {
      case 'new':
        list = _all.where((b) => b['status'] == 'pending');
        break;
      case 'confirmed':
        list = _all.where((b) => b['status'] == 'confirmed');
        break;
      case 'today':
        final todayKey = AppData.dateKey(DateTime.now());
        list = _all.where((b) => b['eventDate'] == todayKey);
        break;
      case 'history':
        list = _all.where((b) => b['status'] == 'completed' || b['status'] == 'cancelled');
        break;
      default:
        list = _all;
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((b) {
        final vendor = AppData.instance.vendorById(b['vendorId'] as String? ?? '');
        final vendorName = (vendor?['name'] as String? ?? '').toLowerCase();
        final client = (b['clientName'] as String? ?? '').toLowerCase();
        final service = (b['service'] as String? ?? '').toLowerCase();
        return vendorName.contains(q) || client.contains(q) || service.contains(q);
      });
    }
    return list.toList();
  }

  List<Map<String, dynamic>> get _counts {
    final todayKey = AppData.dateKey(DateTime.now());
    return [
      {'filter': 'new', 'count': _all.where((b) => b['status'] == 'pending').length},
      {'filter': 'confirmed', 'count': _all.where((b) => b['status'] == 'confirmed').length},
      {'filter': 'today', 'count': _all.where((b) => b['eventDate'] == todayKey).length},
      {'filter': 'history', 'count': _all.where((b) => b['status'] == 'completed' || b['status'] == 'cancelled').length},
    ];
  }

  void _accept(Map<String, dynamic> b) => AppData.instance.updateBookingStatus(b['id'] as String, 'confirmed');
  void _decline(Map<String, dynamic> b) => AppData.instance.updateBookingStatus(b['id'] as String, 'cancelled');
  void _complete(Map<String, dynamic> b) => AppData.instance.updateBookingStatus(b['id'] as String, 'completed');

  void _showDetails(Map<String, dynamic> booking) {
    final vendor = AppData.instance.vendorById(booking['vendorId'] as String? ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingDetailModalWidget(
        booking: booking,
        vendor: vendor,
        onConfirm: booking['status'] == 'pending' ? () { Navigator.pop(context); _accept(booking); } : null,
        onDecline: booking['status'] == 'pending' || booking['status'] == 'confirmed'
            ? () { Navigator.pop(context); _decline(booking); }
            : null,
        onMarkComplete: booking['status'] == 'confirmed' ? () { Navigator.pop(context); _complete(booking); } : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('الحجوزات الواردة')),
      body: ListenableBuilder(
        listenable: AppData.instance,
        builder: (context, _) {
          final filtered = _filtered;
          return Column(
            children: [
              BookingSearchWidget(onSearchChanged: (q) => setState(() => _searchQuery = q)),
              BookingFilterTabsWidget(
                selectedFilter: _selectedFilter,
                onFilterChanged: (f) => setState(() => _selectedFilter = f),
                bookingCounts: _counts,
              ),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyBookingsWidget(filterType: _selectedFilter)
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final b = filtered[index];
                          final vendor = AppData.instance.vendorById(b['vendorId'] as String? ?? '');
                          return BookingCardWidget(
                            booking: b,
                            vendor: vendor,
                            onAccept: b['status'] == 'pending' ? () => _accept(b) : null,
                            onDecline: (b['status'] == 'pending' || b['status'] == 'confirmed') ? () => _decline(b) : null,
                            onViewDetails: () => _showDetails(b),
                            onTap: () => _showDetails(b),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
