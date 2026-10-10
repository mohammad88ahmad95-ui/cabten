import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BookingSearchWidget extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  const BookingSearchWidget({Key? key, required this.onSearchChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: const InputDecoration(
          hintText: 'ابحث باسم العميل أو مقدم الخدمة أو نوع الخدمة...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
