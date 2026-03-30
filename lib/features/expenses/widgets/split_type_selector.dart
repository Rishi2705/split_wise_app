import 'package:flutter/material.dart';
import 'package:split_wise_app/core/constants/app_spacing.dart';

class SplitTypeSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const SplitTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            value: 'equal',
            groupValue: value,
            onChanged: onChanged,
            title: const Text('Equal'),
            dense: true,
          ),
        ),
        SizedBox(width: AppSpacing.sm(context)),
        Expanded(
          child: RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            value: 'proportions',
            groupValue: value,
            onChanged: onChanged,
            title: const Text('Proportions'),
            dense: true,
          ),
        ),
      ],
    );
  }
}
