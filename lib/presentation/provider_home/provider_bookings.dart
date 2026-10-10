import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart';

/// الحجوزات: قبول/رفض الطلبات الواردة، إضافة حجز من خارج التطبيق، وسجل الحجوزات.
class ProviderBookings extends StatefulWidget {
  const ProviderBookings({super.key});

  @override
  State<ProviderBookings> createState() => _ProviderBookingsState();
}

class _ProviderBookingsState extends State<ProviderBookings> {
  final _name = TextEditingController();
  final _received = TextEditingController();
  final _remaining = TextEditingController();
  DateTime? _date;
  String _slot = 'full';
  String? _vendorId;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _vendorId = ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  void dispose() {
    _name.dispose();
    _received.dispose();
    _remaining.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      locale: const Locale('ar'),
    );
    if (d != null) setState(() => _date = d);
  }

  void _add() {
    final id = _vendorId;
    final received = double.tryParse(AppData.toLatinDigits(_received.text)) ?? 0;
    final remaining = double.tryParse(AppData.toLatinDigits(_remaining.text)) ?? 0;
    if (id == null || _name.text.trim().isEmpty || _date == null) {
      Fluttertoast.showToast(msg: 'أدخل الاسم وتاريخ الحجز');
      return;
    }
    final v = AppData.instance.vendorById(id);
    if (v != null) {
      final slots = _slot == 'full' ? ['morning', 'evening'] : [_slot];
      final taken = AppData.bookedSlotsOn(v, _date!);
      if (slots.any(taken.contains)) {
        Fluttertoast.showToast(msg: 'هذه الفترة محجوزة مسبقاً بهذا اليوم');
        return;
      }
    }
    AppData.instance.addManualBooking(
      vendorId: id,
      clientName: _name.text.trim(),
      eventDate: _date!,
      amountReceived: received,
      amountRemaining: remaining,
      slot: _slot,
    );
    _name.clear();
    _received.clear();
    _remaining.clear();
    FocusScope.of(context).unfocus();
    setState(() => _date = null);
    Fluttertoast.showToast(msg: 'تمت إضافة الحجز وتحديث التقويم');
  }

  String _slotLabel(String? s) => s == 'morning' ? 'صباحي' : (s == 'evening' ? 'مسائي' : 'يوم كامل');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الحجوزات')),
      body: ListenableBuilder(
        listenable: AppData.instance,
        builder: (context, _) {
          final all = _vendorId == null ? <Map<String, dynamic>>[] : AppData.instance.bookingsForVendor(_vendorId!);
          final pending = all.where((b) => b['status'] == 'pending').toList();
          final history = all.where((b) => b['status'] != 'pending').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                Text('طلبات بانتظار ردّك (${pending.length})', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final b in pending) _pendingCard(b),
                const SizedBox(height: 16),
              ],
              _addForm(),
              const SizedBox(height: 20),
              Text('سجل الحجوزات', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (history.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('لا توجد حجوزات سابقة', style: TextStyle(color: AppTheme.textSecondary)))),
              for (final b in history) _historyTile(b),
            ],
          );
        },
      ),
    );
  }

  Widget _pendingCard(Map<String, dynamic> b) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${b['clientName']} • ${b['eventDate']} • ${_slotLabel(b['slot'] as String?)}', style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('${b['service'] ?? ''}  •  ${AppData.formatNumber(((b['totalAmount'] as num?) ?? 0).toDouble())} ل.س  •  ${b['guestCount']} ضيف', style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
            if ((b['clientPhone'] as String? ?? '').isNotEmpty) Text('هاتف: ${b['clientPhone']}', style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary), textDirection: TextDirection.ltr),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => AppData.instance.updateBookingStatus(b['id'] as String, 'confirmed'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, padding: const EdgeInsets.symmetric(vertical: 10)),
                    child: const Text('قبول'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      AppData.instance.updateBookingStatus(b['id'] as String, 'cancelled');
                      // نحرّر الفترة المحجوزة ليعود اليوم متاحاً
                      final v = AppData.instance.vendorById(b['vendorId'] as String);
                      final d = DateTime.tryParse(b['eventDate'] as String? ?? '');
                      if (v != null && d != null) {
                        final slot = b['slot'] as String?;
                        final remain = AppData.bookedSlotsOn(v, d).where((s) => slot != 'full' && slot != null ? s != slot : false).toList();
                        AppData.instance.setDaySlots(v['id'] as String, d, remain);
                      }
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error, side: const BorderSide(color: AppTheme.error), padding: const EdgeInsets.symmetric(vertical: 10)),
                    child: const Text('رفض'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _addForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.secondary, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.accent)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.add_circle_outline, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('إضافة حجز من خارج التطبيق', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'الاسم')),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(_date == null ? 'تاريخ الحجز' : '${_date!.day}/${_date!.month}/${_date!.year}'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _slot,
            decoration: const InputDecoration(labelText: 'الفترة'),
            items: const [
              DropdownMenuItem(value: 'full', child: Text('يوم كامل')),
              DropdownMenuItem(value: 'morning', child: Text('صباحي')),
              DropdownMenuItem(value: 'evening', child: Text('مسائي')),
            ],
            onChanged: (v) => setState(() => _slot = v ?? 'full'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: TextField(controller: _received, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المبلغ المستلم'))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _remaining, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المبلغ المتبقي'))),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _add, child: const Text('إضافة الحجز'))),
        ],
      ),
    );
  }

  Widget _historyTile(Map<String, dynamic> b) {
    final manual = b['source'] == 'manual';
    final status = b['status'] as String? ?? '';
    final statusColor = status == 'cancelled' ? AppTheme.error : (status == 'completed' ? AppTheme.primary : AppTheme.success);
    final statusText = status == 'cancelled' ? 'ملغي' : (status == 'completed' ? 'مكتمل' : 'مؤكد');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppTheme.accent, child: Icon(manual ? Icons.edit_note : Icons.phone_android, color: AppTheme.primary, size: 20)),
        title: Text('${b['clientName']}', style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${b['eventDate']} • ${_slotLabel(b['slot'] as String?)} • ${manual ? 'أُضيف يدوياً' : 'من التطبيق'}\n'
            'مستلم ${AppData.formatNumber(((b['amountReceived'] as num?) ?? 0).toDouble())} • متبقي ${AppData.formatNumber(((b['amountRemaining'] as num?) ?? 0).toDouble())}'),
        isThreeLine: true,
        trailing: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    );
  }
}
