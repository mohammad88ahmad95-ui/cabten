import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart';

/// حسابك: الرصيد الحالي وتفاصيل كل حجز (العربون المدفوع والمتبقي).
class ProviderAccount extends StatelessWidget {
  const ProviderAccount({super.key});

  String _slotLabel(String? s) => s == 'morning' ? 'صباحي' : (s == 'evening' ? 'مسائي' : 'يوم كامل');

  @override
  Widget build(BuildContext context) {
    final vendorId = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      appBar: AppBar(title: const Text('حسابك')),
      body: ListenableBuilder(
        listenable: AppData.instance,
        builder: (context, _) {
          final bookings = vendorId == null
              ? <Map<String, dynamic>>[]
              : AppData.instance.bookingsForVendor(vendorId).where((b) => b['status'] != 'cancelled').toList();
          final balance = vendorId == null ? 0.0 : AppData.instance.balanceForVendor(vendorId);
          final pendingMoney = bookings.fold<double>(0, (s, b) => s + ((b['amountRemaining'] as num?) ?? 0).toDouble());

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('رصيد حسابك', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text('${AppData.formatNumber(balance)} ل.س', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.pending_actions, color: Colors.white70, size: 18),
                        const SizedBox(width: 6),
                        Text('مبالغ متبقية على العملاء: ${AppData.formatNumber(pendingMoney)} ل.س', style: const TextStyle(color: Colors.white, fontSize: 12.5)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('تفاصيل الحجوزات', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              if (bookings.isEmpty)
                const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('لا توجد حجوزات بعد', style: TextStyle(color: AppTheme.textSecondary)))),
              for (final b in bookings) _bookingTile(context, b),
            ],
          );
        },
      ),
    );
  }

  Widget _bookingTile(BuildContext context, Map<String, dynamic> b) {
    final received = ((b['amountReceived'] as num?) ?? 0).toDouble();
    final remaining = ((b['amountRemaining'] as num?) ?? 0).toDouble();
    final settled = remaining <= 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(b['clientName'] as String? ?? 'عميل', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: (settled ? AppTheme.success : AppTheme.warning).withOpacity(0.14), borderRadius: BorderRadius.circular(12)),
                  child: Text(settled ? 'تم التسديد بالكامل' : 'عربون مدفوع', style: TextStyle(fontSize: 11.5, color: settled ? AppTheme.success : AppTheme.warning, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'حجز بتاريخ ${b['eventDate']} • ${_slotLabel(b['slot'] as String?)}'
              '${(b['service'] as String? ?? '').isEmpty ? '' : ' • ${b['service']}'}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
            ),
            const Divider(height: 20),
            Row(
              children: [
                _amount('الإجمالي', ((b['totalAmount'] as num?) ?? 0).toDouble(), null),
                _amount('المدفوع', received, AppTheme.success),
                _amount('المتبقي', remaining, remaining > 0 ? AppTheme.error : AppTheme.textSecondary),
              ],
            ),
            if (!settled) ...[
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () {
                    AppData.instance.settleBooking(b['id'] as String);
                    Fluttertoast.showToast(msg: 'تم تسجيل استلام المبلغ المتبقي');
                  },
                  icon: const Icon(Icons.price_check, size: 18),
                  label: const Text('تسجيل استلام المتبقي'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _amount(String label, double value, Color? color) => Expanded(
        child: Column(
          children: [
            Text(AppData.formatNumber(value), style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 14)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      );
}
