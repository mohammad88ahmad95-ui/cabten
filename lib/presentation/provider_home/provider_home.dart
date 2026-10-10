import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_export.dart';
import '../provider_panel/vendor_editor.dart';

/// الصفحة الرئيسية لمقدم الخدمة: إشعارات، إعلان، الفئات الأربع، وتقويم توفر.
/// لا يرى مقدم الخدمة هنا سوى الخدمات المسجّلة باسم رقم هاتفه.
class ProviderHome extends StatefulWidget {
  const ProviderHome({super.key});

  @override
  State<ProviderHome> createState() => _ProviderHomeState();
}

class _ProviderHomeState extends State<ProviderHome> {
  String? _vendorId;
  DateTime _focused = DateTime.now();

  static const Color _morning = Color(0xFFF2A541);
  static const Color _evening = Color(0xFF5E60CE);

  List<Map<String, dynamic>> get _mine => AppData.instance.vendorsForOwner(AuthSession.instance.phone);

  Map<String, dynamic>? get _current {
    final list = _mine;
    if (list.isEmpty) return null;
    return list.firstWhere((v) => v['id'] == _vendorId, orElse: () => list.first);
  }

  Color _colorFor(String status) {
    switch (status) {
      case 'morning_booked':
        return _morning;
      case 'evening_booked':
        return _evening;
      case 'full':
        return AppTheme.error;
      default:
        return AppTheme.success;
    }
  }

  void _openTile(String route) {
    final v = _current;
    if (v == null) return;
    Navigator.pushNamed(context, route, arguments: v['id']);
  }

