import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_wise_app/core/constants/app_colors.dart';
import 'package:split_wise_app/core/constants/app_spacing.dart';
import 'package:split_wise_app/core/constants/strings.dart';
import 'package:split_wise_app/core/widgets/submit_button.dart';
import 'package:split_wise_app/features/expenses/provider/expense_provider.dart';

class ExpenseDetailsScreen extends StatelessWidget {
  final String transactionId;
  final String heroTag;
  final String friendName;
  final String friendPhone;
  final double amount;
  final String splitType;
  final double payerShare;
  final double friendShare;
  final String? note;
  final Timestamp? createdAt;
  final bool settled;

  const ExpenseDetailsScreen({
    super.key,
    required this.transactionId,
    required this.heroTag,
    required this.friendName,
    required this.friendPhone,
    required this.amount,
    required this.splitType,
    required this.payerShare,
    required this.friendShare,
    this.note,
    this.createdAt,
    required this.settled,
  });

  @override
  Widget build(BuildContext context) {
    final date = createdAt?.toDate();
    final trimmedNote = (note ?? '').trim();
    final dateText = date == null
        ? Strings.justNow
        : '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.year}';

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.expenseDetails)),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: AppSpacing.screenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: heroTag,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppSpacing.md(context)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
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
                                Text(
                                  friendName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.xs(context)),
                                Text(friendPhone),
                              ],
                            ),
                          ),
                          Text(
                            '${Strings.rupeePrefix} ${amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg(context)),
                Text('${Strings.splitTypeLabel}: ${splitType == Strings.equal ? Strings.equalLabel : Strings.proportionsLabel}'),
                SizedBox(height: AppSpacing.xs(context)),
                Text('${Strings.youLabel}: ${payerShare.toStringAsFixed(0)}%'),
                SizedBox(height: AppSpacing.xs(context)),
                Text('${Strings.friendLabel}: ${friendShare.toStringAsFixed(0)}%'),
                SizedBox(height: AppSpacing.xs(context)),
                Text('${Strings.createdLabel}: $dateText'),
                SizedBox(height: AppSpacing.xs(context)),
                Text('${Strings.statusLabel}: ${settled ? Strings.settledStatus : Strings.pendingStatus}'),
                SizedBox(height: AppSpacing.md(context)),
                Text(
                  trimmedNote.isEmpty ? Strings.noNoteAdded : trimmedNote,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const Spacer(),
                SubmitButton(
                  text: settled ? Strings.alreadySettled : Strings.settleUp,
                  isLoading: provider.isBusy,
                  onPressed: (settled || provider.isBusy)
                      ? null
                      : () async {
                          final ok = await provider.settleExpense(
                            transactionId: transactionId,
                          );
                          if (!context.mounted) return;
                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(Strings.expenseSettledSuccessfully)),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(provider.error ?? Strings.failedToSettleExpense),
                              ),
                            );
                          }
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}