import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مخزن بيانات التطبيق (مقدمو الخدمة + طرق الدفع).
/// كل ما يُعدَّل من لوحة مقدم الخدمة يُحفظ هنا ويظهر فوراً للعميل.
/// حالياً يُحفظ على الجهاز (shared_preferences)، وعند ربط الخادم لاحقاً
/// يكفي استبدال load() و _save() بنداءات API.
class AppData extends ChangeNotifier {
  AppData._();
  static final AppData instance = AppData._();

  static const String _storageKey = 'captain_party_data_v2';

  /// محافظات سوريا الأربعة عشرة
  static const List<String> governorates = [
    'دمشق',
    'ريف دمشق',
    'حلب',
    'حمص',
    'حماة',
    'اللاذقية',
    'طرطوس',
    'إدلب',
    'درعا',
    'السويداء',
    'القنيطرة',
    'دير الزور',
    'الرقة',
    'الحسكة',
  ];

  /// فئات الخدمات: من القاعات حتى أصغر التفاصيل
  static const List<Map<String, String>> categories = [
    {'id': 'venues', 'name': 'قاعات أفراح', 'icon': 'celebration'},
    {'id': 'photography', 'name': 'تصوير', 'icon': 'photo_camera'},
    {'id': 'catering', 'name': 'ضيافة وطعام', 'icon': 'restaurant'},
    {'id': 'decor', 'name': 'ديكور وزهور', 'icon': 'local_florist'},
    {'id': 'music', 'name': 'فرق وموسيقى', 'icon': 'music_note'},
    {'id': 'beauty', 'name': 'تجميل وعرائس', 'icon': 'spa'},
    {'id': 'fashion', 'name': 'فساتين وبدلات', 'icon': 'checkroom'},
    {'id': 'sweets', 'name': 'حلويات وكيك', 'icon': 'cake'},
    {'id': 'cars', 'name': 'سيارات زفاف', 'icon': 'directions_car'},
    {'id': 'gifts', 'name': 'دعوات وهدايا', 'icon': 'card_giftcard'},
  ];

  List<Map<String, dynamic>> _vendors = [];
  List<Map<String, dynamic>> _paymentMethods = [];
  List<Map<String, dynamic>> _bookings = [];

  List<Map<String, dynamic>> get vendors => List.unmodifiable(_vendors);
  List<Map<String, dynamic>> get paymentMethods =>
      List.unmodifiable(_paymentMethods);
  List<Map<String, dynamic>> get enabledPaymentMethods =>
      _paymentMethods.where((m) => m['enabled'] == true).toList();
  List<Map<String, dynamic>> get bookings => List.unmodifiable(_bookings);

  // ---------------------------------------------------------------------------
  // التحميل والحفظ
  // ---------------------------------------------------------------------------
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _vendors = (data['vendors'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _paymentMethods = (data['payments'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _bookings = ((data['bookings'] as List?) ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        return;
      }
    } catch (_) {
      // بيانات تالفة: نرجع للبيانات الافتراضية
    }
    _vendors = _seedVendors();
    _paymentMethods = _seedPayments();
    _bookings = [];
  }

  Future<void> _save() async {
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode({
          'vendors': _vendors,
          'payments': _paymentMethods,
          'bookings': _bookings,
        }),
      );
    } catch (_) {}
  }

  Future<void> resetToDefaults() async {
    _vendors = _seedVendors();
    _paymentMethods = _seedPayments();
    _bookings = [];
    await _save();
  }

  // ---------------------------------------------------------------------------
  // مقدمو الخدمة
  // ---------------------------------------------------------------------------
  Map<String, dynamic>? vendorById(String id) {
    for (final v in _vendors) {
      if (v['id'] == id) return v;
    }
    return null;
  }

  /// كل الخدمات المسجَّلة تحت رقم هاتف مقدم خدمة معيّن (الملكية).
  List<Map<String, dynamic>> vendorsForOwner(String phone) =>
      _vendors.where((v) => v['ownerPhone'] == phone).toList();

