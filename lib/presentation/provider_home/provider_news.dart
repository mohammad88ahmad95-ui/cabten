import 'package:flutter/material.dart';

import '../../core/app_export.dart';

/// جديدنا: ميزات جديدة، حملات ترويجية، نصائح، أخبار، وقصص نجاح (محتوى تجريبي).
class ProviderNews extends StatelessWidget {
  const ProviderNews({super.key});

  static const Map<String, List<(IconData, String, String, String)>> _sections = {
    'الميزات الجديدة': [
      (Icons.event_available, 'تقويم التوفر الذكي', 'أصبح بإمكانك إدارة الفترة الصباحية والمسائية لكل يوم بضغطة واحدة.', 'جديد'),
      (Icons.bar_chart, 'تقارير أعمق', 'سبعة تقارير تحليلية تساعدك على فهم عملائك ومنافسيك.', 'جديد'),
      (Icons.payments_outlined, 'متابعة الدفعات', 'سجّل استلام المبالغ المتبقية وتابع رصيدك لحظة بلحظة.', 'قريباً'),
    ],
    'الحملات الترويجية': [
      (Icons.campaign, 'حملة موسم الأعراس', 'ضع خدمتك في الواجهة خلال موسم الصيف وزد حجوزاتك حتى 40%.', 'ينتهي بعد 12 يوماً'),
      (Icons.local_offer_outlined, 'خصم الباقات الصباحية', 'فعّل عرضاً على الباقات الصباحية لتملأ الفترات الأقل طلباً.', 'متاح الآن'),
    ],
    'نصائح وأفكار': [
      (Icons.photo_camera_outlined, 'صور احترافية تجذب العملاء', 'الخدمات التي تضم 8 صور فأكثر تحصل على حجوزات أكثر بنسبة 2.3 مرة.', ''),
      (Icons.schedule, 'ردّ سريعاً على الطلبات', 'الرد خلال ساعة يرفع احتمال تثبيت الحجز بشكل كبير.', ''),
      (Icons.lightbulb_outline, 'باقات متنوعة', 'قدّم باقة اقتصادية وأخرى مميزة ليجد كل عميل ما يناسبه.', ''),
    ],
    'أخبار وتحديثات': [
      (Icons.newspaper, 'إطلاق التطبيق في كل المحافظات', 'أصبح كابتن بارتي متاحاً لعملاء الـ14 محافظة سورية.', ''),
      (Icons.verified_outlined, 'توثيق الحسابات', 'احصل على شارة "موثق" بعد زيارة فريقنا لمنشأتك.', ''),
    ],
    'قصص النجاح': [
      (Icons.emoji_events_outlined, 'قاعة الياسمين - دمشق', 'ضاعفت حجوزاتها خلال شهرين بعد تحديث الصور وإضافة الباقات المسائية.', ''),
      (Icons.star_outline, 'استوديو النور - حلب', 'وصل إلى تقييم 4.9 بفضل الالتزام بالمواعيد والرد السريع.', ''),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final keys = _sections.keys.toList();
    return DefaultTabController(
      length: keys.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('جديدنا'),
          bottom: TabBar(isScrollable: true, tabAlignment: TabAlignment.start, tabs: [for (final k in keys) Tab(text: k)]),
        ),
        body: TabBarView(
          children: [
            for (final k in keys)
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final it in _sections[k]!)
                    Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(14)),
                              child: Icon(it.$1, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(it.$2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
                                      if (it.$4.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(10)),
                                          child: Text(it.$4, style: const TextStyle(fontSize: 10.5, color: AppTheme.primary, fontWeight: FontWeight.w700)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(it.$3, style: const TextStyle(color: AppTheme.textSecondary, height: 1.5, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
