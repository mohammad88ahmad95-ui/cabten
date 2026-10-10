import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/app_export.dart';

class _PackageDraft {
  String name = 'الباقة الصباحية الفضية';
  final TextEditingController details = TextEditingController();
  final TextEditingController price = TextEditingController();
  void dispose() {
    details.dispose();
    price.dispose();
  }
}

/// معالج تسجيل خدمة جديدة لمقدم الخدمة:
/// 1) المعلومات الأساسية والموقع والوسائط  2) الباقات والتسعير  3) الاشتراك.
class ProviderOnboarding extends StatefulWidget {
  const ProviderOnboarding({super.key});

  @override
  State<ProviderOnboarding> createState() => _ProviderOnboardingState();
}

class _ProviderOnboardingState extends State<ProviderOnboarding> {
  int _step = 0;

  // الخطوة 1
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _desc = TextEditingController();
  String? _category;
  String? _governorate;
  Offset? _pin; // موقع الدبوس نسبةً لحجم الخريطة (0..1)
  final List<String> _images = [];
  String? _videoPath;

  // الخطوة 2
  final List<_PackageDraft> _packages = [_PackageDraft()];

  static const List<String> _packageNames = [
    'الباقة الصباحية الفضية',
    'الباقة الصباحية الذهبية',
    'الباقة الصباحية البلاتينية',
    'الباقة المسائية الفضية',
    'الباقة المسائية الذهبية',
    'الباقة المسائية البلاتينية',
  ];

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _desc.dispose();
    for (final p in _packages) {
      p.dispose();
    }
    super.dispose();
  }

  // ------------------------------------------------------------------ media
  Future<String?> _copyToAppDir(String srcPath, String folder) async {
    final dir = await getApplicationDocumentsDirectory();
    final target = Directory('${dir.path}/$folder');
    if (!await target.exists()) await target.create(recursive: true);
    final dot = srcPath.lastIndexOf('.');
    final ext = dot == -1 ? '' : srcPath.substring(dot);
    final dest = '${target.path}/${DateTime.now().millisecondsSinceEpoch}$ext';
    await File(srcPath).copy(dest);
    return dest;
  }

  Future<void> _addImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 80);
      if (picked == null) return;
      final saved = await _copyToAppDir(picked.path, 'vendor_images');
      if (saved != null && mounted) setState(() => _images.add(saved));
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر إضافة الصورة');
    }
  }

  Future<void> _addVideo() async {
    try {
      final picked = await ImagePicker().pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 2));
      if (picked == null) return;
      final saved = await _copyToAppDir(picked.path, 'vendor_videos');
      if (saved != null && mounted) setState(() => _videoPath = saved);
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر إضافة الفيديو');
    }
  }

  // ------------------------------------------------------------- validation
  bool get _step1Valid =>
      _name.text.trim().isNotEmpty &&
      _category != null &&
      _governorate != null &&
      _address.text.trim().isNotEmpty &&
      _desc.text.trim().isNotEmpty;

  bool get _step2Valid =>
      _packages.isNotEmpty &&
      _packages.every((p) => p.details.text.trim().isNotEmpty && (int.tryParse(AppData.toLatinDigits(p.price.text)) ?? 0) > 0);

  void _next() {
    if (_step == 0 && !_step1Valid) {
      Fluttertoast.showToast(msg: 'أكمل: الاسم، النوع، المحافظة، العنوان والوصف');
      return;
    }
    if (_step == 1 && !_step2Valid) {
      Fluttertoast.showToast(msg: 'أكمل تفاصيل وسعر كل باقة');
      return;
    }
    setState(() => _step++);
  }

  // ------------------------------------------------------------------- save
  Future<void> _finish(String tierId) async {
    final morning = <Map<String, dynamic>>[];
    final evening = <Map<String, dynamic>>[];
    for (final p in _packages) {
      final item = {
        'name': p.name,
        'details': p.details.text.trim(),
        'price': int.tryParse(AppData.toLatinDigits(p.price.text)) ?? 0,
      };
      (p.name.contains('صباحية') ? morning : evening).add(item);
    }
    final allPrices = [...morning, ...evening].map((e) => e['price'] as int).toList()..sort();
    // نحوّل موضع الدبوس إلى إحداثيات تقريبية داخل حدود سوريا
    final lat = _pin == null ? 33.5138 : 37.3 - (_pin!.dy * 5.0);
    final lng = _pin == null ? 36.2765 : 35.7 + (_pin!.dx * 6.7);

    AppData.instance.upsertVendor({
      'id': AppData.newId(),
      'name': _name.text.trim(),
      'category': _category,
      'city': _governorate,
      'address': _address.text.trim(),
      'phone': AuthSession.instance.phone,
      'ownerPhone': AuthSession.instance.phone,
      'description': _desc.text.trim(),
      'basePrice': allPrices.isEmpty ? 0 : allPrices.first,
      'workingHours': '9:00 ص - 11:00 م',
      'images': _images,
      'videoPath': _videoPath,
      'services': <String>[],
      'bookedSlots': <String, dynamic>{},
      'location': {'lat': lat, 'lng': lng},
      'rating': 0.0,
      'reviewCount': 0,
      'isVerified': false,
      'isActive': true,
      'subscriptionTier': tierId,
      'subscriptionStatus': 'pending_review',
      'morningPackages': morning,
      'eveningPackages': evening,
    });

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text('تم تثبيت المعلومات بنجاح', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('سيتم زيارتكم للتأكد من المعلومات المدرجة في أقرب وقت.',
                textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, height: 1.5)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('الانتقال إلى لوحتي')),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.providerHome, (r) => false);
  }

  // --------------------------------------------------------------------- UI
  Widget _stepHeader() {
    const titles = ['معلومات الخدمة', 'الباقات والتسعير', 'الاشتراك'];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Colors.white,
      child: Row(
        children: List.generate(3, (i) {
          final done = i < _step;
          final active = i == _step;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: (done || active) ? AppTheme.primary : AppTheme.accent,
                      child: done
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text('${i + 1}', style: TextStyle(color: active ? Colors.white : AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 4),
                    Text(titles[i], style: TextStyle(fontSize: 11, color: active ? AppTheme.primary : AppTheme.textSecondary, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
                  ],
                ),
                if (i < 2) Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 18, left: 4, right: 4), color: i < _step ? AppTheme.primary : AppTheme.accent)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(top: 16, bottom: 8), child: Text(t, style: Theme.of(context).textTheme.titleSmall));

  Widget _step1() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _label('اسم الخدمة / المنشأة'),
        TextField(controller: _name, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'مثال: قاعة الأحلام')),
        _label('نوع الخدمة'),
        DropdownButtonFormField<String>(
          value: _category,
          hint: const Text('اختر نوع الخدمة'),
          items: [for (final c in AppData.categories) DropdownMenuItem(value: c['id'], child: Text(c['name']!))],
          onChanged: (v) => setState(() => _category = v),
        ),
        _label('المحافظة'),
        DropdownButtonFormField<String>(
          value: _governorate,
          hint: const Text('اختر المحافظة'),
          items: [for (final g in AppData.governorates) DropdownMenuItem(value: g, child: Text(g))],
          onChanged: (v) => setState(() => _governorate = v),
        ),
        _label('العنوان التفصيلي'),
        TextField(controller: _address, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'الحي، الشارع، أقرب معلم')),
        _label('تحديد الموقع على الخريطة'),
        _mapPicker(),
        _label('لمحة عن الخدمات التي تقدمها'),
        TextField(controller: _desc, onChanged: (_) => setState(() {}), maxLines: 4, decoration: const InputDecoration(hintText: 'اكتب وصفاً جذاباً لخدماتك ومميزاتها...')),
        _label('الصور والفيديو'),
        _mediaSection(),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: _showTerms,
            icon: const Icon(Icons.privacy_tip_outlined, size: 18),
            label: const Text('الاطلاع على الشروط والخصوصية'),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _mapPicker() {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      const h = 190.0;
      return GestureDetector(
        onTapDown: (d) => setState(() => _pin = Offset((d.localPosition.dx / w).clamp(0.0, 1.0), (d.localPosition.dy / h).clamp(0.0, 1.0))),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: w,
            height: h,
            color: const Color(0xFFEFE6F2),
            child: Stack(
              children: [
                CustomPaint(size: Size(w, h), painter: _GridPainter()),
                const Positioned(top: 10, right: 12, child: Text('اضغط لتحديد موقعك', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 12))),
                if (_pin != null)
                  Positioned(
                    left: _pin!.dx * w - 16,
                    top: _pin!.dy * h - 34,
                    child: const Icon(Icons.location_on, color: AppTheme.error, size: 34),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _mediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 84,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: _addImage,
                child: Container(
                  width: 84,
                  margin: const EdgeInsetsDirectional.only(end: 8),
                  decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primaryLight)),
                  child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, color: AppTheme.primary), SizedBox(height: 4), Text('صورة', style: TextStyle(color: AppTheme.primary, fontSize: 12))]),
                ),
              ),
              for (var i = 0; i < _images.length; i++)
                Stack(
                  children: [
                    Container(
                      width: 84,
                      margin: const EdgeInsetsDirectional.only(end: 8),
                      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: AppImage(src: _images[i], width: 84, height: 84)),
                    ),
                    PositionedDirectional(
                      top: 2,
                      end: 10,
                      child: GestureDetector(
                        onTap: () => setState(() => _images.removeAt(i)),
                        child: const CircleAvatar(radius: 10, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 12, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _addVideo,
          icon: Icon(_videoPath == null ? Icons.videocam_outlined : Icons.check_circle, size: 18),
          label: Text(_videoPath == null ? 'إضافة فيديو (اختياري)' : 'تم إرفاق الفيديو - اضغط للاستبدال'),
        ),
      ],
    );
  }

  void _showTerms() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (context, sc) => ListView(
          controller: sc,
          padding: const EdgeInsets.all(20),
          children: const [
            Text('الشروط والخصوصية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            SizedBox(height: 12),
            Text('1. تلتزم بصحة المعلومات والصور المدرجة عن خدمتك.\n\n'
                '2. تلتزم بالأسعار والباقات المعلنة داخل التطبيق وبمواعيد الحجوزات المؤكدة.\n\n'
                '3. يحق للإدارة زيارة المنشأة للتحقق من المعلومات وتوثيق الحساب.\n\n'
                '4. تُستخدم بياناتك لعرض خدمتك وإدارة الحجوزات فقط، ولا تُشارك مع أطراف خارجية دون إذنك.\n\n'
                '5. يحق للإدارة تعليق أي خدمة تخالف السياسات.',
                style: TextStyle(height: 1.7)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- step 2
  Widget _step2() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('أضف باقاتك الصباحية والمسائية بالأسعار التي تناسبك. لا يوجد حد لعدد الباقات.', style: TextStyle(color: AppTheme.textSecondary, height: 1.5)),
        const SizedBox(height: 12),
        for (var i = 0; i < _packages.length; i++) _packageCard(i),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => setState(() => _packages.add(_PackageDraft())),
          icon: const Icon(Icons.add),
          label: const Text('إضافة باقة'),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _packageCard(int i) {
    final p = _packages[i];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('الباقة ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary)),
                const Spacer(),
                if (_packages.length > 1)
                  IconButton(
                    onPressed: () => setState(() {
                      _packages.removeAt(i).dispose();
                    }),
                    icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                  ),
              ],
            ),
            DropdownButtonFormField<String>(
              value: p.name,
              decoration: const InputDecoration(labelText: 'اسم الباقة'),
              items: [for (final n in _packageNames) DropdownMenuItem(value: n, child: Text(n))],
              onChanged: (v) => setState(() => p.name = v ?? p.name),
            ),
            const SizedBox(height: 12),
            TextField(controller: p.details, maxLines: 3, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'تفاصيل الباقة')),
            const SizedBox(height: 12),
            TextField(
              controller: p.price,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'سعر الباقة', suffixText: 'ل.س'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- step 3
  Widget _step3() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('اختر باقة الاشتراك المناسبة لك. يمكنك الترقية في أي وقت.', style: TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 14),
        for (final t in AppData.subscriptionTiers) _tierCard(t),
      ],
    );
  }

  Widget _tierCard(Map<String, dynamic> t) {
    final id = t['id'] as String;
    final price = t['price'] as int;
    final featured = id == 'advanced';
    final premium = id == 'professional';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: premium ? AppTheme.primaryGradient : null,
        color: premium ? null : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: featured ? AppTheme.primary : AppTheme.accent, width: featured ? 2 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(t['name'] as String, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: premium ? Colors.white : AppTheme.textPrimary))),
              if (featured)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(12)),
                  child: const Text('الأكثر طلباً', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(price == 0 ? 'مجاناً' : '${AppData.formatNumber(price)} ل.س / شهرياً',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: premium ? Colors.white : AppTheme.primary)),
          const SizedBox(height: 12),
          for (final f in (t['features'] as List))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Icon(Icons.check_circle, size: 18, color: premium ? Colors.white : AppTheme.success),
                const SizedBox(width: 8),
                Expanded(child: Text(f as String, style: TextStyle(color: premium ? Colors.white : AppTheme.textPrimary))),
              ]),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _finish(id),
              style: premium ? ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary) : null,
              child: Text(price == 0 ? 'ابدأ مجاناً' : 'اختيار هذه الباقة'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _step > 0) setState(() => _step--);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('تسجيل خدمة جديدة')),
        body: Column(
          children: [
            _stepHeader(),
            Expanded(child: [_step1(), _step2(), _step3()][_step]),
            if (_step < 2)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: AppTheme.shadowLight, blurRadius: 4, offset: const Offset(0, -2))]),
                child: SafeArea(
                  child: Row(
                    children: [
                      if (_step > 0) Expanded(child: OutlinedButton(onPressed: () => setState(() => _step--), child: const Text('السابق'))),
                      if (_step > 0) const SizedBox(width: 12),
                      Expanded(child: ElevatedButton(onPressed: _next, child: const Text('التالي'))),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1.2;
    for (double x = 0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
