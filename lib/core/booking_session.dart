/// يحفظ مؤقتاً مقدم الخدمة والتاريخ المختارين أثناء التنقل بين
/// صفحة التفاصيل وتدفق الحجز (لأن بعض الأزرار تفتح الحجز بدون معطيات).
class BookingSession {
  BookingSession._();

  static String? vendorId;
  static DateTime? date;

  static void clear() {
    vendorId = null;
    date = null;
  }
}
