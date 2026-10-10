import 'package:flutter/material.dart';

import '../../core/app_export.dart';

class HomeBrowse extends StatefulWidget {
  const HomeBrowse({super.key});

  @override
  State<HomeBrowse> createState() => _HomeBrowseState();
}

class _HomeBrowseState extends State<HomeBrowse> {
  String _category = 'all';
  String _query = '';
  String _governorate = 'الكل';

  // حالة البحث المتقدم
  RangeValues _priceRange = const RangeValues(0, 500000);
  double _minRating = 0;
  DateTime? _eventDate;
  String _sortBy = 'relevance';

  static const List<Map<String, String>> _allCategories = [
    {'id': 'all', 'name': 'الكل', 'icon': 'apps'},
    ...AppData.categories,
  ];

  static const Map<String, String> _sortLabels = {
    'relevance': 'الأكثر صلة',
    'price_desc': 'السعر: من الأعلى',
    'price_asc': 'السعر: من الأدنى',
    'rating': 'الأعلى تقييماً',
    'nearest': 'الأقرب إليك',
    'newest': 'الأحدث',
  };

  void _openVendor(Map<String, dynamic> v) {
    Navigator.pushNamed(context, AppRoutes.vendorDetailProfile, arguments: v['id']);
  }

  void _book(Map<String, dynamic> v) {
    Navigator.pushNamed(context, AppRoutes.bookingFlow, arguments: v['id']);
  }

  bool get _hasActiveFilters =>
      _priceRange.start > 0 || _priceRange.end < 500000 || _minRating > 0 || _eventDate != null || _sortBy != 'relevance';

