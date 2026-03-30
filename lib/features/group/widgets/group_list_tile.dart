import 'package:flutter/material.dart';
import 'package:split_wise_app/core/constants/app_colors.dart';
import 'package:split_wise_app/core/constants/app_spacing.dart';

class GroupListTile extends StatelessWidget {
  final String groupName;
  final int memberCount;
  final VoidCallback onTap;

  const GroupListTile({
    super.key,
    required this.groupName,
    required this.memberCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.appColor.withOpacity(0.14),
              child: Text(
                groupName.isEmpty ? '?' : groupName[0].toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(width: AppSpacing.md(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: AppSpacing.xs(context)),
                  Text(
                    '$memberCount member${memberCount == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