  List<Map<String, dynamic>> search({
    String category = 'all',
    String query = '',
    String governorate = 'الكل',
    double minPrice = 0,
    double maxPrice = double.infinity,
    double minRating = 0,
    String sortBy = 'relevance', // relevance | price_asc | price_desc | rating | nearest | newest
  }) {
    final q = query.trim();
    var list = _vendors.where((v) {
      if (v['isActive'] == false) return false;
      if (category != 'all' && v['category'] != category) return false;
      if (governorate != 'الكل' && v['city'] != governorate) return false;
      final price = ((v['basePrice'] as num?) ?? 0).toDouble();
      if (price < minPrice || price > maxPrice) return false;
      final rating = ((v['rating'] as num?) ?? 0).toDouble();
      if (rating < minRating) return false;
      if (q.isEmpty) return true;
      final hay = '${v['name']} ${v['city']} ${v['address']} '
          '${categoryName(v['category'] as String?)} '
          '${servicesOf(v).join(' ')}';
      return hay.contains(q);
    }).toList();

    switch (sortBy) {
      case 'price_asc':
        list.sort((a, b) => ((a['basePrice'] as num?) ?? 0).compareTo((b['basePrice'] as num?) ?? 0));
        break;
      case 'price_desc':
        list.sort((a, b) => ((b['basePrice'] as num?) ?? 0).compareTo((a['basePrice'] as num?) ?? 0));
        break;
      case 'rating':
        list.sort((a, b) => ((b['rating'] as num?) ?? 0).compareTo((a['rating'] as num?) ?? 0));
        break;
      case 'newest':
        list = list.reversed.toList();
        break;
      case 'nearest':
        // بانتظار ربط تحديد الموقع الفعلي: نقرّب "الأقرب" بترتيب مقدمي
        // الخدمة في نفس المحافظة المختارة أولاً.
        if (governorate != 'الكل') {
          list.sort((a, b) {
            final an = a['city'] == governorate ? 0 : 1;
            final bn = b['city'] == governorate ? 0 : 1;
            return an.compareTo(bn);
          });
        }
        break;
      case 'relevance':
      default:
        break;
    }
    return list;
  }

  void upsertVendor(Map<String, dynamic> vendor) {
    final copy = Map<String, dynamic>.from(
        jsonDecode(jsonEncode(vendor)) as Map<String, dynamic>);
    final i = _vendors.indexWhere((v) => v['id'] == copy['id']);
    if (i == -1) {
      _vendors.add(copy);
    } else {
      _vendors[i] = copy;
    }
    _save();
  }

  void deleteVendor(String id) {
    _vendors.removeWhere((v) => v['id'] == id);
    _save();
  }

  void setVendorActive(String id, bool active) {
    final v = vendorById(id);
    if (v == null) return;
    v['isActive'] = active;
    _save();
  }

  bool isBooked(String vendorId, DateTime day) {
    final v = vendorById(vendorId);
    if (v == null) return false;
    return dayAvailability(v, day) == 'full';
  }

  /// يضيف يوم حجز كامل (للتوافق مع الكود القديم، يحجز الفترتين معاً)
  void markBooked(String vendorId, DateTime day) {
    markSlotBooked(vendorId, day, 'morning');
    markSlotBooked(vendorId, day, 'evening');
  }

  /// يحجز فترة واحدة فقط (صباحية أو مسائية) من يوم معيّن.
  void markSlotBooked(String vendorId, DateTime day, String slot) {
    final v = vendorById(vendorId);
    if (v == null) return;
    final slots = Map<String, dynamic>.from((v['bookedSlots'] as Map?) ?? {});
    final key = dateKey(day);
    final daySlots = Set<String>.from((slots[key] as List?) ?? const []);
    daySlots.add(slot);
    slots[key] = daySlots.toList();
    v['bookedSlots'] = slots;
    _save();
  }

  /// هل فترة معيّنة (صباحية أو مسائية) من يوم معيّن متاحة للحجز؟
  static bool isSlotAvailable(Map<String, dynamic> v, DateTime day, String slot) {
    final status = dayAvailability(v, day);
    if (status == 'full') return false;
    if (slot == 'morning') return status != 'morning_booked';
    if (slot == 'evening') return status != 'evening_booked';
    return status == 'available';
  }

  /// يعيد حالة يوم معيّن: available | morning_booked | evening_booked | full
  static String dayAvailability(Map<String, dynamic> v, DateTime day) {
    final slots = Map<String, dynamic>.from((v['bookedSlots'] as Map?) ?? {});
    final daySlots = Set<String>.from((slots[dateKey(day)] as List?) ?? const []);
    final hasMorning = daySlots.contains('morning');
    final hasEvening = daySlots.contains('evening');
    if (hasMorning && hasEvening) return 'full';
    if (hasMorning) return 'morning_booked';
    if (hasEvening) return 'evening_booked';
    return 'available';
  }

