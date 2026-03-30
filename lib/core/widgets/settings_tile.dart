import 'package:flutter/material.dart';
import 'package:split_wise_app/core/constants/app_spacing.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? leadingColor;
  final bool isDestructive;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.leadingColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg(context),
        vertical: AppSpacing.sm(context),
      ),
      leading: leading != null
          ? Icon(
              leading,
              color: isDestructive
                  ? Colors.red
                  : (leadingColor ?? Theme.of(context).primaryColor),
              size: 24,
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
