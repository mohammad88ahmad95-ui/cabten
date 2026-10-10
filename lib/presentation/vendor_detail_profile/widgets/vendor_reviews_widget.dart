import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VendorReviewsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;
  final double averageRating;
  final int totalReviews;

  const VendorReviewsWidget({Key? key, required this.reviews, required this.averageRating, required this.totalReviews}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingSummary(),
          SizedBox(height: 3.h),
          Text("التقييمات والمراجعات", style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 2.h),
          if (reviews.isEmpty)
            _buildEmptyReviews()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) => _buildReviewCard(reviews[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightTheme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(averageRating.toStringAsFixed(1),
                        style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    SizedBox(width: 2.w),
                    Column(
                      children: List.generate(5, (index) => CustomIconWidget(
                          iconName: index < averageRating.floor() ? 'star' : 'star_border', color: AppTheme.warning, size: 16)),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text("بناءً على $totalReviews تقييم", style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(children: [for (var s = 5; s >= 1; s--) _buildRatingBar(s, _count(s))]),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count) {
    final pct = totalReviews > 0 ? count / totalReviews : 0.0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Text("$stars", style: AppTheme.lightTheme.textTheme.labelMedium),
          SizedBox(width: 2.w),
          const CustomIconWidget(iconName: 'star', color: AppTheme.warning, size: 12),
          SizedBox(width: 2.w),
          Expanded(
            child: Container(
              height: 0.8.h,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: pct,
                child: Container(decoration: BoxDecoration(color: AppTheme.warning, borderRadius: BorderRadius.circular(4))),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Text("$count", style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 5.w,
                backgroundColor: AppTheme.accent,
                child: ClipOval(child: AppImage(src: review["userAvatar"] as String?, width: 10.w, height: 10.w)),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review["userName"] as String? ?? "مستخدم", style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Row(children: List.generate(5, (index) => CustomIconWidget(
                            iconName: index < (review["rating"] as int? ?? 5) ? 'star' : 'star_border', color: AppTheme.warning, size: 14))),
                        SizedBox(width: 2.w),
                        Text(review["date"] as String? ?? "", style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(review["comment"] as String? ?? "", style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          const CustomIconWidget(iconName: 'rate_review', color: AppTheme.textSecondary, size: 48),
          SizedBox(height: 2.h),
          Text("لا توجد تقييمات بعد", style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 1.h),
          Text("كن أول من يقيم هذه الخدمة", style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  int _count(int rating) => reviews.where((r) => (r["rating"] as int? ?? 0) == rating).length;
}
