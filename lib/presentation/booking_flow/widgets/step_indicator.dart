import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;

  const StepIndicator({Key? key, required this.currentStep, required this.totalSteps, required this.stepTitles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [BoxShadow(color: AppTheme.shadowLight, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 0.5.h,
                        decoration: BoxDecoration(
                          color: isCompleted || isCurrent ? AppTheme.primary : AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < totalSteps - 1) SizedBox(width: 1.w),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: (isCompleted || isCurrent) ? AppTheme.primary : AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: isCurrent ? Border.all(color: AppTheme.primary, width: 2) : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const CustomIconWidget(iconName: 'check', color: Colors.white, size: 16)
                            : Text('${index + 1}',
                                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                  color: isCurrent ? Colors.white : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                )),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      stepTitles[index],
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: (isCurrent || isCompleted) ? AppTheme.primary : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
