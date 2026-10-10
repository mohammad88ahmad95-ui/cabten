import 'package:shared_preferences/shared_preferences.dart';

/// جلسة تسجيل دخول مبسّطة لمرحلة النسخة التجريبية:
/// يقبل أي رقم هاتف سوري وأي رمز تحقق، ويحفظ حالة الدخول على الجهاز.
/// لاحقاً عند ربط خادم حقيقي، يكفي استبدال verifyCode() بنداء API فعلي.
class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  static const _keyLoggedIn = 'auth_logged_in';
  static const _keyPhone = 'auth_phone';

  bool isLoggedIn = false;
  String phone = '';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    phone = prefs.getString(_keyPhone) ?? '';
  }

  /// وضع تجريبي: يقبل أي رمز تحقق غير فارغ.
  Future<bool> verifyCode({required String phoneNumber, required String code}) async {
    if (code.trim().isEmpty) return false;
    isLoggedIn = true;
    phone = phoneNumber;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyPhone, phoneNumber);
    return true;
  }

  Future<void> logout() async {
    isLoggedIn = false;
    phone = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyPhone);
  }
}
