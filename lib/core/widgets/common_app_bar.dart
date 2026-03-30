import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_wise_app/core/constants/app_spacing.dart';
import 'package:split_wise_app/core/Theme/theme_provider.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final VoidCallback? onLeadingPressed;

  const CommonAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.onLeadingPressed,
  });

  @override
  Widget build(BuildContext context) {
    final appBarTheme = context.watch<AppThemeProvider>().appBarTheme;

    return AppBar(
      title: Text(title,style: Theme.of(context).textTheme.titleLarge,),
      centerTitle: centerTitle,
      leading: leading != null
          ? Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm(context)),
        child: leading,
      )
          : null,
      actions: actions?.map((action) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm(context)),
          child: action,
        );
      }).toList(),
      elevation: 1,
      backgroundColor: appBarTheme.backgroundColor,
      foregroundColor: appBarTheme.foregroundColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}