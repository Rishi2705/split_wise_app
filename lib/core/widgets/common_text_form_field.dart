import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:split_wise_app/core/constants/app_colors.dart';
import 'package:split_wise_app/core/constants/app_icons.dart';
import 'package:split_wise_app/core/constants/app_spacing.dart';

class CommonTextField extends StatefulWidget {

  final String labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldSetter<String>? onSaved;
  final TextEditingController? controller;

  const CommonTextField({
    super.key,

    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onSaved,
    this.controller,

  });

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant CommonTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _isObscured = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final resolvedPrefixIcon = widget.prefixIcon ?? _buildDefaultPrefixIcon(context);
    final resolvedSuffixIcon = _buildResolvedSuffixIcon(context);

    if (isIOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.labelText,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.xs(context)),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              CupertinoTextFormFieldRow(
                controller: widget.controller,
                placeholder: widget.hintText,
                obscureText: _isObscured,
                keyboardType: widget.keyboardType,
                validator: widget.validator,
                onSaved: widget.onSaved,
                prefix: resolvedPrefixIcon == null
                    ? null
                    : Padding(
                        padding: EdgeInsets.only(
                          left: AppSpacing.md(context),
                          right: AppSpacing.sm(context),
                        ),
                        child: resolvedPrefixIcon,
                      ),
                padding: EdgeInsets.only(
                  left: AppSpacing.md(context),
                  right: resolvedSuffixIcon == null ? AppSpacing.md(context) : AppSpacing.xxl(context),
                  top: AppSpacing.md(context),
                  bottom: AppSpacing.md(context),
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CupertinoColors.systemGrey4),
                ),
              ),
              if (resolvedSuffixIcon != null)
                Padding(
                  padding: EdgeInsets.only(right: AppSpacing.sm(context)),
                  child: resolvedSuffixIcon,
                ),
            ],
          ),
        ],
      );
    }

    return TextFormField(

      controller: widget.controller,
      obscureText: _isObscured,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onSaved: widget.onSaved,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        contentPadding: EdgeInsets.symmetric(
          vertical: AppSpacing.md(context),
          horizontal: AppSpacing.md(context),
        ),
        prefixIcon: resolvedPrefixIcon,
        suffixIcon: resolvedSuffixIcon,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.appColor,
            width: AppSpacing.textFormFieldBorder(context),
          ),
        ),
      ),
    );
  }

  Widget? _buildResolvedSuffixIcon(BuildContext context) {
    if (_isPasswordField) {
      final icon = _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined;
      return IconButton(
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
        icon: Icon(icon, size: AppSpacing.lg(context)),
        color: Colors.grey.shade600,
        splashRadius: AppSpacing.lg(context),
      );
    }

    return widget.suffixIcon;
  }

  bool get _isPasswordField {
    final normalizedLabel = widget.labelText.toLowerCase();
    return widget.obscureText || normalizedLabel.contains('password');
  }

  Widget? _buildDefaultPrefixIcon(BuildContext context) {
    final iconData = _resolveDefaultIconData();
    if (iconData == null) return null;

    return Icon(
      iconData,
      size: AppSpacing.lg(context),
      color: Colors.grey.shade600,
    );
  }

  IconData? _resolveDefaultIconData() {
    final normalizedLabel = widget.labelText.toLowerCase();

    if (widget.obscureText || normalizedLabel.contains('password')) {
      return AppIcons.passwordIcon;
    }
    if (widget.keyboardType == TextInputType.emailAddress || normalizedLabel.contains('email')) {
      return AppIcons.emailIcon;
    }
    if (widget.keyboardType == TextInputType.phone || normalizedLabel.contains('phone')) {
      return AppIcons.phoneIcon;
    }
    if (normalizedLabel.contains('amount') || normalizedLabel.contains('bill')) {
      return AppIcons.amountIcon;
    }
    if (normalizedLabel.contains('%') || normalizedLabel.contains('percent')) {
      return AppIcons.percentIcon;
    }
    if (normalizedLabel.contains('note')) {
      return AppIcons.noteIcon;
    }
    if (normalizedLabel.contains('group')) {
      return AppIcons.groupNameIcon;
    }
    if (normalizedLabel.contains('name')) {
      return AppIcons.nameIcon;
    }

    return null;
  }
}
