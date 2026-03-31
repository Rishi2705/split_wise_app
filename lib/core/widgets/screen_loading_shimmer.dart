import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:split_wise_app/core/constants/app_spacing.dart';

class ScreenLoadingShimmer extends StatelessWidget {
  const ScreenLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md(context)),
        itemBuilder: (context, index) {
          return Container(
            width: double.infinity,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }
}