  // ---------------------------------------------------------------------------
  // الحجوزات (تربط طلب العميل بلوحة مقدم الخدمة)
  // ---------------------------------------------------------------------------
  /// ينشئ حجزاً جديداً بحالة "قيد المراجعة" ويحجز التاريخ عند مقدم الخدمة.
  String createBooking({
    required String vendorId,
    required String clientName,
    required String clientPhone,
    required String service,
    required DateTime eventDate,
    required int guestCount,
    required int durationHours,
    required double totalAmount,
    required String paymentMethodId,
    String specialRequirements = '',
    String slot = 'full', // morning | evening | full
  }) {
    final id = 'booking_${DateTime.now().millisecondsSinceEpoch}';
    final deposit = totalAmount * 0.25;
    _bookings.insert(0, {
      'id': id,
      'vendorId': vendorId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'service': service,
      'eventDate': dateKey(eventDate),
      'slot': slot,
      'guestCount': guestCount,
      'durationHours': durationHours,
      'totalAmount': totalAmount,
      'amountReceived': deposit,
      'amountRemaining': totalAmount - deposit,
      'paymentMethodId': paymentMethodId,
      'specialRequirements': specialRequirements,
      'status': 'pending', // pending | confirmed | completed | cancelled
      'source': 'app', // app | manual
      'createdAt': DateTime.now().toIso8601String(),
    });
    if (slot == 'full') {
      markBooked(vendorId, eventDate);
    } else {
      markSlotBooked(vendorId, eventDate, slot);
    }
    _save();
    return id;
  }

  /// حجز يضيفه مقدم الخدمة يدوياً (تم خارج التطبيق) من لوحته.
  String addManualBooking({
    required String vendorId,
    required String clientName,
    required DateTime eventDate,
    required double amountReceived,
    required double amountRemaining,
    String slot = 'full',
  }) {
    final id = 'booking_${DateTime.now().millisecondsSinceEpoch}';
    _bookings.insert(0, {
      'id': id,
      'vendorId': vendorId,
      'clientName': clientName,
      'clientPhone': '',
      'service': '',
      'eventDate': dateKey(eventDate),
      'slot': slot,
      'guestCount': 0,
      'durationHours': 0,
      'totalAmount': amountReceived + amountRemaining,
      'amountReceived': amountReceived,
      'amountRemaining': amountRemaining,
      'paymentMethodId': '',
      'specialRequirements': '',
      'status': 'confirmed',
      'source': 'manual',
      'createdAt': DateTime.now().toIso8601String(),
    });
    if (slot == 'full') {
      markBooked(vendorId, eventDate);
    } else {
      markSlotBooked(vendorId, eventDate, slot);
    }
    _save();
    return id;
  }

  void updateBookingStatus(String bookingId, String status) {
    final i = _bookings.indexWhere((b) => b['id'] == bookingId);
    if (i == -1) return;
    _bookings[i] = {..._bookings[i], 'status': status};
    _save();
  }

  List<Map<String, dynamic>> bookingsForVendor(String vendorId) =>
      _bookings.where((b) => b['vendorId'] == vendorId).toList();

  /// إجمالي الرصيد المحصَّل لمقدم خدمة معيّن (مجموع العرابين والمبالغ المحصّلة)
  double balanceForVendor(String vendorId) {
    return bookingsForVendor(vendorId)
        .where((b) => b['status'] != 'cancelled')
        .fold<double>(0, (sum, b) => sum + ((b['amountReceived'] as num?) ?? 0).toDouble());
  }

  /// يضبط فترات يوم معيّن بشكل مباشر (يستخدمه مقدم الخدمة من تقويمه).
  /// slots: قائمة فارغة = متاح، ['morning'] / ['evening'] / كلاهما = محجوز.
  void setDaySlots(String vendorId, DateTime day, List<String> slots) {
    final v = vendorById(vendorId);
    if (v == null) return;
    final map = Map<String, dynamic>.from((v['bookedSlots'] as Map?) ?? {});
    if (slots.isEmpty) {
      map.remove(dateKey(day));
    } else {
      map[dateKey(day)] = slots;
    }
    v['bookedSlots'] = map;
    _save();
  }

