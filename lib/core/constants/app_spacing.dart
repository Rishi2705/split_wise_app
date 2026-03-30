import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double _baseWidth = 375.0;
  static const double _minScale = 0.9;
  static const double _maxScale = 1.2;

  static double _scale(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final raw = width / _baseWidth;
    return raw.clamp(_minScale, _maxScale).toDouble();
  }

  static double _sp(BuildContext context, double value) => value * _scale(context);

  static double xs(BuildContext context) => _sp(context, 4);
  static double sm(BuildContext context) => _sp(context, 8);
  static double md(BuildContext context) => _sp(context, 12);
  static double lg(BuildContext context) => _sp(context, 16);
  static double xl(BuildContext context) => _sp(context, 24);
  static double xxl(BuildContext context) => _sp(context, 32);

  static EdgeInsets screenPadding(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: xxl(context), vertical: md(context));

  static EdgeInsets cardPadding(BuildContext context) =>
      EdgeInsets.all(md(context));

  static double textFormFieldBorder(BuildContext context) => _sp(context, 2);
}