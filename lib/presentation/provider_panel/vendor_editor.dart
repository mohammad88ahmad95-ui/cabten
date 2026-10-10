import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/app_export.dart';

/// شاشة تعديل مقدم خدمة (أو إضافة جديد): الاسم، الصور، الأسعار،
/// الخدمات، أيام الحجز، وغيرها.
class VendorEditor extends StatefulWidget {
  final String? vendorId;
  const VendorEditor({super.key, this.vendorId});

  @override
  State<VendorEditor> createState() => _VendorEditorState();
}

class _VendorEditorState extends State<VendorEditor> {
  final _formKey = GlobalKey<FormState>();

  late final String _id;
  late final Map<String, dynamic> _original;
  late final TextEditingController _name;
  late final TextEditingController _city;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _desc;
  late final TextEditingController _price;
  late final TextEditingController _hours;
  final TextEditingController _serviceInput = TextEditingController();

  String _category = 'venues';
  bool _verified = true;
  bool _active = true;
  List<String> _images = [];
  List<String> _services = [];
  List<Map<String, dynamic>> _packages = [];

  bool get _isNew => widget.vendorId == null;

  @override
  void initState() {
    super.initState();
    final existing = _isNew ? null : AppData.instance.vendorById(widget.vendorId!);
    _original = existing == null ? {} : Map<String, dynamic>.from(existing);
    _id = (existing?['id'] as String?) ?? AppData.newId();

    _name = TextEditingController(text: existing?['name'] as String? ?? '');
    _city = TextEditingController(text: existing?['city'] as String? ?? '');
    _address = TextEditingController(text: existing?['address'] as String? ?? '');
    _phone = TextEditingController(text: existing?['phone'] as String? ?? '');
    _desc = TextEditingController(text: existing?['description'] as String? ?? '');
    _price = TextEditingController(
        text: existing == null ? '' : '${existing['basePrice'] ?? ''}');
    _hours = TextEditingController(
        text: existing?['workingHours'] as String? ?? '9:00 ص - 11:00 م');

    if (existing != null) {
      _category = existing['category'] as String? ?? 'venues';
      _verified = existing['isVerified'] != false;
      _active = existing['isActive'] != false;
      _images = AppData.imagesOf(existing);
      _services = AppData.servicesOf(existing);
      _packages = [...AppData.morningPackagesOf(existing), ...AppData.eveningPackagesOf(existing)];
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _city, _address, _phone, _desc, _price, _hours, _serviceInput]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // الحفظ
  // ---------------------------------------------------------------------------
  void _save() {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: 'تحقق من الحقول المطلوبة');
      return;
    }
    final vendor = <String, dynamic>{
      ..._original,
      'id': _id,
      'name': _name.text.trim(),
      'category': _category,
      'city': _city.text.trim(),
      'address': _address.text.trim(),
      'phone': _phone.text.trim(),
      'description': _desc.text.trim(),
      'basePrice': _packages.isEmpty
          ? (int.tryParse(AppData.toLatinDigits(_price.text)) ?? 0)
          : _packages.map((p) => ((p['price'] as num?) ?? 0).toInt()).reduce((a, b) => a < b ? a : b),
      'workingHours': _hours.text.trim(),
      'images': _images,
      'services': _services,
      'morningPackages': _packages.where((p) => p['name'].toString().contains('صباحية')).toList(),
      'eveningPackages': _packages.where((p) => !p['name'].toString().contains('صباحية')).toList(),
      'isVerified': _verified,
      'isActive': _active,
      'rating': _original['rating'] ?? 4.5,
      'reviewCount': _original['reviewCount'] ?? 0,
    };
    AppData.instance.upsertVendor(vendor);
    Fluttertoast.showToast(msg: 'تم حفظ التعديلات');
    Navigator.pop(context);
  }

  // ---------------------------------------------------------------------------
  // الصور
  // ---------------------------------------------------------------------------
  Future<void> _pickFromGallery() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (picked == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/vendor_images');
      if (!await folder.exists()) await folder.create(recursive: true);

      final dot = picked.path.lastIndexOf('.');
      final ext = dot == -1 ? '.jpg' : picked.path.substring(dot);
      final dest = '${folder.path}/${DateTime.now().millisecondsSinceEpoch}$ext';
      await File(picked.path).copy(dest);

      if (!mounted) return;
      setState(() => _images.add(dest));
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر إضافة الصورة');
    }
  }

  Future<void> _addUrl() async {
    final c = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة صورة برابط'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.url,
          textDirection: TextDirection.ltr,
          decoration: const InputDecoration(hintText: 'https://...'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('إضافة')),
        ],
      ),
    );
    c.dispose();
    if (url != null && url.startsWith('http')) {
      setState(() => _images.add(url));
    } else if (url != null && url.isNotEmpty) {
      Fluttertoast.showToast(msg: 'الرابط يجب أن يبدأ بـ http');
    }
  }

  void _showAddPhotoSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primary),
              title: const Text('من معرض الصور'),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link, color: AppTheme.primary),
              title: const Text('من رابط إنترنت'),
              onTap: () {
                Navigator.pop(ctx);
                _addUrl();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageTile(int i) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => setState(() {
              final img = _images.removeAt(i);
              _images.insert(0, img);
            }),
            child: AppImage(src: _images[i]),
          ),
          if (i == 0)
            PositionedDirectional(
              bottom: 0,
              start: 0,
              end: 0,
              child: Container(
                color: AppTheme.primary.withOpacity(0.85),
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: const Text('الغلاف',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ),
          PositionedDirectional(
            top: 4,
            end: 4,
            child: InkWell(
              onTap: () => setState(() => _images.removeAt(i)),
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // الخدمات
  // ---------------------------------------------------------------------------
  void _addService(String value) {
    final s = value.trim();
    if (s.isEmpty || _services.contains(s)) return;
    setState(() => _services.add(s));
    _serviceInput.clear();
  }

  // ---------------------------------------------------------------------------
  static const List<String> _pkgNames = [
    'الباقة الصباحية الفضية',
    'الباقة الصباحية الذهبية',
    'الباقة الصباحية البلاتينية',
    'الباقة المسائية الفضية',
    'الباقة المسائية الذهبية',
    'الباقة المسائية البلاتينية',
  ];

  Future<void> _editPackage(int? index) async {
    final existing = index == null ? null : _packages[index];
    String name = (existing?['name'] as String?) ?? _pkgNames.first;
    final details = TextEditingController(text: existing?['details'] as String? ?? '');
    final price = TextEditingController(text: existing == null ? '' : '${existing['price']}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(existing == null ? 'إضافة باقة' : 'تعديل الباقة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _pkgNames.contains(name) ? name : _pkgNames.first,
                  items: [for (final n in _pkgNames) DropdownMenuItem(value: n, child: Text(n))],
                  onChanged: (v) => setD(() => name = v ?? name),
                ),
                const SizedBox(height: 10),
                TextField(controller: details, maxLines: 3, decoration: const InputDecoration(labelText: 'التفاصيل')),
                const SizedBox(height: 10),
                TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر (ل.س)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حفظ')),
          ],
        ),
      ),
    );
    if (ok == true) {
      final item = {'name': name, 'details': details.text.trim(), 'price': int.tryParse(AppData.toLatinDigits(price.text)) ?? 0};
      setState(() {
        if (index == null) {
          _packages.add(item);
        } else {
          _packages[index] = item;
        }
      });
    }
    details.dispose();
    price.dispose();
  }

  Widget _section(String title, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'إضافة مقدم خدمة' : 'تعديل مقدم الخدمة'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            _section(
              'المعلومات الأساسية',
              Column(
                children: [
                  TextFormField(
                    controller: _name,
                    validator: _required,
                    decoration: const InputDecoration(labelText: 'اسم مقدم الخدمة'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(labelText: 'الفئة'),
                    items: [
                      for (final c in AppData.categories)
                        DropdownMenuItem(value: c['id'], child: Text(c['name']!)),
                    ],
                    onChanged: (v) => setState(() => _category = v ?? _category),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _city,
                          validator: _required,
                          decoration: const InputDecoration(labelText: 'المدينة'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _address,
                          decoration: const InputDecoration(labelText: 'الحي / الشارع'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _desc,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'الوصف'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف (للإدارة فقط - لا يظهر للعملاء)',
                    ),
                  ),
                ],
              ),
            ),
            _section(
              'الأسعار وأوقات العمل',
              Column(
                children: [
                  TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'السعر الأساسي (يُحدَّث تلقائياً من أقل باقة)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _hours,
                    decoration: const InputDecoration(labelText: 'ساعات العمل'),
                  ),
                ],
              ),
            ),
            _section(
              'الصور (${_images.length})',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _images.length + 1,
                    itemBuilder: (context, i) {
                      if (i == _images.length) {
                        return InkWell(
                          onTap: _showAddPhotoSheet,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.accent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primaryLight),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: AppTheme.primary),
                                SizedBox(height: 4),
                                Text('إضافة',
                                    style: TextStyle(
                                        color: AppTheme.primary, fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      }
                      return _imageTile(i);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('اضغط على أي صورة لجعلها صورة الغلاف',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            _section(
              'الخدمات المقدّمة',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final s in _services)
                        InputChip(
                          label: Text(s),
                          onDeleted: () => setState(() => _services.remove(s)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _serviceInput,
                          onSubmitted: _addService,
                          decoration: const InputDecoration(
                              hintText: 'أضف خدمة (مثال: حفل زفاف)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () => _addService(_serviceInput.text),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _section(
              'الباقات والأسعار',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < _packages.length; i++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(_packages[i]['name'].toString().contains('صباحية') ? Icons.wb_sunny_outlined : Icons.nightlight_round, color: AppTheme.primary),
                      title: Text(_packages[i]['name'] as String? ?? ''),
                      subtitle: Text('${AppData.formatNumber(((_packages[i]['price'] as num?) ?? 0).round())} ل.س'),
                      onTap: () => _editPackage(i),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                        onPressed: () => setState(() => _packages.removeAt(i)),
                      ),
                    ),
                  OutlinedButton.icon(onPressed: () => _editPackage(null), icon: const Icon(Icons.add), label: const Text('إضافة باقة')),
                ],
              ),
            ),
            _section(
              'الحالة',
              Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('ظاهر للعملاء'),
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('حساب موثّق'),
                    value: _verified,
                    onChanged: (v) => setState(() => _verified = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 70),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('حفظ التعديلات'),
          ),
        ),
      ),
    );
  }
}