  // ---------------------------------------------------------------------------
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          // زر الإشعارات
          _circleIconButton(
            icon: Icons.notifications_outlined,
            onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/images/app_logo.png', width: 30, height: 30),
              ),
              const SizedBox(width: 8),
              const Text('كابتن بارتي', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          const Spacer(),
          // اختيار المحافظة
          GestureDetector(
            onTap: _pickGovernorate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Text(_governorate, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                  const Icon(Icons.keyboard_arrow_down, size: 18, color: AppTheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({required IconData icon, required VoidCallback onTap, bool showDot = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: AppTheme.secondary, shape: BoxShape.circle, border: Border.all(color: AppTheme.accent)),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          if (showDot)
            Positioned(
              top: 0,
              right: 0,
              child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle)),
            ),
        ],
      ),
    );
  }

  void _pickGovernorate() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('اختر المحافظة', style: Theme.of(context).textTheme.titleMedium),
            ),
            ListTile(
              title: const Text('الكل'),
              trailing: _governorate == 'الكل' ? const Icon(Icons.check, color: AppTheme.primary) : null,
              onTap: () {
                setState(() => _governorate = 'الكل');
                Navigator.pop(ctx);
              },
            ),
            ...AppData.governorates.map((g) => ListTile(
                  title: Text(g),
                  trailing: _governorate == g ? const Icon(Icons.check, color: AppTheme.primary) : null,
                  onTap: () {
                    setState(() => _governorate = g);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (q) => setState(() => _query = q),
              decoration: const InputDecoration(
                hintText: 'ابحث عن قاعة أو خدمة أو مدينة...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _openAdvancedSearch,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Center(child: Icon(Icons.tune, color: Colors.white)),
                  if (_hasActiveFilters)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.warning, shape: BoxShape.circle)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAdvancedSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _AdvancedSearchSheet(
        initialPriceRange: _priceRange,
        initialMinRating: _minRating,
        initialDate: _eventDate,
        initialSort: _sortBy,
        onApply: (priceRange, minRating, date, sort) {
          setState(() {
            _priceRange = priceRange;
            _minRating = minRating;
            _eventDate = date;
            _sortBy = sort;
          });
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _adBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: Stack(
            children: [
              Positioned(
                left: -10,
                bottom: -20,
                child: Icon(Icons.celebration, size: 110, color: Colors.white.withOpacity(0.12)),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('خصومات حصرية على باقات الأفراح',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('اكتشف أفضل العروض الآن', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _categoryStrip() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _allCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final c = _allCategories[i];
          final selected = _category == c['id'];
          return GestureDetector(
            onTap: () => setState(() => _category = c['id']!),
            child: SizedBox(
              width: 74,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: selected ? AppTheme.primaryGradient : null,
                      color: selected ? null : AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomIconWidget(iconName: c['icon']!, color: selected ? Colors.white : AppTheme.primary, size: 26),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c['name']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _sortChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _sortLabels.entries.map((e) {
          final selected = _sortBy == e.key;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              label: Text(e.value, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppTheme.textPrimary)),
              selected: selected,
              selectedColor: AppTheme.primary,
              backgroundColor: AppTheme.accent,
              onSelected: (_) => setState(() => _sortBy = e.key),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _vendorCard(Map<String, dynamic> v) {
    final tt = Theme.of(context).textTheme;
    final images = AppData.imagesOf(v);
    final price = AppData.startingPrice(v);
    final rating = (v['rating'] as num?)?.toDouble() ?? 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openVendor(v),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AppImage(src: images.isEmpty ? null : images.first, width: double.infinity, height: 170),
                PositionedDirectional(
                  top: 10,
                  start: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                    child: Text(AppData.categoryName(v['category'] as String?),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
                if (v['isVerified'] == true)
                  const PositionedDirectional(
                    top: 10,
                    end: 10,
                    child: CircleAvatar(radius: 14, backgroundColor: Colors.white, child: Icon(Icons.verified, size: 20, color: AppTheme.primary)),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(v['name'] as String? ?? '', style: tt.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const Icon(Icons.star, size: 18, color: AppTheme.warning),
                      const SizedBox(width: 4),
                      Text(rating.toStringAsFixed(1), style: tt.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('${v['city'] ?? ''} - ${v['address'] ?? ''}', style: tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text('ابتداءً من ${AppData.formatNumber(price)} ل.س', style: tt.titleSmall?.copyWith(color: AppTheme.primary)),
                      ),
                      ElevatedButton(
                        onPressed: () => _book(v),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10)),
                        child: const Text('احجز الآن'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: AppData.instance,
        builder: (context, _) {
          final list = AppData.instance.search(
            category: _category,
            query: _query,
            governorate: _governorate,
            minPrice: _priceRange.start,
            maxPrice: _priceRange.end >= 500000 ? double.infinity : _priceRange.end,
            minRating: _minRating,
            sortBy: _sortBy,
          );
          return SafeArea(
            child: Column(
              children: [
                _topBar(),
                _searchBar(),
                _adBanner(),
                _categoryStrip(),
                if (_hasActiveFilters) _sortChips(),
                Expanded(
                  child: list.isEmpty
                      ? const Center(child: Text('لا توجد نتائج مطابقة', style: TextStyle(color: AppTheme.textSecondary)))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: list.length,
                          itemBuilder: (context, i) => _vendorCard(list[i]),
                        ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, AppRoutes.bookingManagement);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), activeIcon: Icon(Icons.event_note), label: 'حجوزاتي'),
        ],
      ),
    );
  }
}

/// ورقة البحث المتقدم: نطاق السعر، التقييم، تاريخ الحدث، والترتيب.
class _AdvancedSearchSheet extends StatefulWidget {
  final RangeValues initialPriceRange;
  final double initialMinRating;
  final DateTime? initialDate;
  final String initialSort;
  final void Function(RangeValues priceRange, double minRating, DateTime? date, String sort) onApply;

  const _AdvancedSearchSheet({
    required this.initialPriceRange,
    required this.initialMinRating,
    required this.initialDate,
    required this.initialSort,
    required this.onApply,
  });

  @override
  State<_AdvancedSearchSheet> createState() => _AdvancedSearchSheetState();
}

class _AdvancedSearchSheetState extends State<_AdvancedSearchSheet> {
  late RangeValues _priceRange = widget.initialPriceRange;
  late double _minRating = widget.initialMinRating;
  DateTime? _date;
  late String _sort = widget.initialSort;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      locale: const Locale('ar'),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('بحث متقدم', style: tt.titleLarge),
                  TextButton(
                    onPressed: () => setState(() {
                      _priceRange = const RangeValues(0, 500000);
                      _minRating = 0;
                      _date = null;
                      _sort = 'relevance';
                    }),
                    child: const Text('إعادة ضبط'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('نطاق السعر (ل.س)', style: tt.titleSmall),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 500000,
                divisions: 20,
                labels: RangeLabels(AppData.formatNumber(_priceRange.start), AppData.formatNumber(_priceRange.end)),
                onChanged: (v) => setState(() => _priceRange = v),
              ),
              const SizedBox(height: 10),
              Text('الحد الأدنى للتقييم', style: tt.titleSmall),
              Row(
                children: List.generate(5, (i) {
                  final starValue = i + 1;
                  return IconButton(
                    onPressed: () => setState(() => _minRating = _minRating == starValue ? 0 : starValue.toDouble()),
                    icon: Icon(
                      starValue <= _minRating ? Icons.star : Icons.star_border,
                      color: AppTheme.warning,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              Text('تاريخ الحدث', style: tt.titleSmall),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(_date == null ? 'اختر تاريخاً (اختياري)' : '${_date!.day}/${_date!.month}/${_date!.year}'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_priceRange, _minRating, _date, _sort);
                    Navigator.pop(context);
                  },
                  child: const Text('تطبيق البحث'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