  /// يسجّل استلام كامل المبلغ المتبقي لحجز معيّن.
  void settleBooking(String bookingId) {
    final i = _bookings.indexWhere((b) => b['id'] == bookingId);
    if (i == -1) return;
    final total = ((_bookings[i]['totalAmount'] as num?) ?? 0).toDouble();
    _bookings[i] = {..._bookings[i], 'amountReceived': total, 'amountRemaining': 0.0};
    _save();
  }

  /// كل حجوزات الخدمات التي يملكها رقم هاتف معيّن.
  List<Map<String, dynamic>> bookingsForOwner(String phone) {
    final ids = vendorsForOwner(phone).map((v) => v['id']).toSet();
    return _bookings.where((b) => ids.contains(b['vendorId'])).toList();
  }

  /// أقل سعر باقة لعرضه كـ "ابتداءً من".
  static num startingPrice(Map<String, dynamic> v) {
    final prices = [...morningPackagesOf(v), ...eveningPackagesOf(v)]
        .map((p) => (p['price'] as num?) ?? 0)
        .where((p) => p > 0)
        .toList();
    if (prices.isEmpty) return (v['basePrice'] as num?) ?? 0;
    prices.sort();
    return prices.first;
  }

  // ---------------------------------------------------------------------------
  // طرق الدفع
  // ---------------------------------------------------------------------------
  void updatePaymentMethod(String id, Map<String, dynamic> changes) {
    final i = _paymentMethods.indexWhere((m) => m['id'] == id);
    if (i == -1) return;
    _paymentMethods[i] = {..._paymentMethods[i], ...changes};
    _save();
  }

  // ---------------------------------------------------------------------------
  // مساعدات
  // ---------------------------------------------------------------------------
  static String newId() => 'vendor_${DateTime.now().millisecondsSinceEpoch}';

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static List<String> imagesOf(Map<String, dynamic> v) =>
      List<String>.from((v['images'] as List?) ?? const []);
  static List<String> servicesOf(Map<String, dynamic> v) =>
      List<String>.from((v['services'] as List?) ?? const []);
  /// الأيام المحجوزة بالكامل (الفترتان الصباحية والمسائية معاً)
  static List<String> bookedDatesOf(Map<String, dynamic> v) {
    final slots = Map<String, dynamic>.from((v['bookedSlots'] as Map?) ?? {});
    return slots.entries
        .where((e) => Set<String>.from((e.value as List?) ?? const []).length >= 2)
        .map((e) => e.key)
        .toList();
  }

  static List<Map<String, dynamic>> morningPackagesOf(Map<String, dynamic> v) =>
      List<Map<String, dynamic>>.from((v['morningPackages'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)) ?? const []);
  static List<Map<String, dynamic>> eveningPackagesOf(Map<String, dynamic> v) =>
      List<Map<String, dynamic>>.from((v['eveningPackages'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)) ?? const []);

  static Set<String> bookedSlotsOn(Map<String, dynamic> v, DateTime day) =>
      Set<String>.from((Map<String, dynamic>.from((v['bookedSlots'] as Map?) ?? {})[dateKey(day)] as List?) ?? const []);

  static String categoryName(String? id) {
    for (final c in categories) {
      if (c['id'] == id) return c['name']!;
    }
    return 'أخرى';
  }

  static String formatNumber(num n) {
    final s = n.round().toString();
    return s.replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  }

