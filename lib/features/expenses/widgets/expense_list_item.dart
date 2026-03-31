import 'package:flutter/material.dart';
import 'package:split_wise_app/core/constants/app_colors.dart';
import 'package:split_wise_app/core/constants/app_spacing.dart';

class ExpenseListItem extends StatelessWidget {
  final String heroTag;
  final String friendName;
  final double amount;
  final String splitType;
  final double payerShare;
  final double friendShare;
  final String? note;
  final bool settled;
  final VoidCallback? onTap;

  const ExpenseListItem({
    super.key,
    required this.heroTag,
    required this.friendName,
    required this.amount,
    required this.splitType,
    required this.payerShare,
    required this.friendShare,
    this.note,
    this.settled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = splitType == 'equal'
        ? 'Split equally'
        : 'Split by proportion';
    final trimmedNote = (note ?? '').trim();

    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.only(bottom: AppSpacing.md(context)),
            padding: EdgeInsets.all(AppSpacing.md(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.appColor.withOpacity(0.15),
                  child: Text(
                    friendName.isEmpty ? '?' : friendName[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(width: AppSpacing.md(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              friendName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (settled)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Settled',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs(context)),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                      if (trimmedNote.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.xs(context)),
                        Text(
                          trimmedNote,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs ${amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: AppSpacing.xs(context)),
                    Text(
                      'You: ${payerShare.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    Text(
                      'Friend: ${friendShare.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
