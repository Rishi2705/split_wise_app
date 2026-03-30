import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_wise_app/core/constants/app_icons.dart';
import 'package:split_wise_app/core/constants/app_colors.dart';
import 'package:split_wise_app/core/constants/app_spacing.dart';
import 'package:split_wise_app/core/constants/strings.dart';
import 'package:split_wise_app/features/activity_track/provider/activity_provider.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ActivityProvider()..init(),
      child: Consumer<ActivityProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.currentUserPhone == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: AppSpacing.screenPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.activityTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm(context)),
                    Text(
                      Strings.activitySubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg(context)),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: provider.watchTransactions(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final docs = snapshot.data?.docs ?? [];
                          final sorted = docs.toList()
                            ..sort((a, b) {
                              final aAt = a.data()['createdAt'] as Timestamp?;
                              final bAt = b.data()['createdAt'] as Timestamp?;
                              final aMs = aAt?.millisecondsSinceEpoch ?? 0;
                              final bMs = bAt?.millisecondsSinceEpoch ?? 0;
                              return bMs.compareTo(aMs);
                            });

                          if (sorted.isEmpty) {
                            return _buildEmptyState(context);
                          }

                          return ListView.separated(
                            itemCount: sorted.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: AppSpacing.md(context)),
                            itemBuilder: (context, index) {
                              final data = sorted[index].data();
                              return _TransactionTile(
                                amount: (data['amount'] as num?)?.toDouble() ?? 0,
                                type: (data['type'] ?? Strings.expenseTypeLabel.toLowerCase()).toString(),
                                note: data['note']?.toString(),
                                createdBy: (data['createdBy'] ?? '').toString(),
                                currentUserPhone: provider.currentUserPhone ?? '',
                                participants: (data['participants'] as List<dynamic>? ?? [])
                                    .map((e) => e.toString())
                                    .toList(),
                                createdAt: data['createdAt'] as Timestamp?,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if ((provider.error ?? '').isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: AppSpacing.sm(context)),
                        child: Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.timelineIcon, size: 56, color: Colors.grey.shade400),
          SizedBox(height: AppSpacing.md(context)),
          const Text(
            Strings.noActivityYet,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.sm(context)),
          Text(
            Strings.noActivityDescription,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final double amount;
  final String type;
  final String? note;
  final String createdBy;
  final String currentUserPhone;
  final List<String> participants;
  final Timestamp? createdAt;

  const _TransactionTile({
    required this.amount,
    required this.type,
    required this.note,
    required this.createdBy,
    required this.currentUserPhone,
    required this.participants,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final isCreatedByMe = createdBy == currentUserPhone;
    final effectiveType = type.toLowerCase();
    final isExpense = effectiveType == Strings.expenseTypeLabel.toLowerCase();
    final signPrefix = isExpense
        ? (isCreatedByMe ? '+' : '-')
        : (isCreatedByMe ? '-' : '+');
    final amountColor = signPrefix == '+' ? Colors.green : Colors.red;

    final timestampText = createdAt == null
      ? Strings.justNow
        : _formatDate(createdAt!.toDate());

    final subtitleParts = <String>[
      isExpense ? Strings.expenseTypeLabel : Strings.settlementTypeLabel,
      '${participants.length} participant${participants.length == 1 ? '' : 's'}',
    ];

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
              color: AppColors.appColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isExpense ? AppIcons.receiptLongIcon : AppIcons.swapHorizIcon,
              color: AppColors.appColor,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitleParts.join(' • '),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: AppSpacing.xs(context)),
                Text(
                  note?.trim().isNotEmpty == true ? note!.trim() : Strings.noNote,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs(context)),
                Text(
                  timestampText,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            '$signPrefix ${Strings.rupeePrefix} ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y  $hh:$mm';
  }
}