  /// يحوّل الأرقام العربية (٠١٢٣) إلى لاتينية لتقبلها int.tryParse
  static String toLatinDigits(String s) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    var out = s;
    for (var i = 0; i < arabic.length; i++) {
      out = out.replaceAll(arabic[i], i.toString());
    }
    return out.replaceAll(',', '').replaceAll('،', '').trim();
  }

  // ---------------------------------------------------------------------------
  // البيانات الافتراضية (يمكن تعديلها كلها من لوحة مقدم الخدمة)
  // ---------------------------------------------------------------------------
  static String _u(String id) =>
      'https://images.unsplash.com/$id?fm=jpg&q=60&w=1000';

  /// باقات الاشتراك الشهرية لمقدمي الخدمة
  static const List<Map<String, dynamic>> subscriptionTiers = [
    {
      'id': 'free',
      'name': 'الباقة المجانية',
      'price': 0,
      'features': ['عرض الخدمات', 'استقبال الحجوزات', 'تقارير أساسية'],
    },
    {
      'id': 'advanced',
      'name': 'الباقة المتقدمة',
      'price': 2500,
      'features': ['جميع الخدمات الأساسية', 'تقارير مفصلة', 'ظهور متقدم في النتائج'],
    },
    {
      'id': 'professional',
      'name': 'الباقة الاحترافية',
      'price': 6000,
      'features': ['جميع الخدمات السابقة', 'عروض ترويجية مجانية', 'دعم مخصص'],
    },
  ];

  static List<Map<String, dynamic>> _seedVendors() {
    final u1 = _u('photo-1519167758481-83f550bb49b3');
    final u2 = _u('photo-1464366400600-7168b8af9bc3');
    final u3 = _u('photo-1511795409834-ef04bbd61622');
    final u4 = _u('photo-1465495976277-4387d4b0e4a6');
    final u5 = _u('photo-1478146896981-b80fe463b330');
    final u6 = _u('photo-1507003211169-0a1dd7228f2d');

    Map<String, dynamic> v({
      required String id,
      required String name,
      required String category,
      required String city,
      required String address,
      required String description,
      required int price,
      required List<String> images,
      required List<String> services,
      required List<int> booked,
      double rating = 4.8,
      int reviews = 120,
    }) {
      // نوزّع أيام "booked" التجريبية بين حجز كامل، صباحي، ومسائي، لإظهار
      // الألوان الأربعة لحالة التوفر في صفحة التفاصيل منذ أول تشغيل.
      final bookedSlots = <String, List<String>>{};
      for (var i = 0; i < booked.length; i++) {
        final key = dateKey(DateTime.now().add(Duration(days: booked[i])));
        if (i % 3 == 0) {
          bookedSlots[key] = ['morning', 'evening'];
        } else if (i % 3 == 1) {
          bookedSlots[key] = ['morning'];
        } else {
          bookedSlots[key] = ['evening'];
        }
      }
      final morningBase = (price * 4).round();
      final eveningBase = (price * 6).round();
      return {
        'id': id,
        'name': name,
        'category': category,
        'city': city,
        'address': address,
        'phone': '',
        'ownerPhone': '', // غير مملوك لحساب حقيقي؛ بيانات تجريبية للعرض فقط
        'description': description,
        'basePrice': morningBase,
        'workingHours': '9:00 ص - 11:00 م',
        'images': images,
        'services': services,
        'bookedSlots': bookedSlots,
        'location': {'lat': 33.5138, 'lng': 36.2765},
        'rating': rating,
        'reviewCount': reviews,
        'isVerified': true,
        'isActive': true,
        'subscriptionTier': 'advanced',
        'subscriptionStatus': 'active',
        'morningPackages': [
          {'name': 'الباقة الصباحية الفضية', 'details': 'استخدام القاعة 4 ساعات صباحاً + ديكور أساسي', 'price': morningBase},
          {'name': 'الباقة الصباحية الذهبية', 'details': 'استخدام القاعة 5 ساعات صباحاً + ديكور وإضاءة مميزة', 'price': (morningBase * 1.4).round()},
        ],
        'eveningPackages': [
          {'name': 'الباقة المسائية الفضية', 'details': 'استخدام القاعة 6 ساعات مساءً + ديكور أساسي', 'price': eveningBase},
          {'name': 'الباقة المسائية الذهبية', 'details': 'استخدام القاعة 8 ساعات مساءً + ديكور فاخر وتصوير', 'price': (eveningBase * 1.5).round()},
        ],
      };
    }

    return [
      v(
        id: 'vendor_001',
        name: 'قاعة الأحلام الذهبية',
        category: 'venues',
        city: 'دمشق',
        address: 'شارع بغداد',
        description:
            'من أفخم قاعات الأفراح في دمشق بتصميم أنيق وعصري، تتسع لـ 500 ضيف وتوفر كل الخدمات اللازمة لحفل لا يُنسى.',
        price: 150000,
        images: [u1, u2, u3],
        services: ['حفل زفاف', 'خطوبة', 'عيد ميلاد', 'مناسبات شركات'],
        booked: [3, 10, 15, 22],
      ),
      v(
        id: 'vendor_002',
        name: 'قاعة الياسمين',
        category: 'venues',
        city: 'دمشق',
        address: 'المالكي',
        description: 'قاعة راقية بإطلالة جميلة وحديقة خارجية مناسبة لحفلات النهار والمساء.',
        price: 120000,
        images: [u4, u5],
        services: ['حفل زفاف', 'خطوبة', 'حفل تخرج'],
        booked: [5, 12],
        rating: 4.6,
        reviews: 89,
      ),
      v(
        id: 'vendor_003',
        name: 'استوديو النور للتصوير',
        category: 'photography',
        city: 'دمشق',
        address: 'المزة',
        description: 'تصوير فوتوغرافي وسينمائي احترافي للأفراح والمناسبات مع خدمة الدرون.',
        price: 60000,
        images: [u6, u3],
        services: ['تصوير فوتوغرافي', 'تصوير فيديو', 'تصوير جوي', 'جلسة ما قبل الزفاف'],
        booked: [4, 9],
        rating: 4.9,
        reviews: 210,
      ),
      v(
        id: 'vendor_004',
        name: 'مطعم الشام الأصيل للضيافة',
        category: 'catering',
        city: 'دمشق',
        address: 'الصالحية',
        description: 'بوفيهات ومقبلات وحلويات شرقية وغربية لجميع أنواع المناسبات.',
        price: 200000,
        images: [u5, u2],
        services: ['بوفيه مفتوح', 'مقبلات', 'قهوة وضيافة'],
        booked: [7, 14],
        rating: 4.7,
        reviews: 143,
      ),
      v(
        id: 'vendor_005',
        name: 'فرقة الأنغام الموسيقية',
        category: 'music',
        city: 'حلب',
        address: 'الفرقان',
        description: 'فرقة موسيقية ودي جي وزفة عروس بأجواء تراثية وعصرية.',
        price: 90000,
        images: [u3, u1],
        services: ['فرقة حية', 'دي جي', 'زفة عروس'],
        booked: [6],
        rating: 4.5,
        reviews: 64,
      ),
      v(
        id: 'vendor_006',
        name: 'لمسات للديكور والزهور',
        category: 'decor',
        city: 'اللاذقية',
        address: 'الزراعة',
        description: 'تنسيق ورود وكوشات وديكورات مخصصة لكل مناسبة.',
        price: 80000,
        images: [u2, u4],
        services: ['كوشة', 'تنسيق ورود', 'إضاءة'],
        booked: [8, 20],
        rating: 4.8,
        reviews: 97,
      ),
      v(
        id: 'vendor_007',
        name: 'بيت العروس للتجميل',
        category: 'beauty',
        city: 'دمشق',
        address: 'أبو رمانة',
        description: 'مكياج وتسريحات ورعاية بشرة للعروس والمدعوات.',
        price: 50000,
        images: [u6, u5],
        services: ['مكياج عروس', 'تسريحة', 'باقة العناية'],
        booked: [11],
        rating: 4.9,
        reviews: 178,
      ),
      v(
        id: 'vendor_008',
        name: 'حلويات السلطان',
        category: 'sweets',
        city: 'حمص',
        address: 'الحمراء',
        description: 'كيك مناسبات وتورتات مخصصة وحلويات عربية فاخرة.',
        price: 40000,
        images: [u4, u3],
        services: ['تورتة زفاف', 'كيك مناسبات', 'حلويات عربية'],
        booked: [13],
        rating: 4.7,
        reviews: 76,
      ),
    ];
  }

  static List<Map<String, dynamic>> _seedPayments() => [
        {
          'id': 'mtn_cash',
          'name': 'MTN كاش',
          'icon': 'account_balance_wallet',
          'fee': 2.5,
          'description': 'الدفع عبر محفظة MTN كاش',
          'enabled': true,
          'account': '',
        },
        {
          'id': 'syriatel_cash',
          'name': 'سيرياتيل كاش',
          'icon': 'account_balance_wallet',
          'fee': 2.0,
          'description': 'الدفع عبر محفظة سيرياتيل كاش',
          'enabled': true,
          'account': '',
        },
        {
          'id': 'sham_cash',
          'name': 'شام كاش',
          'icon': 'account_balance_wallet',
          'fee': 1.5,
          'description': 'الدفع عبر محفظة شام كاش',
          'enabled': true,
          'account': '',
        },
        {
          'id': 'bank_transfer',
          'name': 'دفع بنكي',
          'icon': 'account_balance',
          'fee': 0.0,
          'description': 'تحويل إلى الحساب البنكي',
          'enabled': true,
          'account': '',
        },
        {
          'id': 'cash_delivery',
          'name': 'الدفع عند التسليم',
          'icon': 'local_atm',
          'fee': 0.0,
          'description': 'ادفع نقداً عند تقديم الخدمة',
          'enabled': true,
          'account': '',
        },
      ];
}
