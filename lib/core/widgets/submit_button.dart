import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:split_wise_app/core/constants/app_spacing.dart';

class SubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SubmitButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    return SizedBox(
      width: double.infinity,
      child: isIOS
          ? CupertinoButton.filled(
              onPressed: isLoading ? null : onPressed,
              child: isLoading
                  ? const CupertinoActivityIndicator()
                  : Text(
                      text,
                      style: const TextStyle(color: Colors.white),
                    ),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              child: isLoading
                  ? SizedBox(
                      height: AppSpacing.lg(context),
                      width: AppSpacing.lg(context),
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(text),
            ),
    );
  }
}