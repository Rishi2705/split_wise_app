import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_wise_app/core/constants/app_colors.dart';
import 'package:split_wise_app/core/constants/app_icons.dart';
import 'package:split_wise_app/core/constants/app_spacing.dart';
import 'package:split_wise_app/core/constants/strings.dart';
import 'package:split_wise_app/core/widgets/common_app_bar.dart';
import 'package:split_wise_app/core/widgets/common_text_form_field.dart';
import 'package:split_wise_app/core/widgets/friend_contact_picker_sheet.dart';
import 'package:split_wise_app/core/widgets/screen_loading_shimmer.dart';
import 'package:split_wise_app/core/widgets/submit_button.dart';
import 'package:split_wise_app/features/expenses/provider/expense_provider.dart';
import 'package:split_wise_app/features/expenses/screens/expense_details_screen.dart';
import 'package:split_wise_app/features/expenses/widgets/expense_list_item.dart';
import 'package:split_wise_app/features/expenses/widgets/split_type_selector.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _payerPercentController = TextEditingController(text: '50');
  final _friendPercentController = TextEditingController(text: '50');

  String _splitType = Strings.equal;
  Map<String, dynamic>? _selectedFriend;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().init();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _payerPercentController.dispose();
    _friendPercentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: const CommonAppBar(title: Strings.expensesTitle),
          body: SafeArea(
            child: Padding(
              padding: AppSpacing.screenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: AppSpacing.md(context)),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: provider.watchExpenses(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const ScreenLoadingShimmer();
                        }

                        final docs = snapshot.data?.docs ?? [];
                        final expenseDocs = docs
                            .where(
                              (d) =>
                                  (d.data()['type'] ?? Strings.expenseTypeLabel.toLowerCase()) ==
                                      Strings.expenseTypeLabel.toLowerCase() &&
                                  d.data()['settled'] != true,
                            )
                            .toList()
                          ..sort((a, b) {
                            final aAt = a.data()['createdAt'] as Timestamp?;
                            final bAt = b.data()['createdAt'] as Timestamp?;
                            final aMs = aAt?.millisecondsSinceEpoch ?? 0;
                            final bMs = bAt?.millisecondsSinceEpoch ?? 0;
                            return bMs.compareTo(aMs);
                          });

                        if (expenseDocs.isEmpty) {
                          return _buildEmptyState(context);
                        }

                        return ListView.builder(
                          itemCount: expenseDocs.length,
                          itemBuilder: (context, index) {
                            final doc = expenseDocs[index];
                            final data = expenseDocs[index].data();
                            final heroTag = 'expense-card-${doc.id}';
                            return ExpenseListItem(
                              heroTag: heroTag,
                              friendName: (data['friendName'] ?? Strings.defaultFriendName).toString(),
                              amount: (data['amount'] as num?)?.toDouble() ?? 0,
                              splitType: (data['splitType'] ?? Strings.equal).toString(),
                              payerShare: (data['payerShare'] as num?)?.toDouble() ?? 50,
                              friendShare: (data['friendShare'] as num?)?.toDouble() ?? 50,
                              note: data['note']?.toString(),
                              settled: data['settled'] == true,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ExpenseDetailsScreen(
                                      transactionId: doc.id,
                                      heroTag: heroTag,
                                      friendName: (data['friendName'] ?? Strings.defaultFriendName).toString(),
                                      friendPhone: (data['friendPhone'] ?? '').toString(),
                                      amount: (data['amount'] as num?)?.toDouble() ?? 0,
                                      splitType: (data['splitType'] ?? Strings.equal).toString(),
                                      payerShare: (data['payerShare'] as num?)?.toDouble() ?? 50,
                                      friendShare: (data['friendShare'] as num?)?.toDouble() ?? 50,
                                      note: data['note']?.toString(),
                                      createdAt: data['createdAt'] as Timestamp?,
                                      settled: data['settled'] == true,
                                    ),
                                  ),
                                );
                              },
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
                        provider.error ?? '',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: provider.isBusy ? null : () => _showAddExpenseSheet(context),
            backgroundColor: AppColors.appColor,
            foregroundColor: Colors.white,
            icon: const Icon(AppIcons.receiptLongIcon),
            label: const Text(Strings.addExpense),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.receiptLongIcon, size: 56, color: Colors.grey.shade400),
          SizedBox(height: AppSpacing.md(context)),
          const Text(
            Strings.noExpensesYet,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.sm(context)),
          Text(
            Strings.addExpenseHint,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddExpenseSheet(BuildContext context) async {
    _formKey.currentState?.reset();
    _amountController.clear();
    _noteController.clear();
    _payerPercentController.text = '50';
    _friendPercentController.text = '50';
    _splitType = Strings.equal;
    _selectedFriend = null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.lg(context),
                right: AppSpacing.lg(context),
                top: AppSpacing.lg(context),
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg(context),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        Strings.addBillToFriend,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: AppSpacing.md(context)),
                      _buildFriendPickerField(
                        context: context,
                        selectedFriend: _selectedFriend,
                        onPick: () async {
                          final picked = await _showFriendPicker(context);
                          if (picked != null) {
                            setModalState(() {
                              _selectedFriend = picked;
                            });
                          }
                        },
                      ),
                      SizedBox(height: AppSpacing.md(context)),
                      CommonTextField(
                        labelText: Strings.billAmountLabel,
                        hintText: Strings.enterAmount,
                        keyboardType: TextInputType.number,
                        controller: _amountController,
                        validator: (value) {
                          final parsed = double.tryParse((value ?? '').trim());
                          if (parsed == null || parsed <= 0) {
                            return Strings.enterValidAmount;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.md(context)),
                      const Text(Strings.splitType),
                      SplitTypeSelector(
                        value: _splitType,
                        onChanged: (value) {
                          setModalState(() {
                            _splitType = value ?? Strings.equal;
                            if (_splitType == Strings.equal) {
                              _payerPercentController.text = '50';
                              _friendPercentController.text = '50';
                            }
                          });
                        },
                      ),
                      if (_splitType == Strings.proportions) ...[
                        Row(
                          children: [
                            Expanded(
                              child: CommonTextField(
                                labelText: Strings.yourPercent,
                                keyboardType: TextInputType.number,
                                controller: _payerPercentController,
                                validator: (value) {
                                  final v = double.tryParse((value ?? '').trim());
                                  if (v == null || v < 0 || v > 100) {
                                    return Strings.valueRange0To100;
                                  }
                                  final friendV = double.tryParse(_friendPercentController.text.trim()) ?? -1;
                                  if ((v + friendV).toStringAsFixed(2) != '100.00') {
                                    return Strings.sumMustBe100;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: AppSpacing.md(context)),
                            Expanded(
                              child: CommonTextField(
                                labelText: Strings.friendPercent,
                                keyboardType: TextInputType.number,
                                controller: _friendPercentController,
                                validator: (value) {
                                  final v = double.tryParse((value ?? '').trim());
                                  if (v == null || v < 0 || v > 100) {
                                    return Strings.valueRange0To100;
                                  }
                                  final meV = double.tryParse(_payerPercentController.text.trim()) ?? -1;
                                  if ((v + meV).toStringAsFixed(2) != '100.00') {
                                    return Strings.sumMustBe100;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.md(context)),
                      ],
                      CommonTextField(
                        labelText: Strings.noteOptional,
                        hintText: Strings.noteExpenseHint,
                        controller: _noteController,
                      ),
                      SizedBox(height: AppSpacing.lg(context)),
                      Consumer<ExpenseProvider>(
                        builder: (context, provider, _) {
                          return SubmitButton(
                            text: Strings.saveExpense,
                            isLoading: provider.isBusy,
                            onPressed: provider.isBusy
                                ? null
                                : () async {
                                    if (_selectedFriend == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text(Strings.pleaseChooseFriend)),
                                      );
                                      return;
                                    }
                                    if (!(_formKey.currentState?.validate() ?? false)) {
                                      return;
                                    }

                                    final amount = double.parse(_amountController.text.trim());
                  final payerPercent = _splitType == Strings.equal
                                        ? 50.0
                                        : double.parse(_payerPercentController.text.trim());
                  final friendPercent = _splitType == Strings.equal
                                        ? 50.0
                                        : double.parse(_friendPercentController.text.trim());

                                    final success = await provider.addExpense(
                                      friendPhone: _selectedFriend!['friendPhone'] as String,
                                      friendName: _selectedFriend!['friendName'] as String,
                                      amount: amount,
                                      splitType: _splitType,
                                      payerShare: payerPercent,
                                      friendShare: friendPercent,
                                      note: _noteController.text.trim().isEmpty
                                          ? null
                                          : _noteController.text.trim(),
                                    );

                                    if (!mounted) return;
                                    if (success) {
                                      Navigator.pop(sheetContext);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(provider.error ?? Strings.failedToSaveExpense)),
                                      );
                                    }
                                  },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFriendPickerField({
    required BuildContext context,
    required Map<String, dynamic>? selectedFriend,
    required VoidCallback onPick,
  }) {
    return InkWell(
      onTap: onPick,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md(context),
          vertical: AppSpacing.md(context),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(AppIcons.personSearchIcon, color: AppColors.appColor),
            SizedBox(width: AppSpacing.sm(context)),
            Expanded(
              child: Text(
                selectedFriend == null
                    ? Strings.chooseFriend
                    : '${selectedFriend['friendName']} (${selectedFriend['friendPhone']})',
                style: TextStyle(
                  color: selectedFriend == null ? Colors.grey.shade600 : Colors.black87,
                ),
              ),
            ),
            const Icon(AppIcons.keyboardArrowDownIcon),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showFriendPicker(BuildContext context) async {
    final provider = context.read<ExpenseProvider>();
    return FriendContactPickerSheet.show(
      context: context,
      watchFriends: provider.watchFriends,
      loadContacts: provider.loadContacts,
      contacts: () => provider.contacts,
      addFriendFromContact: provider.addFriendFromContact,
      errorMessage: () => provider.error,
      accentColor: AppColors.appColor,
      emptyFriendsMessage: Strings.noFriendsYet,
    );
  }
}
