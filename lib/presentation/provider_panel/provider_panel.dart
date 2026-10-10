import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import './vendor_editor.dart';

/// لوحة مقدمي الخدمة: تعديل كل بيانات التطبيق
/// (الأسماء، الصور، أيام الحجز، الأسعار، طرق الدفع).
class ProviderPanel extends StatefulWidget {
  const ProviderPanel({super.key});

  @override
  State<ProviderPanel> createState() => _ProviderPanelState();
}

class _ProviderPanelState extends State<ProviderPanel>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _openEditor([String? vendorId]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VendorEditor(vendorId: vendorId)),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف مقدم الخدمة'),
        content: Text('هل أنت متأكد من حذف "${v['name']}" نهائياً؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok == true) AppData.instance.deleteVendor(v['id'] as String);
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('استعادة البيانات الافتراضية'),
        content: const Text(
            'سيتم حذف كل تعديلاتك واسترجاع البيانات التجريبية الأصلية. متابعة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('استعادة'),
          ),
        ],
      ),
    );
    if (ok == true) await AppData.instance.resetToDefaults();
  }

  // ---------------------------------------------------------------------------
  Widget _vendorsTab() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('إضافة مقدم خدمة'),
      ),
      body: ListenableBuilder(
        listenable: AppData.instance,
        builder: (context, _) {
          final vendors = AppData.instance.vendors;
          if (vendors.isEmpty) {
            return const Center(child: Text('لا يوجد مقدمو خدمة بعد'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 96),
            itemCount: vendors.length,
            itemBuilder: (context, i) {
              final v = vendors[i];
              final images = AppData.imagesOf(v);
              final active = v['isActive'] != false;
              return Card(
                child: ListTile(
                  onTap: () => _openEditor(v['id'] as String),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AppImage(
                      src: images.isEmpty ? null : images.first,
                      width: 56,
                      height: 56,
                    ),
                  ),
                  title: Text(v['name'] as String? ?? '',
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${AppData.categoryName(v['category'] as String?)} • ${v['city'] ?? ''}\n'
                    '${AppData.bookedDatesOf(v).length} يوم محجوز • ${images.length} صور',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: active ? 'ظاهر للعملاء' : 'مخفي عن العملاء',
                        child: Switch(
                          value: active,
                          onChanged: (b) => AppData.instance
                              .setVendorActive(v['id'] as String, b),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _confirmDelete(v),
                        icon: const Icon(Icons.delete_outline,
                            color: AppTheme.error),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Future<void> _editPayment(Map<String, dynamic> m) async {
    final account = TextEditingController(text: m['account'] as String? ?? '');
    final fee = TextEditingController(text: '${m['fee'] ?? 0}');
    final isCash = m['id'] == 'cash_delivery';

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(m['name'] as String? ?? ''),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isCash)
                TextField(
                  controller: account,
                  decoration: InputDecoration(
                    labelText: m['id'] == 'bank_transfer'
                        ? 'رقم الحساب / IBAN'
                        : 'رقم المحفظة',
                  ),
                ),
              if (!isCash) const SizedBox(height: 12),
              TextField(
                controller: fee,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    const InputDecoration(labelText: 'رسوم المعالجة (%)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              AppData.instance.updatePaymentMethod(m['id'] as String, {
                'account': account.text.trim(),
                'fee': double.tryParse(AppData.toLatinDigits(fee.text)) ?? 0.0,
              });
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    account.dispose();
    fee.dispose();
  }

  Widget _paymentsTab() {
    return ListenableBuilder(
      listenable: AppData.instance,
      builder: (context, _) {
        final methods = AppData.instance.paymentMethods;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 24),
          itemCount: methods.length,
          itemBuilder: (context, i) {
            final m = methods[i];
            final account = (m['account'] as String?) ?? '';
            final isCash = m['id'] == 'cash_delivery';
            return Card(
              child: ListTile(
                onTap: () => _editPayment(m),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.accent,
                  child: CustomIconWidget(
                    iconName: m['icon'] as String? ?? 'payment',
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
                title: Text(m['name'] as String? ?? ''),
                subtitle: Text(isCash
                    ? 'رسوم ${m['fee']}%'
                    : (account.isEmpty
                        ? 'لم يتم إدخال رقم الحساب • رسوم ${m['fee']}%'
                        : 'الحساب: $account • رسوم ${m['fee']}%')),
                trailing: Switch(
                  value: m['enabled'] == true,
                  onChanged: (b) => AppData.instance
                      .updatePaymentMethod(m['id'] as String, {'enabled': b}),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة مقدمي الخدمة'),
        leading: IconButton(
          tooltip: 'رجوع',
          icon: const Icon(Icons.logout),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.roleSelection, (r) => false),
        ),
        actions: [
          IconButton(
            tooltip: 'الحجوزات الواردة',
            icon: const Icon(Icons.inbox_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.vendorBookingManagement),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'reset') _confirmReset();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'reset', child: Text('استعادة البيانات الافتراضية')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'مقدمو الخدمة'),
            Tab(text: 'طرق الدفع'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_vendorsTab(), _paymentsTab()],
      ),
    );
  }
}
