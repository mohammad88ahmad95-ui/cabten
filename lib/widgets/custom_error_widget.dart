import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../core/app_export.dart';

/// يظهر هذا الودجت بدلاً من الشاشة الحمراء الافتراضية في فلاتر عند حدوث
/// خطأ غير متوقع أثناء البناء، ليعطي المستخدم تجربة أهدأ وزر "رجوع".
class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;

  const CustomErrorWidget({Key? key, this.errorDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/images/sad_face.svg', height: 48, width: 48),
                const SizedBox(height: 12),
                const Text(
                  'حدث خطأ غير متوقع',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF262626)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'نواجه مشكلة أثناء تحميل هذا الجزء من التطبيق.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Color(0xFF525252)),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.initial, (r) => false);
                    }
                  },
                  icon: const Icon(Icons.arrow_back, size: 18, color: Colors.white),
                  label: const Text('رجوع'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