  void _editDay(Map<String, dynamic> v, DateTime day) {
    final current = AppData.bookedSlotsOn(v, day);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        Widget opt(IconData icon, Color c, String label, List<String> slots) {
          return ListTile(
            leading: CircleAvatar(backgroundColor: c.withOpacity(0.15), child: Icon(icon, color: c, size: 20)),
            title: Text(label),
            onTap: () {
              AppData.instance.setDaySlots(v['id'] as String, day, slots);
              Navigator.pop(ctx);
              Fluttertoast.showToast(msg: 'تم تحديث اليوم');
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('${day.day}/${day.month}/${day.year}  •  ${current.isEmpty ? 'متاح' : 'يوجد حجز'}', style: Theme.of(context).textTheme.titleMedium),
              ),
              opt(Icons.check_circle_outline, AppTheme.success, 'متاح (إلغاء الحجز)', []),
              opt(Icons.wb_sunny_outlined, _morning, 'حجز صباحي', ['morning']),
              opt(Icons.nightlight_round, _evening, 'حجز مسائي', ['evening']),
              opt(Icons.block, AppTheme.error, 'محجوز بالكامل', ['morning', 'evening']),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------------ parts
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.notifications, arguments: 'provider'),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: AppTheme.secondary, shape: BoxShape.circle, border: Border.all(color: AppTheme.accent)),
                  child: const Icon(Icons.notifications_outlined, color: AppTheme.primary),
                ),
                Positioned(top: 0, right: 0, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Text('لوحة مقدم الخدمة', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17))),
          IconButton(
            tooltip: 'تبديل الحساب',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.roleSelection, (r) => false),
            icon: const Icon(Icons.swap_horiz, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _vendorSwitcher() {
    final list = _mine;
    final cur = _current!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: cur['id'] as String,
              isExpanded: true,
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              items: [for (final v in list) DropdownMenuItem(value: v['id'] as String, child: Text(v['name'] as String? ?? '', overflow: TextOverflow.ellipsis))],
              onChanged: (id) => setState(() => _vendorId = id),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: 'إضافة خدمة جديدة',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.providerOnboarding),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _statusBanner(Map<String, dynamic> v) {
    if (v['subscriptionStatus'] != 'pending_review') return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.warning.withOpacity(0.4))),
      child: const Row(
        children: [
          Icon(Icons.hourglass_top, color: AppTheme.warning, size: 20),
          SizedBox(width: 8),
          Expanded(child: Text('خدمتك قيد المراجعة؛ سيتم زيارتكم للتأكد من المعلومات في أقرب وقت.', style: TextStyle(fontSize: 12.5, color: AppTheme.warning))),
        ],
      ),
    );
  }

  Widget _adBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 130,
          width: double.infinity,
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: Stack(
            children: [
              Positioned(left: -10, bottom: -24, child: Icon(Icons.campaign, size: 120, color: Colors.white.withOpacity(0.12))),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('إعلان الصفحة الرئيسية', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('2,000 ل.س لمدة شهر كامل', style: TextStyle(color: Colors.white.withOpacity(0.92), fontSize: 13)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        onPressed: () => Fluttertoast.showToast(msg: 'تم استلام طلب الإعلان وسنتواصل معك للتأكيد'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(horizontal: 18)),
                        child: const Text('احجز الآن', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stats(Map<String, dynamic> v) {
    final bookings = AppData.instance.bookingsForVendor(v['id'] as String);
    final pending = bookings.where((b) => b['status'] == 'pending').length;
    final balance = AppData.instance.balanceForVendor(v['id'] as String);
    Widget tile(String label, String value, IconData icon) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(color: AppTheme.secondary, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.accent)),
            child: Column(
              children: [
                Icon(icon, color: AppTheme.primary, size: 20),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.primary)),
                Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          tile('الرصيد', AppData.formatNumber(balance), Icons.account_balance_wallet_outlined),
          const SizedBox(width: 8),
          tile('طلبات جديدة', '$pending', Icons.inbox_outlined),
          const SizedBox(width: 8),
          tile('التقييم', '${((v['rating'] as num?) ?? 0).toStringAsFixed(1)}', Icons.star_outline),
        ],
      ),
    );
  }

  Widget _categories() {
    final items = [
      ('حسابك', Icons.account_balance_wallet, AppRoutes.providerAccount),
      ('تقارير', Icons.bar_chart, AppRoutes.providerReports),
      ('الحجوزات', Icons.event_note, AppRoutes.providerBookings),
      ('جديدنا', Icons.auto_awesome, AppRoutes.providerNews),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          for (final it in items)
            Expanded(
              child: GestureDetector(
                onTap: () => _openTile(it.$3),
                child: Column(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 4))]),
                      child: Icon(it.$2, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 6),
                    Text(it.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _calendar(Map<String, dynamic> v) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تقويم التوفر', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text('اضغط على أي يوم لإضافة حجز أو تفريغه.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(spacing: 12, runSpacing: 6, children: [
            _legend(AppTheme.success, 'متاح'),
            _legend(_morning, 'صباحي محجوز'),
            _legend(_evening, 'مسائي محجوز'),
            _legend(AppTheme.error, 'محجوز بالكامل'),
          ]),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.accent)),
            child: TableCalendar<DateTime>(
              locale: 'ar',
              firstDay: DateTime.now().subtract(const Duration(days: 30)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focused,
              startingDayOfWeek: StartingDayOfWeek.saturday,
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
              onPageChanged: (f) => _focused = f,
              onDaySelected: (d, f) {
                setState(() => _focused = f);
                _editDay(v, d);
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, f) => _dayCell(v, day),
                todayBuilder: (context, day, f) => _dayCell(v, day, isToday: true),
                outsideBuilder: (context, day, f) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayCell(Map<String, dynamic> v, DateTime day, {bool isToday = false}) {
    final c = _colorFor(AppData.dayAvailability(v, day));
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.14),
        shape: BoxShape.circle,
        border: Border.all(color: isToday ? AppTheme.primary : c.withOpacity(0.45), width: isToday ? 2 : 1),
      ),
      child: Center(child: Text('${day.day}', style: TextStyle(color: c, fontWeight: FontWeight.w700))),
    );
  }

  Widget _legend(Color c, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 11, height: 11, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(t, style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
      ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AppData.instance,
          builder: (context, _) {
            final v = _current;
            if (v == null) {
              return Column(
                children: [
                  _topBar(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.storefront, size: 64, color: AppTheme.primaryLight),
                          const SizedBox(height: 12),
                          const Text('لم تسجّل أي خدمة بعد'),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.providerOnboarding), child: const Text('سجّل خدمتك الآن')),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView(
              children: [
                _topBar(),
                _vendorSwitcher(),
                _statusBanner(v),
                _adBanner(),
                _stats(v),
                _categories(),
                _calendar(v),
              ],
            );
          },
        ),
      ),
      floatingActionButton: ListenableBuilder(
        listenable: AppData.instance,
        builder: (context, _) {
          final v = _current;
          if (v == null) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VendorEditor(vendorId: v['id'] as String))),
            icon: const Icon(Icons.edit),
            label: const Text('تعديل خدمتي'),
          );
        },
      ),
    );
  }
}
