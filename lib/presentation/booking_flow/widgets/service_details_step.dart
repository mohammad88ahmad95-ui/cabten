import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// خطوة اختيار الباقة: تعرض الباقة المختارة مسبقاً (إن وصلت من صفحة
/// التفاصيل) مع خيار تغييرها، أو تطلب من العميل اختيار باقة إن لم تصل أي.
class ServiceDetailsStep extends StatefulWidget {
  final Map<String, dynamic> vendor;
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic> formData;

  const ServiceDetailsStep({Key? key, required this.vendor, required this.onDataChanged, required this.formData}) : super(key: key);

  @override
  State<ServiceDetailsStep> createState() => _ServiceDetailsStepState();
}

class _ServiceDetailsStepState extends State<ServiceDetailsStep> {
  int guestCount = 50;
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _requirements = TextEditingController();
  final int maxLen = 500;

  @override
  void initState() {
    super.initState();
    guestCount = widget.formData['guestCount'] ?? 50;
    _name.text = widget.formData['clientName'] ?? '';
    _phone.text = widget.formData['clientPhone'] ?? '';
    _requirements.text = widget.formData['specialRequirements'] ?? '';
  }

  void _update({Map<String, dynamic>? package, String? slot}) {
    widget.onDataChanged({
      ...widget.formData,
      if (package != null) 'selectedPackage': package,
      if (slot != null) 'selectedSlot': slot,
      'guestCount': guestCount,
      'clientName': _name.text,
      'clientPhone': _phone.text,
      'specialRequirements': _requirements.text,
    });
  }

  void _pickPackage() {
    final morning = AppData.morningPackagesOf(widget.vendor);
    final evening = AppData.eveningPackagesOf(widget.vendor);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اختر الباقة', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (morning.isNotEmpty) ...[
                  const Text('صباحية', style: TextStyle(fontWeight: FontWeight.w600)),
                  ...morning.map((p) => _pkgTile(p, 'morning', ctx)),
                ],
                if (evening.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('مسائية', style: TextStyle(fontWeight: FontWeight.w600)),
                  ...evening.map((p) => _pkgTile(p, 'evening', ctx)),
                ],
                if (morning.isEmpty && evening.isEmpty) const Text('لا توجد باقات متاحة لهذا المورّد بعد'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pkgTile(Map<String, dynamic> p, String slot, BuildContext ctx) {
    return ListTile(
      title: Text(p['name'] as String? ?? ''),
      subtitle: Text('${AppData.formatNumber(((p['price'] as num?) ?? 0).round())} ل.س'),
      onTap: () {
        Navigator.pop(ctx);
        setState(() {});
        _update(package: p, slot: slot);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = AppData.imagesOf(widget.vendor);
    final package = widget.formData['selectedPackage'] as Map<String, dynamic>?;
    final slot = widget.formData['selectedSlot'] as String?;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: AppImage(src: images.isEmpty ? null : images.first, width: 15.w, height: 15.w)),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.vendor['name'] as String? ?? '', style: AppTheme.lightTheme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 0.5.h),
                      Text('${widget.vendor['city'] ?? ''}', style: AppTheme.lightTheme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          Text('الباقة المختارة', style: AppTheme.lightTheme.textTheme.titleMedium),
          SizedBox(height: 1.h),
          if (package == null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(onPressed: _pickPackage, icon: const Icon(Icons.list_alt), label: const Text('اختر باقة')),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(slot == 'morning' ? Icons.wb_sunny_outlined : Icons.nightlight_round, color: AppTheme.primary, size: 18),
                      SizedBox(width: 2.w),
                      Expanded(child: Text(package['name'] as String? ?? '', style: AppTheme.lightTheme.textTheme.titleSmall)),
                      TextButton(onPressed: _pickPackage, child: const Text('تغيير')),
                    ],
                  ),
                  if ((package['details'] as String? ?? '').isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Text(package['details'] as String, style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                  ],
                  SizedBox(height: 0.5.h),
                  Text('${AppData.formatNumber(((package['price'] as num?) ?? 0).round())} ل.س',
                      style: AppTheme.getDataTextStyle(isLight: true, fontSize: 16, fontWeight: FontWeight.bold).copyWith(color: AppTheme.primary)),
                ],
              ),
            ),
          SizedBox(height: 3.h),
          Text('بيانات التواصل', style: AppTheme.lightTheme.textTheme.titleMedium),
          SizedBox(height: 1.h),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'الاسم الكامل'), onChanged: (_) => _update()),
          SizedBox(height: 2.h),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(labelText: 'رقم الهاتف'),
            onChanged: (_) => _update(),
          ),
          SizedBox(height: 3.h),
          Text('عدد الضيوف', style: AppTheme.lightTheme.textTheme.titleMedium),
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(border: Border.all(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الضيوف', style: AppTheme.lightTheme.textTheme.bodyMedium),
                Row(
                  children: [
                    _stepper('remove', guestCount > 1, () {
                      if (guestCount > 1) {
                        setState(() => guestCount--);
                        _update();
                      }
                    }),
                    SizedBox(width: 4.w),
                    SizedBox(width: 15.w, child: Text('$guestCount', textAlign: TextAlign.center, style: AppTheme.lightTheme.textTheme.titleMedium)),
                    SizedBox(width: 4.w),
                    _stepper('add', guestCount < 1000, () {
                      if (guestCount < 1000) {
                        setState(() => guestCount++);
                        _update();
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          Text('متطلبات خاصة', style: AppTheme.lightTheme.textTheme.titleMedium),
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(border: Border.all(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _requirements,
              maxLines: 4,
              maxLength: maxLen,
              decoration: InputDecoration(hintText: 'اذكر أي متطلبات خاصة لحدثك...', border: InputBorder.none, contentPadding: EdgeInsets.all(4.w)),
              onChanged: (_) {
                setState(() {});
                _update();
              },
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _stepper(String icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(color: enabled ? AppTheme.primary : AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
        child: CustomIconWidget(iconName: icon, color: enabled ? Colors.white : AppTheme.textSecondary, size: 16),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _requirements.dispose();
    super.dispose();
  }
}
