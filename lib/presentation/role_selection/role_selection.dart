import 'package:flutter/material.dart';

import '../../core/app_export.dart';

class RoleSelection extends StatelessWidget {
  const RoleSelection({super.key});

  Widget _roleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final tt = Theme.of(context).textTheme;
    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: AppTheme.shadowLight,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: tt.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: tt.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: AppTheme.primaryLight),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 32, 24, 36),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset('assets/images/app_logo.png',
                      width: 76, height: 76),
                ),
                const SizedBox(height: 16),
                Text(
                  'أهلاً بك في كابتن بارتي',
                  style: tt.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'اختر كيف تريد المتابعة',
                  style: tt.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _roleCard(
                    context,
                    icon: Icons.celebration,
                    title: 'أنا أخطط لمناسبة',
                    subtitle: 'تصفّح القاعات والخدمات واحجز بسهولة',
                    onTap: () => Navigator.pushReplacementNamed(
                        context, AppRoutes.home),
                  ),
                  const SizedBox(height: 16),
                  _roleCard(
                    context,
                    icon: Icons.storefront,
                    title: 'أنا مقدم خدمة',
                    subtitle: 'سجّل خدمتك وأدِر حجوزاتك وتقاريرك',
                    onTap: () {
                      final has = AppData.instance
                          .vendorsForOwner(AuthSession.instance.phone)
                          .isNotEmpty;
                      Navigator.pushReplacementNamed(
                          context,
                          has
                              ? AppRoutes.providerHome
                              : AppRoutes.providerOnboarding);
                    },
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () async {
                      await AuthSession.instance.logout();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                          context, AppRoutes.phoneLogin, (r) => false);
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('تسجيل الخروج'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
