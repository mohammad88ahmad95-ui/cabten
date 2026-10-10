import 'package:flutter/material.dart';

import '../../core/app_export.dart';

/// شاشة الإشعارات. حالياً تعرض بيانات تجريبية (placeholder) إلى أن يُربط
/// التطبيق بنظام إشعارات حقيقي (push notifications).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const List<Map<String, String>> _demo = [
    {'icon': 'event_available', 'title': 'تم تأكيد حجزك', 'body': 'وافق مقدم الخدمة على طلب حجزك بنجاح.', 'time': 'قبل ساعة'},
    {'icon': 'local_offer', 'title': 'عرض خاص', 'body': 'خصم 10% على باقات التصوير هذا الأسبوع فقط.', 'time': 'أمس'},
    {'icon': 'star_rate', 'title': 'قيّم تجربتك', 'body': 'كيف كانت تجربتك مع آخر حجز لك؟ شاركنا رأيك.', 'time': 'منذ يومين'},
  ];

  static const List<Map<String, String>> _providerDemo = [
    {'icon': 'event_note', 'title': 'طلب حجز جديد', 'body': 'وصلك طلب حجز جديد بانتظار ردّك.', 'time': 'قبل 10 دقائق'},
    {'icon': 'star_rate', 'title': 'تقييم جديد', 'body': 'قيّمك أحد العملاء بـ 5 نجوم.', 'time': 'قبل ساعتين'},
    {'icon': 'local_offer', 'title': 'حملة ترويجية', 'body': 'انضم لحملة موسم الأعراس وزد حجوزاتك.', 'time': 'أمس'},
  ];

  @override
  Widget build(BuildContext context) {
    final isProvider = ModalRoute.of(context)?.settings.arguments == 'provider';
    final data = isProvider ? _providerDemo : _demo;
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: data.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final n = data[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.accent,
                child: CustomIconWidget(iconName: n['icon']!, color: AppTheme.primary, size: 20),
              ),
              title: Text(n['title']!),
              subtitle: Text(n['body']!),
              trailing: Text(n['time']!, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ),
          );
        },
      ),
    );
  }
}
