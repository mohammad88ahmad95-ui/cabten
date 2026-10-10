import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart';
import '../../core/auth_session.dart';

/// شاشة إدخال رمز التحقق (OTP).
/// نسخة تجريبية: تقبل أي رمز من 4 أرقام فأكثر دون إرسال فعلي عبر SMS.
class OtpVerify extends StatefulWidget {
  const OtpVerify({super.key});

  @override
  State<OtpVerify> createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  final TextEditingController _code = TextEditingController();
  String _phone = '';
  bool _loading = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    _phone = args is String ? args : '';
  }

  Future<void> _verify() async {
    if (_code.text.trim().length < 4) {
      Fluttertoast.showToast(msg: 'أدخل رمز التحقق المكوّن من 4 أرقام على الأقل');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    final ok = await AuthSession.instance.verifyCode(phoneNumber: _phone, code: _code.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.roleSelection, (r) => false);
    } else {
      Fluttertoast.showToast(msg: 'رمز غير صحيح، حاول مرة أخرى');
    }
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('رمز التحقق')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(gradient: AppTheme.primaryGradient, shape: BoxShape.circle),
              child: const Icon(Icons.sms_outlined, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 20),
            Text('تم إرسال رمز التحقق', style: tt.titleLarge),
            const SizedBox(height: 6),
            Text(
              _phone.isEmpty ? 'إلى رقم هاتفك' : 'إلى الرقم $_phone',
              style: tt.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 26, letterSpacing: 10, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(counterText: '', hintText: '• • • •'),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'نسخة تجريبية: أدخل أي رمز لإتمام الدخول.',
                      style: tt.bodySmall?.copyWith(color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('تأكيد'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Fluttertoast.showToast(msg: 'تم إرسال رمز جديد'),
                child: const Text('إعادة إرسال الرمز'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
