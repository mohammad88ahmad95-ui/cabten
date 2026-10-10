import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/vendor_availability_widget.dart';
import './widgets/vendor_gallery_widget.dart';
import './widgets/vendor_header_widget.dart';
import './widgets/vendor_overview_widget.dart';
import './widgets/vendor_pricing_widget.dart';
import './widgets/vendor_reviews_widget.dart';
import './widgets/vendor_sticky_bottom_bar_widget.dart';

/// صفحة تفاصيل مقدم الخدمة: سلايد صور، باقات صباحية/مسائية، وتقويم توفر
/// بأربع حالات ملوّنة. كل البيانات تُقرأ من AppData مباشرة فتتحدّث فوراً
/// مع أي تعديل من لوحة مقدم الخدمة.
class VendorDetailProfile extends StatefulWidget {
  const VendorDetailProfile({Key? key}) : super(key: key);

  @override
  State<VendorDetailProfile> createState() => _VendorDetailProfileState();
}

class _VendorDetailProfileState extends State<VendorDetailProfile> with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;
  bool _isFavorite = false;
  String? _vendorId;

  final List<Map<String, dynamic>> _reviewsData = [
    {
      "userName": "أحمد محمد",
      "userAvatar": "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rating": 5,
      "date": "منذ أسبوع",
      "comment": "خدمة ممتازة وفريق عمل محترف ومتعاون. أنصح بها بشدة لحفلات الزفاف.",
      "helpfulCount": 12,
      "images": [],
    },
    {
      "userName": "فاطمة أحمد",
      "userAvatar": "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rating": 4,
      "date": "منذ أسبوعين",
      "comment": "الخدمة جيدة، لكن الأسعار مرتفعة قليلاً. بشكل عام تجربة إيجابية.",
      "helpfulCount": 8,
      "images": [],
    },
    {
      "userName": "محمد علي",
      "userAvatar": "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "rating": 5,
      "date": "منذ شهر",
      "comment": "تنظيم رائع وأجواء مميزة. شكراً لكم على جعل حفلنا مميزاً.",
      "helpfulCount": 15,
      "images": [],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_vendorId != null) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    String? id;
    if (args is String) {
      id = args;
    } else if (args is Map) {
      id = args['vendorId'] as String?;
    }
    if (id == null || AppData.instance.vendorById(id) == null) {
      final list = AppData.instance.search();
      id = list.isEmpty ? null : list.first['id'] as String;
    }
    _vendorId = id;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 25.h && !_showAppBarTitle) {
      setState(() => _showAppBarTitle = true);
    } else if (_scrollController.offset <= 25.h && _showAppBarTitle) {
      setState(() => _showAppBarTitle = false);
    }
  }

  Map<String, dynamic> _buildVendorData(Map<String, dynamic> v) {
    final hours = (v['workingHours'] as String?) ?? '9:00 ص - 11:00 م';
    final desc = (v['description'] as String?)?.trim();
    return {
      "id": v['id'],
      "name": v['name'],
      "category": AppData.categoryName(v['category'] as String?),
      "rating": ((v['rating'] as num?) ?? 4.5).toDouble(),
      "reviewCount": ((v['reviewCount'] as num?) ?? 0).toInt(),
      "isVerified": v['isVerified'] == true,
      "description": (desc == null || desc.isEmpty) ? null : desc,
      "address": '${v['city'] ?? ''}، ${v['address'] ?? ''}',
      "images": AppData.imagesOf(v),
      "amenities": [for (final s in AppData.servicesOf(v)) {"name": s, "icon": "check_circle"}],
      "workingHours": {
        for (final d in ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']) d: hours,
      },
    };
  }

  /// ينتقل إلى تدفق الحجز حاملاً الباقة والفترة والتاريخ (إن وُجد).
  void _goToBooking(Map<String, dynamic> package, String slot, {DateTime? date}) {
    Navigator.pushNamed(
      context,
      AppRoutes.bookingFlow,
      arguments: {'vendorId': _vendorId, 'package': package, 'slot': slot, 'date': date},
    );
  }

  /// عند اختيار يوم وفترة من تقويم التوفر مباشرة (بدون المرور بتبويب
  /// الأسعار) نعرض باقات تلك الفترة ليختار العميل واحدة منها.
  void _onSlotSelectedFromCalendar(Map<String, dynamic> vendor, DateTime day, String slot) {
    final packages = slot == 'morning' ? AppData.morningPackagesOf(vendor) : AppData.eveningPackagesOf(vendor);
    if (packages.isEmpty) {
      Fluttertoast.showToast(msg: 'لا توجد باقات متاحة لهذه الفترة بعد');
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('اختر الباقة (${slot == 'morning' ? 'صباحية' : 'مسائية'})', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              ...packages.map((p) => ListTile(
                    title: Text(p['name'] as String? ?? ''),
                    subtitle: Text('${AppData.formatNumber(((p['price'] as num?) ?? 0).round())} ل.س'),
                    trailing: const Icon(Icons.arrow_back_ios, size: 16),
                    onTap: () {
                      Navigator.pop(ctx);
                      _goToBooking(p, slot, date: day);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  /// زر الحجز العام (الشريط السفلي اللاصق): يفتح تبويب الأسعار مباشرة
  /// ليختار العميل الفترة والباقة بنفسه.
  void _onGenericBookPressed() {
    _tabController.animateTo(3);
    Fluttertoast.showToast(msg: 'اختر الباقة المناسبة من الأسفل');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppData.instance,
      builder: (context, _) {
        final vendor = _vendorId == null ? null : AppData.instance.vendorById(_vendorId!);
        if (vendor == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('مقدم الخدمة غير متوفر')));
        }

        final vendorData = _buildVendorData(vendor);
        final morningPackages = AppData.morningPackagesOf(vendor);
        final eveningPackages = AppData.eveningPackagesOf(vendor);
        final allPrices = [...morningPackages, ...eveningPackages].map((p) => ((p['price'] as num?) ?? 0).round());
        final startingPrice = allPrices.isEmpty ? null : allPrices.reduce((a, b) => a < b ? a : b);

        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: VendorHeaderWidget(
                      vendorData: vendorData,
                      onBackPressed: () => Navigator.of(context).pop(),
                      onSharePressed: () => Fluttertoast.showToast(msg: 'تم نسخ رابط مقدم الخدمة'),
                      onFavoritePressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => _isFavorite = !_isFavorite);
                      },
                      isFavorite: _isFavorite,
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        tabs: const [
                          Tab(text: "نظرة عامة"),
                          Tab(text: "المعرض"),
                          Tab(text: "التقييمات"),
                          Tab(text: "الأسعار"),
                          Tab(text: "التوفر"),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.only(top: 2.h, bottom: 12.h),
                          child: VendorOverviewWidget(vendorData: vendorData),
                        ),
                        SingleChildScrollView(
                          padding: EdgeInsets.only(top: 2.h, bottom: 12.h),
                          child: VendorGalleryWidget(images: (vendorData["images"] as List).cast<String>()),
                        ),
                        SingleChildScrollView(
                          padding: EdgeInsets.only(top: 2.h, bottom: 12.h),
                          child: VendorReviewsWidget(
                            reviews: _reviewsData,
                            averageRating: vendorData["rating"] as double,
                            totalReviews: vendorData["reviewCount"] as int,
                          ),
                        ),
                        SingleChildScrollView(
                          padding: EdgeInsets.only(top: 2.h, bottom: 12.h),
                          child: VendorPricingWidget(
                            morningPackages: morningPackages,
                            eveningPackages: eveningPackages,
                            onPackageSelected: (p, slot) => _goToBooking(p, slot),
                          ),
                        ),
                        SingleChildScrollView(
                          padding: EdgeInsets.only(top: 2.h, bottom: 12.h),
                          child: VendorAvailabilityWidget(
                            vendor: vendor,
                            onSlotSelected: (day, slot) => _onSlotSelectedFromCalendar(vendor, day, slot),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _showAppBarTitle ? 12.h : 0,
                  decoration: BoxDecoration(
                    color: _showAppBarTitle ? AppTheme.lightTheme.scaffoldBackgroundColor.withOpacity(0.95) : Colors.transparent,
                    boxShadow: _showAppBarTitle ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))] : null,
                  ),
                  child: _showAppBarTitle
                      ? SafeArea(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Container(
                                    width: 10.w,
                                    height: 10.w,
                                    decoration: BoxDecoration(color: AppTheme.lightTheme.colorScheme.surface, borderRadius: BorderRadius.circular(20)),
                                    child: const Center(child: CustomIconWidget(iconName: 'arrow_forward', color: AppTheme.textPrimary, size: 20)),
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Text(vendorData["name"] as String? ?? "",
                                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VendorStickyBottomBarWidget(
                  onBookServicePressed: _onGenericBookPressed,
                  onRequestQuotePressed: () => Fluttertoast.showToast(msg: 'تم إرسال طلب عرض السعر بنجاح'),
                  startingPrice: startingPrice == null ? null : AppData.formatNumber(startingPrice),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppTheme.lightTheme.scaffoldBackgroundColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
