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
import 'package:split_wise_app/features/group/provider/group_provider.dart';
import 'package:split_wise_app/features/group/widgets/group_expense_tile.dart';
import 'package:split_wise_app/features/group/widgets/group_list_tile.dart';

class GroupsScreens extends StatelessWidget {
  const GroupsScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return const _GroupsView();
  }
}

class _GroupsView extends StatelessWidget {
  const _GroupsView();

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: const CommonAppBar(title: Strings.groupsTitle),
          body: SafeArea(
            child: Padding(
              padding: AppSpacing.screenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Strings.groupsSubtitle,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: AppSpacing.lg(context)),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: provider.watchGroups(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ScreenLoadingShimmer();
                        }

                        final groups = snapshot.data?.docs.toList() ?? [];
                        groups.sort((a, b) {
                          final aAt = a.data()['updatedAt'] as Timestamp?;
                          final bAt = b.data()['updatedAt'] as Timestamp?;
                          final aMs = aAt?.millisecondsSinceEpoch ?? 0;
                          final bMs = bAt?.millisecondsSinceEpoch ?? 0;
                          return bMs.compareTo(aMs);
                        });

                        if (groups.isEmpty) {
                          return _buildEmptyState(context);
                        }

                        return ListView.separated(
                          itemCount: groups.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: AppSpacing.md(context)),
                          itemBuilder: (context, index) {
                            final data = groups[index].data();
                            final groupId = groups[index].id;
                            final memberPhones =
                                (data['memberPhones'] as List<dynamic>? ?? [])
                                    .map((e) => e.toString())
                                    .toList();
                            return GroupListTile(
                              groupName:
                                  (data['name'] ?? Strings.defaultGroupName)
                                      .toString(),
                              memberCount: memberPhones.length,
                              onTap: () => _showGroupDetails(
                                context,
                                groupId: groupId,
                                groupName:
                                    (data['name'] ?? Strings.defaultGroupName)
                                        .toString(),
                                memberPhones: memberPhones,
                              ),
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
            onPressed: provider.isBusy
                ? null
                : () => _showCreateGroupSheet(context),
            backgroundColor: AppColors.appColor,
            foregroundColor: Colors.white,
            icon: const Icon(AppIcons.groupAddIcon),
            label: const Text(Strings.createGroup),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.groupNameIcon, size: 56, color: Colors.grey.shade400),
          SizedBox(height: AppSpacing.md(context)),
          const Text(
            Strings.noGroupsYet,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.sm(context)),
          Text(
            Strings.createGroupHint,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateGroupSheet(BuildContext context) async {
    final groupProvider = context.read<GroupProvider>();
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final selected = <String, String>{};

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return ChangeNotifierProvider.value(
          value: groupProvider,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.lg(context),
                  right: AppSpacing.lg(context),
                  top: AppSpacing.lg(context),
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom +
                      AppSpacing.lg(context),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        Strings.createGroupTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md(context)),
                      CommonTextField(
                        labelText: Strings.groupNameLabel,
                        hintText: Strings.groupNameHint,
                        controller: nameController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? Strings.groupNameRequired
                            : null,
                      ),
                      SizedBox(height: AppSpacing.md(context)),
                      const Text(
                        Strings.selectMembers,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: AppSpacing.sm(context)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final provider = context.read<GroupProvider>();
                            final picked = await FriendContactPickerSheet.show(
                              context: context,
                              watchFriends: provider.watchFriends,
                              loadContacts: provider.loadContacts,
                              contacts: () => provider.contacts,
                              addFriendFromContact:
                                  provider.addFriendFromContact,
                              errorMessage: () => provider.error,
                              accentColor: AppColors.appColor,
                              emptyFriendsMessage: Strings.noFriendsYet,
                            );

                            if (!context.mounted || picked == null) return;
                            final phone = (picked['friendPhone'] ?? '')
                                .toString();
                            final name =
                                (picked['friendName'] ??
                                        Strings.defaultFriendName)
                                    .toString();
                            if (phone.isEmpty) return;

                            setSheetState(() {
                              selected[phone] = name;
                            });
                          },
                          icon: const Icon(AppIcons.personAddAltIcon),
                          label: const Text(Strings.addMember),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs(context)),
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.26,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: selected.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(Strings.noMembersSelectedYet),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: selected.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final phone = selected.keys.elementAt(index);
                                  final name =
                                      selected[phone] ??
                                      Strings.defaultFriendName;
                                  return ListTile(
                                    dense: true,
                                    title: Text(name),
                                    subtitle: Text(phone),
                                    trailing: IconButton(
                                      icon: const Icon(AppIcons.closeIcon),
                                      onPressed: () {
                                        setSheetState(() {
                                          selected.remove(phone);
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                      SizedBox(height: AppSpacing.md(context)),
                      Consumer<GroupProvider>(
                        builder: (context, provider, _) {
                          return SubmitButton(
                            text: Strings.createGroup,
                            isLoading: provider.isBusy,
                            onPressed: provider.isBusy
                                ? null
                                : () async {
                                    if (!(formKey.currentState?.validate() ??
                                        false))
                                      return;
                                    if (selected.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            Strings
                                                .pleaseSelectAtLeastOneMember,
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final success = await provider.createGroup(
                                      groupName: nameController.text.trim(),
                                      selectedMembers: selected.entries
                                          .map(
                                            (e) => {
                                              'phone': e.key,
                                              'name': e.value,
                                            },
                                          )
                                          .toList(),
                                    );
                                    if (!context.mounted) return;
                                    if (success) {
                                      Navigator.pop(sheetContext);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            provider.error ??
                                                Strings.failedToCreateGroup,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showGroupDetails(
    BuildContext context, {
    required String groupId,
    required String groupName,
    required List<String> memberPhones,
  }) async {
    final groupProvider = context.read<GroupProvider>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return ChangeNotifierProvider.value(
          value: groupProvider,
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.86,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg(sheetContext)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs(sheetContext)),
                  Text(
                    '${memberPhones.length} member${memberPhones.length == 1 ? '' : 's'}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: AppSpacing.md(sheetContext)),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: sheetContext
                          .read<GroupProvider>()
                          .watchGroupExpenses(groupId),
                      builder: (innerContext, snapshot) {
                        final docs = snapshot.data?.docs.toList() ?? [];
                        docs.sort((a, b) {
                          final aAt = a.data()['createdAt'] as Timestamp?;
                          final bAt = b.data()['createdAt'] as Timestamp?;
                          final aMs = aAt?.millisecondsSinceEpoch ?? 0;
                          final bMs = bAt?.millisecondsSinceEpoch ?? 0;
                          return bMs.compareTo(aMs);
                        });

                        if (docs.isEmpty) {
                          return const Center(
                            child: Text(Strings.noGroupExpensesYet),
                          );
                        }

                        return ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: AppSpacing.md(innerContext)),
                          itemBuilder: (innerContext, index) {
                            final data = docs[index].data();
                            return GroupExpenseTile(
                              amount: (data['amount'] as num?)?.toDouble() ?? 0,
                              splitType: (data['splitType'] ?? Strings.equal)
                                  .toString(),
                              note: data['note']?.toString(),
                              createdAt: data['createdAt'] as Timestamp?,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: AppSpacing.md(sheetContext)),
                  SubmitButton(
                    text: Strings.addGroupExpense,
                    onPressed: () => _showAddGroupExpenseSheet(
                      sheetContext,
                      groupId: groupId,
                      groupName: groupName,
                      memberPhones: memberPhones,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddGroupExpenseSheet(
    BuildContext context, {
    required String groupId,
    required String groupName,
    required List<String> memberPhones,
  }) async {
    final groupProvider = context.read<GroupProvider>();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final creatorPercentController = TextEditingController(text: '50');
    String splitType = Strings.equal;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return ChangeNotifierProvider.value(
          value: groupProvider,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.lg(context),
                  right: AppSpacing.lg(context),
                  top: AppSpacing.lg(context),
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom +
                      AppSpacing.lg(context),
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          Strings.addGroupExpenseTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md(context)),
                        CommonTextField(
                          labelText: Strings.amountLabel,
                          hintText: Strings.enterAmount,
                          keyboardType: TextInputType.number,
                          controller: amountController,
                          validator: (v) {
                            final parsed = double.tryParse((v ?? '').trim());
                            if (parsed == null || parsed <= 0)
                              return Strings.enterValidAmountSimple;
                            return null;
                          },
                        ),
                        SizedBox(height: AppSpacing.md(context)),
                        const Text(Strings.splitType),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: const Text(Strings.equalLabel),
                                value: Strings.equal,
                                groupValue: splitType,
                                onChanged: (v) {
                                  setSheetState(
                                    () => splitType = v ?? Strings.equal,
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: const Text(Strings.proportionsLabel),
                                value: Strings.proportions,
                                groupValue: splitType,
                                onChanged: (v) {
                                  setSheetState(
                                    () => splitType = v ?? Strings.equal,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        if (splitType == Strings.proportions) ...[
                          CommonTextField(
                            labelText: Strings.yourPercent,
                            hintText: Strings.hintOneToNinetyNine,
                            keyboardType: TextInputType.number,
                            controller: creatorPercentController,
                            validator: (v) {
                              final parsed = double.tryParse((v ?? '').trim());
                              if (parsed == null ||
                                  parsed <= 0 ||
                                  parsed >= 100) {
                                return Strings.enterPercentOneToNinetyNine;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.md(context)),
                        ],
                        CommonTextField(
                          labelText: Strings.noteOptional,
                          hintText: Strings.noteGroupHint,
                          controller: noteController,
                        ),
                        SizedBox(height: AppSpacing.lg(context)),
                        Consumer<GroupProvider>(
                          builder: (context, provider, _) {
                            return SubmitButton(
                              text: Strings.saveExpense,
                              isLoading: provider.isBusy,
                              onPressed: provider.isBusy
                                  ? null
                                  : () async {
                                      if (!(formKey.currentState?.validate() ??
                                          false))
                                        return;
                                      final amount = double.parse(
                                        amountController.text.trim(),
                                      );
                                      final double creatorPercent =
                                          splitType == Strings.equal
                                          ? 0.0
                                          : double.parse(
                                              creatorPercentController.text
                                                  .trim(),
                                            );

                                      final ok = await provider.addGroupExpense(
                                        groupId: groupId,
                                        groupName: groupName,
                                        memberPhones: memberPhones,
                                        amount: amount,
                                        splitType: splitType,
                                        creatorPercent: creatorPercent,
                                        note: noteController.text.trim().isEmpty
                                            ? null
                                            : noteController.text.trim(),
                                      );

                                      if (!context.mounted) return;
                                      if (ok) {
                                        Navigator.pop(sheetContext);
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              provider.error ??
                                                  Strings.failedToAddExpense,
                                            ),
                                          ),
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
          ),
        );
      },
    );
  }
}
