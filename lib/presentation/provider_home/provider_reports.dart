import 'package:flutter/material.dart';

import '../../core/app_export.dart';

class _Report {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<(String, String, String)> metrics; // label, value, delta
  final String chartTitle;
  final List<(String, double)> bars;
  const _Report(this.title, this.subtitle, this.icon, this.metrics, this.chartTitle, this.bars);
}

/// التقارير: بيانات تجريبية حالياً إلى أن تُربط بسجلات حقيقية.
class ProviderReports extends StatelessWidget {
  const ProviderReports({super.key});

  static const List<_Report> _reports = [
    _Report('التقييمات والرضا', 'ماذا يقول عملاؤك عن خدمتك', Icons.sentiment_satisfied_alt, [
      ('متوسط التقييم', '4.7', '+0.2'),
      ('نسبة الرضا', '93%', '+4%'),
      ('عدد التقييمات', '128', '+17'),
    ], 'توزيع النجوم', [('5★', 82), ('4★', 31), ('3★', 9), ('2★', 4), ('1★', 2)]),
    _Report('مقارنة شهرية', 'أداؤك هذا الشهر مقابل الشهر الماضي', Icons.compare_arrows, [
      ('الحجوزات', '24', '+20%'),
      ('الإيرادات', '9.6M', '+14%'),
      ('المشاهدات', '1,420', '+9%'),
    ], 'الحجوزات (آخر 6 أشهر)', [('ت1', 12), ('ت2', 15), ('ك1', 14), ('ش', 18), ('آ', 20), ('ن', 24)]),
    _Report('تقرير الأداء الشهري', 'ملخص نشاطك خلال الشهر', Icons.insights, [
      ('معدل التحويل', '7.8%', '+1.1%'),
      ('متوسط قيمة الحجز', '400K', '+6%'),
      ('نسبة الإلغاء', '4%', '-2%'),
    ], 'الإيرادات الأسبوعية (مليون)', [('أ1', 1.8), ('أ2', 2.4), ('أ3', 2.1), ('أ4', 3.3)]),
    _Report('تقرير المنافسة والترتيب', 'موقعك بين مقدمي الخدمة المشابهين', Icons.emoji_events_outlined, [
      ('ترتيبك بالمحافظة', '#3', '+2'),
      ('أقرب منافس', '4.8★', ''),
      ('حصتك من السوق', '11%', '+1.5%'),
    ], 'مقارنة التقييم', [('أنت', 4.7), ('م1', 4.8), ('م2', 4.5), ('م3', 4.3), ('م4', 4.1)]),
    _Report('تقرير السوق والترويج', 'أثر الإعلانات والعروض على نتائجك', Icons.campaign_outlined, [
      ('ظهور بالنتائج', '8,900', '+22%'),
      ('نقرات الإعلان', '640', '+31%'),
      ('حجوزات من الإعلان', '9', '+4'),
    ], 'الظهور الأسبوعي (آلاف)', [('أ1', 1.6), ('أ2', 2.1), ('أ3', 2.4), ('أ4', 2.8)]),
    _Report('الاتجاهات', 'ما الذي يطلبه العملاء حالياً', Icons.trending_up, [
      ('الأكثر طلباً', 'مسائي', ''),
      ('أفضل شهر', 'تموز', ''),
      ('متوسط الضيوف', '240', '+18'),
    ], 'الطلب حسب اليوم', [('سبت', 30), ('أحد', 8), ('اثن', 6), ('ثلا', 5), ('أرب', 7), ('خمي', 22), ('جمع', 34)]),
    _Report('قنوات الحصول على عملاء', 'من أين يأتي عملاؤك؟', Icons.share_outlined, [
      ('البحث بالتطبيق', '46%', ''),
      ('الإعلانات', '24%', ''),
      ('توصيات الأصدقاء', '30%', ''),
    ], 'النسبة المئوية', [('بحث', 46), ('إعلان', 24), ('توصية', 30)]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [
              Icon(Icons.info_outline, color: AppTheme.primary, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('بيانات تجريبية للعرض فقط، وستتحول إلى أرقام حقيقية عند تشغيل التطبيق فعلياً.', style: TextStyle(fontSize: 12, color: AppTheme.primary))),
            ]),
          ),
          const SizedBox(height: 12),
          for (final r in _reports)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(14)),
                  child: Icon(r.icon, color: Colors.white),
                ),
                title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(r.subtitle, style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.arrow_back_ios, size: 14),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ReportDetail(report: r))),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReportDetail extends StatelessWidget {
  final _Report report;
  const _ReportDetail({required this.report});

  @override
  Widget build(BuildContext context) {
    final maxV = report.bars.map((e) => e.$2).reduce((a, b) => a > b ? a : b);
    return Scaffold(
      appBar: AppBar(title: Text(report.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              for (final m in report.metrics)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                    decoration: BoxDecoration(color: AppTheme.secondary, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.accent)),
                    child: Column(
                      children: [
                        Text(m.$2, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                        const SizedBox(height: 2),
                        Text(m.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                        if (m.$3.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(m.$3, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: m.$3.startsWith('-') ? AppTheme.error : AppTheme.success)),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(report.chartTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          Container(
            height: 220,
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.accent)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final b in report.bars)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(b.$2 % 1 == 0 ? b.$2.toInt().toString() : b.$2.toString(), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          height: (b.$2 / maxV) * 130 + 6,
                          decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
                        ),
                        const SizedBox(height: 6),
                        Text(b.$1, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.5), borderRadius: BorderRadius.circular(14)),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: AppTheme.primary),
                SizedBox(width: 8),
                Expanded(child: Text('نصيحة: أضف صوراً جديدة وحدّث باقاتك دورياً لترفع ترتيبك في نتائج البحث.', style: TextStyle(height: 1.5, color: AppTheme.primary))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
