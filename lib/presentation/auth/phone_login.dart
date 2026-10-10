import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';

/// شاشة تسجيل الدخول برقم الهاتف. يقبل أرقاماً سورية فقط شكلياً
/// (يبدأ بـ 9 ويتكون من 9 أرقام بعد مفتاح الدولة +963).
class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key});

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  final TextEditingController _phone = TextEditingController();
  String? _error;

  bool get _isValid {
    final digits = _phone.text.trim();
    return digits.length == 9 && digits.startsWith('9');
  }

  void _continue() {
    if (!_isValid) {
      setState(() => _error = 'أدخل رقماً سورياً صحيحاً (9 أرقام، يبدأ بـ 9)');
      return;
    }
    setState(() => _error = null);
    Navigator.pushNamed(context, AppRoutes.otpVerify, arguments: '+963${_phone.text.trim()}');
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 40, 24, 44),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset('assets/images/app_logo.png', width: 84, height: 84),
                ),
                const SizedBox(height: 18),
                Text('كابتن بارتي', style: tt.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('سجّل دخولك برقم هاتفك للمتابعة', style: tt.bodyMedium?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text('رقم الهاتف', style: tt.titleMedium),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: _error != null ? AppTheme.error : AppTheme.primaryLight.withOpacity(0.4), width: 1.4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(13)),
                          ),
                          child: const Text('+963', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary)),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.left,
                            maxLength: 9,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                              hintText: '9xxxxxxxx',
                            ),
                            onChanged: (_) => setState(() => _error = null),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(onPressed: _continue, child: const Text('متابعة')),
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      'بالمتابعة أنت توافق على الشروط وسياسة الخصوصية',
                      style: tt.bodySmall?.copyWith(color: AppTheme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
