import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:split_wise_app/core/constants/app_colors.dart';
import 'package:split_wise_app/core/constants/app_spacing.dart';

class GroupExpenseTile extends StatelessWidget {
  final double amount;
  final String splitType;
  final String? note;
  final Timestamp? createdAt;

  const GroupExpenseTile({
    super.key,
    required this.amount,
    required this.splitType,
    this.note,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final label = splitType == 'equal' ? 'Equal split' : 'Proportions split';
    final createdDate = createdAt?.toDate();
    final dateText = createdDate == null
        ? 'Just now'
      : '${createdDate.day.toString().padLeft(2, '0')}/'
        '${createdDate.month.toString().padLeft(2, '0')}/'
        '${createdDate.year}';
    final trimmedNote = note?.trim() ?? '';

    return Container(
      padding: EdgeInsets.all(AppSpacing.md(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.appColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.receipt_long, color: AppColors.appColor, size: 20),
          ),
          SizedBox(width: AppSpacing.md(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppSpacing.xs(context)),
                Text(
                  trimmedNote.isNotEmpty ? trimmedNote : 'No note',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                SizedBox(height: AppSpacing.xs(context)),
                Text(
                  dateText,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            'Rs ${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
